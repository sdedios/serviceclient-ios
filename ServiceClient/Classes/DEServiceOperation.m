/*
 * Copyright 2012 Simeon de Dios
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0 
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "DEServiceOperation.h"
#import "DEServiceOperation_Internal.h"
#import "DEServiceClient.h"
#import "DEServiceHelper.h"


#pragma mark Constants

static NSString * const FinishedKeyPath = @"isFinished";
static NSString * const ExecutingKeyPath = @"isExecuting";


#pragma mark -
#pragma mark Class Extension

@interface DEServiceOperation()
{
    @private __strong DEServiceClient *_serviceClient;
    @private __strong NSMutableURLRequest *_request;
    @private DEServiceFormat _format;
    @private dispatch_queue_priority_t _dispatchPriority;
    @private NSData * (__strong ^_bodyDataProvider)(DEServiceOperation *);
    @private id (__strong ^_transform)(NSHTTPURLResponse *, id);
    @private void (__strong ^_completion)(DEServiceResult, NSHTTPURLResponse *, id);
    @private __strong id _context;
    @private __strong NSHTTPURLResponse *_response;
    @private __strong NSMutableData *_responseData;
	@private BOOL _executing;
	@private BOOL _finished;
	@private BOOL _completed;
	@private BOOL _connectionIsCancelled;
}

#pragma mark -
#pragma mark Instance Methods

- (BOOL)isCompleted;

- (void)raiseCompletionWithResult: (DEServiceResult)result
    response: (NSHTTPURLResponse *)response
    data: (id)data;


@end  // @interface DEServiceOperation()



#pragma mark -
#pragma mark Class Definition

@implementation DEServiceOperation


#pragma mark -
#pragma mark Properties

@synthesize context = _context;


#pragma mark -
#pragma mark Constructors

- (id)_initWithRequest: (NSURLRequest *)request
    bodyDataProvider: (NSData * (^)(DEServiceOperation *))dataProvider
    format: (DEServiceFormat)format
    dispatchPriority: (dispatch_queue_priority_t)dispatchPriority
    transform: (id (^)(NSHTTPURLResponse *, id))transform
    completion: (void (^)(DEServiceResult, NSHTTPURLResponse *, id))completion
    serviceClient: (DEServiceClient *)serviceClient 
    context: (id)context   
{
    // abort if base initializer fails
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// initialize instance variables
    _request = [request mutableCopy];
    _format = format;
    _dispatchPriority = dispatchPriority;
    _bodyDataProvider = dataProvider == nil ? nil : [dataProvider copy];
    _transform = transform == nil ? nil : [transform copy];
    _completion = completion == nil ? nil : [completion copy];
    _serviceClient = serviceClient;
    _context = context;

	return self;
}


#pragma mark -
#pragma mark Overridden Methods

- (void)start
{
	// abort if cancelled
	if ([self isCancelled] == YES)
	{
		// raise finished notification
		[self willChangeValueForKey: FinishedKeyPath];		
		@synchronized(self)
		{
			_finished = YES;
		}		
		[self didChangeValueForKey: FinishedKeyPath];
		
		// callback delegate
        if (_completion != 0)
        {
            dispatch_queue_t mainQueue = dispatch_get_main_queue();
            dispatch_sync(mainQueue, ^
            {
                _completion(DEServiceResultCancelled, nil, nil);
            });
        }
		
		// stop processing
		return;
	}

	// start main execution via GCD
	[self willChangeValueForKey: ExecutingKeyPath];
    dispatch_queue_t globalQueue = dispatch_get_global_queue(_dispatchPriority,
        0);
    dispatch_async(globalQueue, ^
    {
        [self main];
    });
		
	// raise executing notifcation
	@synchronized(self)
	{
		_executing = YES;
	}
	[self didChangeValueForKey: ExecutingKeyPath];
}

- (void)main
{
	// start connection
	@autoreleasepool 
    {
        NSURLConnection *connection = nil;
        @try 
        {
            // notify client of connection start
            [_serviceClient serviceOperationDidBegin: self];
            
            // set connection as alive
            _connectionIsCancelled = NO;
            
            // add body data to request (if any)
            NSData *bodyData = _bodyDataProvider == nil
                ? nil
                : _bodyDataProvider(self);
            if (bodyData != nil)
            {
                [_request setHTTPBody: bodyData];
            }
            
            // ensure body data provider is released (frees intermediate data)
            _bodyDataProvider = nil;
            
            // create a new connection for the request (starts immediately)
            connection = [[NSURLConnection alloc]
                initWithRequest: _request 
                delegate: self];
                
            // abort if connection failed
            if (connection == nil)
            {
                // log error        
                NSLog(@"Cannot create connection to %@", 
                    [[_request URL] absoluteString]);
                
                // raise error
                NSError *error = [[NSError alloc]
                    initWithDomain: DEServiceClientErrorDomain 
                    code: DEServiceClientAllocationError
                    userInfo: [NSDictionary dictionaryWithObjectsAndKeys:
                        @"Unable to allocate underlying connection.", 
                            NSLocalizedDescriptionKey,                        
                        nil]];
                [_serviceClient serviceOperationFailed: self 
                    error: error];
                
                // stop processing
                return;
            }				

            // start run loop
            NSDate *distantFuture = [NSDate distantFuture];
            NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
            while (_connectionIsCancelled == NO 
                && [runLoop runMode: NSDefaultRunLoopMode 
                        beforeDate: distantFuture]);
            
            // release connection
            connection = nil;
        }
        
        // log and supress any exceptions
        @catch (NSException *e) 
        {
            NSLog(@"Unexpected exception during download: %@", e.reason);
        }
        
        // complete operation
        @finally
        {
            // notify client of connection end
            [_serviceClient serviceOperationDidEnd: self];
        
            // check completion status
            BOOL success = NO;
            @synchronized(self)
            {
                success = _completed;
            }
            
            // handle cancellation 
            if ([self isCancelled] == YES)
            {
                [self raiseCompletionWithResult: DEServiceResultCancelled 
                    response: nil 
                    data: nil];
            }
            
            // finalize download if completed
            else if (success == YES)
            {
                // try to deserialize/transform data
                BOOL errorEncountered = YES;
                id data = nil;
                @try 
                {
                    // deserialize data
                    NSError *error = nil;
                    data = [_serviceClient serviceOperation: self 
                        transformData: _responseData 
                        format: _format 
                        error: &error];
                        
                    // log error (if any)
                    if (error != nil)
                    {
                        NSLog(@"Response deserialize error: %@", 
                            error.localizedDescription);
                    }
                    
                    // or continue processing
                    else 
                    {
                        // transform data (if required)
                        if (_transform != nil)
                        {
                            data = _transform(_response, data);
                        }
                    
                        // mark as error free
                        errorEncountered = NO;
                    }
                }
                
                // suppress exceptions (handled via completion callback)
                @catch (NSException *e) 
                {                
                    NSLog(@"Response deserialize/transform failed unexpectedly: %@", 
                        e.reason);     
                        
                    // reset data (unreliable state)
                    data = nil;
                }

                // raise completion
                [self raiseCompletionWithResult: errorEncountered
                        ? DEServiceResultFailed
                        : DEServiceResultSuccess
                    response: _response 
                    data: data];
            }
            
            // otherwise, raise failure
            else 
            {
                [self raiseCompletionWithResult: DEServiceResultFailed
                    response: _response 
                    data: nil];
            }
        
            // raise executing/finished notifcations
            [self willChangeValueForKey: FinishedKeyPath];
            [self willChangeValueForKey: ExecutingKeyPath];
            @synchronized(self)
            {
                _executing = NO;
                _finished = YES;
            }
            [self didChangeValueForKey: ExecutingKeyPath];
            [self didChangeValueForKey: FinishedKeyPath];
            
            // stop connection (if still open)
            if (connection != nil)
            {
                [connection cancel];
                connection = nil;
            }
            
            // release response
            _response = nil;
            _responseData = nil;
        }        
    }
}

- (BOOL)isConcurrent
{
	return YES;
}

- (BOOL)isExecuting
{
	@synchronized(self)
	{
		return _executing;
	}
}

- (BOOL)isFinished
{
	@synchronized(self)
	{
		return _finished;
	}
}


#pragma mark -
#pragma mark Internal Methods

- (BOOL)isCompleted
{
	@synchronized(self)
	{
		return _completed;
	}
}

- (void)raiseCompletionWithResult: (DEServiceResult)result
    response: (NSHTTPURLResponse *)response
    data: (id)data
{
    if (_completion != nil)
    {
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_sync(mainQueue, ^
        {
            _completion(result, response, data);
        });
    }
}


#pragma mark -
#pragma mark NSURLConnection Delegate Methods

- (void)connection: (NSURLConnection *)connection
    didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
{
    // cancel if not first attempt
    NSInteger retryCount = challenge.previousFailureCount;
    if (retryCount != 0)
    {
        // cancel authentication
        [challenge.sender cancelAuthenticationChallenge: challenge];
        
        // TODO: notify service client
        
        // stop processing
        return;
    }
    
    // get credential from service client
    NSURLCredential *credential = [_serviceClient 
        credentialForServiceOperation: self
        challenge: challenge];
    
    // use credential if provided
    if (credential != nil
        && [[NSNull null] isEqual: credential] == NO)
    {
        [challenge.sender useCredential: credential 
            forAuthenticationChallenge: challenge];
    }
    
    // or cancel challenge
    else 
    {
        [challenge.sender cancelAuthenticationChallenge: challenge];
    }
}

- (void)connection: (NSURLConnection *)connection 
	didReceiveResponse: (NSURLResponse *)response
{
    // cache response
	NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    _response = httpResponse;    
    
	// cancel if operation if cancelled
	if ([self isCancelled] == YES)
	{
		[connection cancel];
		_connectionIsCancelled = YES;
	}
    
    // otherwise, create data container
    else
    {    
        // create using default size
        _responseData = [[NSMutableData alloc]
            init];
    }
}

- (void)connection: (NSURLConnection *)connection 
	didReceiveData:(NSData *)data
{
	// cancel if operation is cancelled
	if ([self isCancelled] == YES)
    {
		[connection cancel];
		_connectionIsCancelled = YES;
	}	
	
	// or continue download
	else 
	{
        [_responseData appendData: data];
	}
}

- (void)connection: (NSURLConnection *)connection 
	didFailWithError: (NSError *)error
{
    // forward errors to service client
    [_serviceClient serviceOperationFailed: self 
        error: error];
}

- (void)connectionDidFinishLoading: (NSURLConnection *)connection
{
	// mark as completed
	@synchronized(self)
	{
		_completed = YES;
	}
}


@end  // @implementation DEServiceOperation
