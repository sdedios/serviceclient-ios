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
 

#pragma mark Class Interface

@interface DEServiceHelper : NSObject

#pragma mark -
#pragma mark Methods

+ (NSString *)base64EncodeString: (NSString *)string;
+ (NSString *)base64Encode: (NSData *)data;

+ (NSString *)stringByEscapingURLArgument: (NSString *)argument;
+ (NSString *)stringByUnescapingURLArgument: (NSString *)argument;

+ (NSString *)URLArgumentsFromDictionary: (NSDictionary *)dictionary;
+ (NSDictionary *)dictionaryFromURLArguments: (NSString *)arguments;

+ (void)updateRequest: (NSMutableURLRequest *)request
    setParameter: (NSString *)key
    toValue: (NSString *)value;
+ (void)updateRequest: (NSMutableURLRequest *)request
    deleteParameter: (NSString *)key;

@end  // @interface DEServiceHelper
