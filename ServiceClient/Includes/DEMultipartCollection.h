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

#import "DEMultipart.h"


#pragma mark Constants

NSString * const DEMultipartDelimiterDefault;


#pragma mark -
#pragma mark Class Interface

@interface DEMultipartCollection : NSObject


#pragma mark -
#pragma mark Constructors

- (id)initWithParts: (DEMultipart *)firstPart, ... NS_REQUIRES_NIL_TERMINATION;

- (id)initWithPartArray: (NSArray *)parts;


#pragma mark -
#pragma mark Properties

@property (nonatomic, readonly) NSArray *parts;

@property (nonatomic, copy) NSString *partDelimiter;


@end  // @interface DEMultipartCollection
