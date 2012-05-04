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
  
#import "DENetworkIndicatorHelper.h"


#pragma mark Constants

//static NSString * const SomeString = @"";
//#define SomeContant 1.0


#pragma mark -
#pragma mark Internal Interface

@interface DENetworkIndicatorHelper ()

@end  // @interface DENetworkIndicatorHelper ()


#pragma mark -
#pragma mark Class Variables

static __strong NSLock *_networkOperationLock;
static NSInteger _networkOperationCount;



#pragma mark -
#pragma mark Class Definition

@implementation DENetworkIndicatorHelper


#pragma mark -
#pragma mark Constructors

+ (void)initialize
{
    static volatile BOOL classInitialized = NO;
    if (classInitialized == NO)
    {
        // initialize class variables
        _networkOperationLock = [[NSLock alloc]
            init];
        _networkOperationCount = 0;
            
        // close double-checked lock
        classInitialized = YES;
    }
}

+ (id)allocWithZone: (NSZone *)zone
{
    return nil;
}


#pragma mark -
#pragma mark Public Methods

+ (void)networkOperationBegin
{
    [_networkOperationLock lock];
    if (++_networkOperationCount == 1)
    {
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_sync(mainQueue, ^
        {
           [[UIApplication sharedApplication]
                setNetworkActivityIndicatorVisible: YES];
        });
    }
    [_networkOperationLock unlock];
}

+ (void)networkOperationEnd
{
    [_networkOperationLock lock];
    if (--_networkOperationCount == 0)
    {
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_sync(mainQueue, ^
        {
           [[UIApplication sharedApplication]
                setNetworkActivityIndicatorVisible: NO];
        });
    }
    NSAssert(_networkOperationCount >= 0, 
        @"Expected network operation count to be positive.");
    [_networkOperationLock unlock];
}


@end  // @interface DENetworkIndicatorHelper