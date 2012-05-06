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

#import "DEMultipartCollection.h"
#import "DEMultipartCollection_Internal.h"
#import "DEMultipart_Internal.h"


#pragma mark Constants

NSString * const DEMultipartDelimiterDefault = @"__com.dedios.ServiceClient__";


#pragma mark -
#pragma mark Class Extension

@interface DEMultipartCollection()
{
    @private __strong NSArray *_parts;
    @private __strong NSString *_partDelimiter;
}
@end  // @interface DEMultipartCollection()


#pragma mark -
#pragma mark Class Definition

@implementation DEMultipartCollection


#pragma mark -
#pragma mark Properties

@synthesize parts = _parts;
@synthesize partDelimiter = _partDelimiter;


#pragma mark -
#pragma mark Constructors

- (id)initWithParts: (DEMultipart *)firstPart, ... 
{
    // convert variable args to part array
    NSMutableArray *parts = [[NSMutableArray alloc]
        initWithCapacity: 4];
    va_list args;
    va_start(args, firstPart);
    for (DEMultipart *part = firstPart; part != nil; 
        part = va_arg(args, DEMultipart *))
    {
        [parts addObject: part];
    }
    va_end(args);

    // forward construction
    return [self initWithPartArray: parts];
}

- (id)initWithPartArray: (NSArray *)parts
{
    // abort if allocation fails
    if ((self = [super init]) == nil)
    {
        return nil;
    }
    
    // initialize instance variables
    _parts = parts;
    _partDelimiter = DEMultipartDelimiterDefault;
    
    // return instance
    return self;
}


#pragma mark -
#pragma mark Internal Methods

- (NSData *)data
{
    [NSException raise: @"NotImplemented" 
        format: @"The MultipartCollection is not yet complete"];
    return nil;
}


@end  // @implementation DEMultipartCollection
