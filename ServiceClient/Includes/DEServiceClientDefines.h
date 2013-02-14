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
 
#pragma mark Constants

#define DERequestTimeout 30.0


#pragma mark -
#pragma mark Error Domain/Codes

extern NSString * const DEServiceClientErrorDomain;

typedef enum 
{    
    DEServiceClientAllocationError = 0,
    DEServiceClientInvalidFormatError = 1,
    DEServiceClientUnhandledFormatError = 2

} DEServiceClientErrorCode;


#pragma mark -
#pragma mark Enumerations

typedef enum 
{
    DEServiceMethodGet,
    DEServiceMethodPost,
    DEServiceMethodPut,
    DEServiceMethodDelete
    
} DEServiceMethod;

enum
{
    DEServiceFormatRaw = 0,
    DEServiceFormatString = 1,
    DEServiceFormatFormEncoded = 2,
    DEServiceFormatJson = 3
    
};
typedef NSUInteger DEServiceFormat;

typedef enum
{
    DEServiceResultCancelled = -1,
    DEServiceResultFailed = 0,
    DEServiceResultSuccess = 1
    
} DEServiceResult;
