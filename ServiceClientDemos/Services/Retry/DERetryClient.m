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
 
#import "DERetryClient.h"
#import "DENetworkIndicatorHelper.h"


#pragma mark Constants

static NSString * const DEGithubUri = @"https://api.github.com";
static NSString * const DEGithubAuthorizePath = @"authorizations";
static NSString * const DEGithubReposPath = @"user/repos";



#pragma mark -
#pragma mark Internal Interface

@interface DERetryClient ()
{
    @private __strong NSString *_accessToken;
}

#pragma mark -
#pragma mark Methods

- (DEServiceOperation *)refreshAccessTokenWithCompletion:
    (void (^)(DEServiceResult result, NSInteger statusCode, NSString *token))completion;

- (BOOL)tryRefreshAccessToken: (DEServiceOperation *)operation;


@end  // @interface DERetryClient ()


#pragma mark -
#pragma mark Class Definition

@implementation DERetryClient


#pragma mark -
#pragma mark Properties

@synthesize accessToken = _accessToken;


#pragma mark -
#pragma mark Constructors

- (id)initWithRequestQueue: (NSOperationQueue *)requestQueue
{
    // abort base constructor fails
    if ((self = [super initWithRequestQueue: requestQueue]) == nil)
    {
        return nil;
    }
    
    // return self
    return self;
}


#pragma mark -
#pragma mark Public Methods

- (void)testWithCompletion: (void (^)(DEServiceResult, NSInteger, NSString *))completion
{
    // create request data
    NSDictionary *parameters = [[NSDictionary alloc]
        initWithObjectsAndKeys:
            _accessToken, @"access_token",
            @"bar", @"foo",
            nil];            
    NSDictionary *headers = [[NSDictionary alloc]
        initWithObjectsAndKeys:
            @"application/json", @"Accept",
            nil];
            
    // send request
    [self beginRequestWithURL: @"http://localhost/~sdedios/test.php"
        method: DEServiceMethodGet 
        headers: headers 
        parameters: parameters 
        bodyData: nil
        format: DEServiceFormatString
        transform: nil 
        completion: ^(DEServiceResult result, NSHTTPURLResponse *response, 
            id message)
        {
            // callback completion (if any)
            if (completion != nil)
            {
                completion(result, response.statusCode, message);
            }
        }         
        context: nil];
}


#pragma mark -
#pragma mark Overridden Methods

- (void)serviceOperationDidBegin: (DEServiceOperation *)operation
{
    [DENetworkIndicatorHelper networkOperationBegin];
}

- (void)serviceOperationDidEnd: (DEServiceOperation *)operation
{
    [DENetworkIndicatorHelper networkOperationEnd];
}

- (BOOL)serviceOperationShouldRetry: (DEServiceOperation *)operation
    response: (NSHTTPURLResponse *)response
    data: (NSData *)data
    attempt: (NSUInteger)retryCount
{
    // stop if max retry count has been met
    if (retryCount == 3)
    {
        return NO;
    }
    
    // determine domain
    NSURLRequest *request = operation.request;
    NSString *domain = request.URL.host;
    
    // evaluate SSO requests
    BOOL isAuthenticationMethod = YES;
    NSInteger statusCode = response.statusCode;
    if ([domain isEqualToString: @"127.0.0.1"])
    {
        if (statusCode == 200
            && isAuthenticationMethod == NO)
        {
            // parse json response
            NSError *error = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData: data
                options: kNilOptions
                error: &error];
            
            // retry request if token is invalid
            NSString *requestError = error == nil
                ? nil
                : [json objectForKey: @"error"];
            if (requestError != nil)
            {
                return [self tryRefreshAccessToken: operation];
            }
        }
    }
    
    // or evaluate data service requests
    else if ([domain isEqualToString: @"localhost"]
        && statusCode == 401)
    {
        return [self tryRefreshAccessToken: operation];
    }
    
    // don't retry if control flow reaches this position
    return NO;
}


#pragma mark -
#pragma mark Private Methods

- (DEServiceOperation *)refreshAccessTokenWithCompletion: (void (^)(DEServiceResult, NSInteger, NSString *))completion
{
    // create request data
    NSString *refreshToken = @"refresh";
    NSDictionary *parameters = [[NSDictionary alloc]
        initWithObjectsAndKeys:
            refreshToken, @"access_token",
            @"xyz", @"abc",
            nil];            
    NSDictionary *headers = [[NSDictionary alloc]
        initWithObjectsAndKeys:
            @"application/json", @"Accept",
            nil];
            
    // send request
    return [self beginRequestWithURL: @"http://127.0.0.1/~sdedios/refresh.php"
        method: DEServiceMethodGet 
        headers: headers 
        parameters: parameters 
        bodyData: nil
        format: DEServiceFormatJson
        transform: nil 
        completion: ^(DEServiceResult result, NSHTTPURLResponse *response, 
            id json)
        {
            // capture access token
            NSString *token = [json objectForKey: @"access_token"];
        
            // callback completion (if any)
            if (completion != nil)
            {
                completion(result, response.statusCode, token);
            }
        }         
        context: nil];
}

- (BOOL)tryRefreshAccessToken: (DEServiceOperation *)operation
{
    // send a separate request
    DEServiceOperation *refreshOperation =
        [self refreshAccessTokenWithCompletion:
            ^(DEServiceResult result, NSInteger statusCode, NSString *token)
            {
                _accessToken = token;
            }];
    [refreshOperation waitUntilFinished];
    
    // retry if refresh succeeded
    if (_accessToken != nil)
    {
        // update access token of operation
        [DEServiceHelper updateRequest: operation.request
            setParameter: @"access_token"
            toValue: _accessToken];
        
        // request retry
        return YES;
    }

    // or stop on failure (logout required)
    else
    {
        return NO;
    }
}


@end  // @interface DEGithubClient