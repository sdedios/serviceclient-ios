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


#pragma mark Type Definitions

typedef id DEServiceRequest; 


#pragma mark -
#pragma mark Class Interface

@interface DEServiceClient : NSObject


#pragma mark -
#pragma mark Properties

@property (nonatomic, readonly) NSOperationQueue *requestQueue;

@property (nonatomic, assign) NSTimeInterval requestTimeout;


#pragma mark - 
#pragma mark Constructors

- (id)init;

- (id)initWithRequestQueue: (NSOperationQueue *)requestQueue;


#pragma mark -
#pragma mark Instance Methods

- (DEServiceOperation *)beginRequestAsync: (NSString *)uri
    method: (DEServiceMethod)method
    headers: (NSDictionary *)headers
    parameters: (NSDictionary *)parameters    
    body: (NSString *)body 
    format: (DEServiceFormat)format
    transform: (id (^)(NSHTTPURLResponse *response, id data))transform
    completion: (void (^)(DEServiceResult result, NSHTTPURLResponse *response, id data))completion;

- (DEServiceOperation *)beginRequestAsync: (NSString *)uri
    method: (DEServiceMethod)method
    headers: (NSDictionary *)headers
    parameters: (NSDictionary *)parameters    
    body: (NSString *)body 
    format: (DEServiceFormat)format
    transform: (id (^)(NSHTTPURLResponse *response, id data))transform
    completion: (void (^)(DEServiceResult result, NSHTTPURLResponse *response, id data))completion
    queuePriority: (NSOperationQueuePriority)queuePriority
    dispatchPriority: (dispatch_queue_priority_t)dispatchPriority
    cachePolicy: (NSURLRequestCachePolicy)cachePolicy;

- (DEServiceOperation *)beginRequestAsync: (NSString *)uri
    method: (DEServiceMethod)method
    headers: (NSDictionary *)headers
    parameters: (NSDictionary *)parameters    
    bodyData: (NSData *)bodyData 
    format: (DEServiceFormat)format
    transform: (id (^)(NSHTTPURLResponse *response, id data))transform
    completion: (void (^)(DEServiceResult result, NSHTTPURLResponse *response, id data))completion;

- (DEServiceOperation *)beginRequestAsync: (NSString *)uri
    method: (DEServiceMethod)method
    headers: (NSDictionary *)headers
    parameters: (NSDictionary *)parameters    
    bodyData: (NSData *)bodyData 
    format: (DEServiceFormat)format
    transform: (id (^)(NSHTTPURLResponse *response, id data))transform
    completion: (void (^)(DEServiceResult result, NSHTTPURLResponse *response, id data))completion
    queuePriority: (NSOperationQueuePriority)queuePriority
    dispatchPriority: (dispatch_queue_priority_t)dispatchPriority
    cachePolicy: (NSURLRequestCachePolicy)cachePolicy;

- (DEServiceOperation *)beginURLRequestAsync: (NSURLRequest *)request
    format: (DEServiceFormat)format
    transform: (id (^)(NSHTTPURLResponse *response, id data))transform
    completion: (void (^)(DEServiceResult result, NSHTTPURLResponse *response, id data))completion
    queuePriority: (NSOperationQueuePriority)queuePriority
    dispatchPriority: (dispatch_queue_priority_t)dispatchPriority;

- (void)serviceOperationDidBegin: (DEServiceOperation *)operation;

- (void)serviceOperationDidEnd: (DEServiceOperation *)operation;

- (void)serviceOperationFailed: (DEServiceOperation *)operation
    error: (NSError *)error;

- (id)serviceOperation: (DEServiceOperation *)operation
    transformData: (NSData *)data
    format: (DEServiceFormat)format
    error: (NSError * __autoreleasing *)error;

@end  // @interface DEServiceClient
