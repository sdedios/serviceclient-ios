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

#import "DEServiceClient.h"
#import "DEServiceOperation_Internal.h"
#import "DEMultipartCollection_Internal.h"


#pragma mark Class Extension

@interface DEServiceClient()
{
    @private __strong NSOperationQueue *_requestQueue;
    @private NSTimeInterval _requestTimeout;
}
@end  // @interface DEServiceClient()


#pragma mark -
#pragma mark Class Definition

@implementation DEServiceClient


#pragma mark -
#pragma mark Properties

@synthesize requestQueue = _requestQueue;
@synthesize requestTimeout = _requestTimeout;


#pragma mark - 
#pragma mark Constructors

- (id)init
{
    // create new operation queue
    NSOperationQueue *requestQueue = [[NSOperationQueue alloc]
        init];

    // initialize with new operation queue
    return [self initWithRequestQueue: requestQueue];  
}

- (id)initWithRequestQueue: (NSOperationQueue *)requestQueue
{
    // abort if default allocation fails
    if ((self = [super init]) == nil)
    {
        return nil;
    }
    
    // initalize instance variables
    _requestQueue = requestQueue;
    _requestTimeout = 60.0;
    
    // return instance
    return self;
}


#pragma mark -
#pragma mark Public Methods

- (DEServiceOperation *)beginRequestWithURL: (NSString *)uri
    method: (DEServiceMethod)method
    headers: (NSDictionary *)headers
    parameters: (NSDictionary *)parameters    
    body: (NSString *)body 
    format: (DEServiceFormat)format
    transform: (id (^)(NSHTTPURLResponse *response, id data))transform
    completion: (void (^)(DEServiceResult result, NSHTTPURLResponse *response, id data))completion
    context: (id)context
{
    return [self beginRequestWithURL: uri 
        method: method 
        headers: headers 
        parameters: parameters 
        body: body
        format: format 
        transform: transform 
        completion: completion
        queuePriority: NSOperationQueuePriorityNormal 
        dispatchPriority: DISPATCH_QUEUE_PRIORITY_DEFAULT 
        cachePolicy: NSURLRequestUseProtocolCachePolicy
        context: context];
}

- (DEServiceOperation *)beginRequestWithURL: (NSString *)uri
    method: (DEServiceMethod)method
    headers: (NSDictionary *)headers
    parameters: (NSDictionary *)parameters    
    body: (NSString *)body 
    format: (DEServiceFormat)format
    transform: (id (^)(NSHTTPURLResponse *response, id data))transform
    completion: (void (^)(DEServiceResult result, NSHTTPURLResponse *response, id data))completion
    queuePriority: (NSOperationQueuePriority)queuePriority
    dispatchPriority: (dispatch_queue_priority_t)dispatchPriority
    cachePolicy: (NSURLRequestCachePolicy)cachePolicy
    context: (id)context
{
	// encode body data, if provided
	NSData *bodyData = nil;
	if (body != nil
        && [[NSNull null] isEqual: body] == NO)
    {
        bodyData = [body dataUsingEncoding: NSUTF8StringEncoding];
    }

    // make request
    return [self beginRequestWithURL: uri 
        method: method 
        headers: headers 
        parameters: parameters 
        bodyData: bodyData
        format: format 
        transform: transform 
        completion: completion
        queuePriority: queuePriority 
        dispatchPriority: dispatchPriority 
        cachePolicy: cachePolicy
        context: context];
}

- (DEServiceOperation *)beginRequestWithURL: (NSString *)uri
    method: (DEServiceMethod)method
    headers: (NSDictionary *)headers
    parameters: (NSDictionary *)parameters    
    parts: (DEMultipartCollection *)parts
    format: (DEServiceFormat)format
    transform: (id (^)(NSHTTPURLResponse *response, id data))transform
    completion: (void (^)(DEServiceResult result, NSHTTPURLResponse *response, id data))completion
    queuePriority: (NSOperationQueuePriority)queuePriority
    dispatchPriority: (dispatch_queue_priority_t)dispatchPriority
    cachePolicy: (NSURLRequestCachePolicy)cachePolicy
    context: (id)context
{
	// encode body data, if provided
	NSData *bodyData = [parts data];
	
    // make request
    return [self beginRequestWithURL: uri 
        method: method 
        headers: headers 
        parameters: parameters 
        bodyData: bodyData
        format: format 
        transform: transform 
        completion: completion
        queuePriority: queuePriority 
        dispatchPriority: dispatchPriority 
        cachePolicy: cachePolicy
        context: context];
}

- (DEServiceOperation *)beginRequestWithURL: (NSString *)uri
    method: (DEServiceMethod)method
    headers: (NSDictionary *)headers
    parameters: (NSDictionary *)parameters    
    bodyData: (NSData *)bodyData 
    format: (DEServiceFormat)format
    transform: (id (^)(NSHTTPURLResponse *response, id data))transform
    completion: (void (^)(DEServiceResult result, NSHTTPURLResponse *response, id data))completion
    context: (id)context
{
    return [self beginRequestWithURL: uri 
        method: method 
        headers: headers 
        parameters: parameters 
        bodyData: bodyData 
        format: format 
        transform: transform 
        completion: completion
        queuePriority: NSOperationQueuePriorityNormal 
        dispatchPriority: DISPATCH_QUEUE_PRIORITY_DEFAULT 
        cachePolicy: NSURLRequestUseProtocolCachePolicy
        context: context];
}

- (DEServiceOperation *)beginRequestWithURL: (NSString *)uri
    method: (DEServiceMethod)method
    headers: (NSDictionary *)headers
    parameters: (NSDictionary *)parameters    
    bodyData: (NSData *)bodyData 
    format: (DEServiceFormat)format
    transform: (id (^)(NSHTTPURLResponse *response, id data))transform
    completion: (void (^)(DEServiceResult result, NSHTTPURLResponse *response, id data))completion
    queuePriority: (NSOperationQueuePriority)queuePriority
    dispatchPriority: (dispatch_queue_priority_t)dispatchPriority
    cachePolicy: (NSURLRequestCachePolicy)cachePolicy
    context: (id)context
{
    // apply query parameters (if any)
    if (parameters != nil
        && [parameters count] > 0)
    {
        uri = [NSString stringWithFormat: @"%@?%@", uri, 
            [DEServiceHelper URLArgumentsFromDictionary: parameters]];
    }

    // create request
    NSURL *url = [[NSURL alloc]
        initWithString: uri];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
        initWithURL: url];
    
    // initialize request
    switch (method)
    {
        case DEServiceMethodGet:
            [request setHTTPMethod: @"GET"];
            break;
        case DEServiceMethodPost:
            [request setHTTPMethod: @"POST"];
            break;
        case DEServiceMethodPut:
            [request setHTTPMethod: @"PUT"];
            break;
        case DEServiceMethodDelete:
            [request setHTTPMethod: @"DELETE"];
            break;
        default:
            // throw exception
            break;
    }
    [request setAllHTTPHeaderFields: headers];
    [request setTimeoutInterval: _requestTimeout];
	[request setCachePolicy: cachePolicy];
	
	// set body, if provided
	if (bodyData != nil)
	{
		[request setHTTPBody: bodyData];
    }

    // process request
    return [self beginRequest: request 
        format: format 
        transform: transform 
        completion: completion 
        queuePriority: queuePriority 
        dispatchPriority: dispatchPriority
        context: context];
}

- (DEServiceOperation *)beginRequest: (NSURLRequest *)request
    format: (DEServiceFormat)format
    transform: (id (^)(NSHTTPURLResponse *response, id data))transform
    completion: (void (^)(DEServiceResult result, NSHTTPURLResponse *response, id data))completion
    queuePriority: (NSOperationQueuePriority)queuePriority
    dispatchPriority: (dispatch_queue_priority_t)dispatchPriority
    context: (id)context
{    
    // create request operation
    DEServiceOperation *operation = [[DEServiceOperation alloc]
        _initWithRequest: request
        format: format 
        dispatchPriority: dispatchPriority 
        transform: transform
        completion: completion
        serviceClient: self
        context: context];
    [operation setQueuePriority: queuePriority];
    
    // start operation
    [_requestQueue addOperation: operation];

    return operation;
}

- (void)serviceOperationDidBegin: (DEServiceOperation *)operation
{
}

- (void)serviceOperationDidEnd: (DEServiceOperation *)operation
{
}

- (void)serviceOperationFailed: (DEServiceOperation *)operation
    error: (NSError *)error
{
}

- (NSURLCredential *)credentialForServiceOperation: (DEServiceOperation *)operation
    challenge: (NSURLAuthenticationChallenge *)challenge
{
    return nil;
}

- (id)serviceOperation: (DEServiceOperation *)operation
    transformData: (NSData *)data
    format: (DEServiceFormat)format
    error: (NSError * __autoreleasing *)error
{
    // trasform data based on target format
    id transformedData;
    switch (format)
    {
        case DEServiceFormatRaw:
            transformedData = data;
            break;
            
        case DEServiceFormatString:
            transformedData = [[NSString alloc]
                initWithData: data 
                encoding: NSUTF8StringEncoding];
            break;
            
        case DEServiceFormatFormEncoded:
        {
            NSString *content = [[NSString alloc]
                initWithData: data 
                encoding: NSUTF8StringEncoding];
            transformedData = [DEServiceHelper 
                dictionaryFromURLArguments: content];
            break;
        }
        
        case DEServiceFormatJson:
        {
            // transform json
            NSError *jsonError = nil;
            transformedData = [NSJSONSerialization JSONObjectWithData: data 
                options: NSJSONReadingAllowFragments 
                error: &jsonError];
                
            // handle error (if any and supported)
            if (jsonError != nil
                && error != NULL)
            {
                *error = [[NSError alloc]
                    initWithDomain: DEServiceClientErrorDomain 
                    code: DEServiceClientInvalidFormatError 
                    userInfo: [NSDictionary dictionaryWithObjectsAndKeys:
                        @"Unable to parse JSON.", NSLocalizedDescriptionKey,
                        jsonError, NSUnderlyingErrorKey,                         
                        nil]];
            }
            
            break;  
        }
            
        default:
        {
            // specify error if transform is unhandled
            if (error != NULL)
            {
                *error = [[NSError alloc]
                    initWithDomain: DEServiceClientErrorDomain 
                    code: DEServiceClientUnhandledFormatError
                    userInfo: [NSDictionary dictionaryWithObjectsAndKeys:
                        @"Unrecognized format specified.  Custom formats must be handled by derived class.", 
                            NSLocalizedDescriptionKey,
                        nil]];
            }
        
            // don't return any data
            transformedData = nil;
            break;
        }
    }
    
    // return transformed response
    return transformedData;
}


@end  // @implementation DEServiceClient
