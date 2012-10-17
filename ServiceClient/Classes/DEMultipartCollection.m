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

NSString * const DEMultipartTokenDefault = @"__com.dedios.ServiceClient__";


#pragma mark -
#pragma mark Class Extension

@interface DEMultipartCollection()
{
    @private __strong NSArray *_parts;
    @private __strong NSString *_partToken;
}
@end  // @interface DEMultipartCollection()


#pragma mark -
#pragma mark Class Definition

@implementation DEMultipartCollection


#pragma mark -
#pragma mark Properties

@synthesize parts = _parts;
@synthesize partToken = _partToken;


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
    _partToken = DEMultipartTokenDefault;
    
    // return instance
    return self;
}


#pragma mark -
#pragma mark Internal Methods

- (NSData *)data
{
    // allocate data
    NSMutableData *data = [[NSMutableData alloc]
        initWithCapacity: 128];
        
    // define constants
    NSString *partDelimiter = [NSString stringWithFormat: @"--%@\r\n",
		_partToken];
    NSData *partDelimiterData = [partDelimiter
		dataUsingEncoding: NSUTF8StringEncoding];
	NSData *newlineData = [@"\r\n"
		dataUsingEncoding: NSUTF8StringEncoding];
    
    // append parts to data
    NSNull *null = [NSNull null];
    for (DEMultipart *multipart in _parts) 
    {
        @autoreleasepool 
        {
            // append delimiter
            [data appendData: partDelimiterData];
            
            // append standard part disposition
            NSString *filename = multipart.filename;
            if (filename == nil
                || [null isEqual: filename])
            {
                [data appendData: [[NSString stringWithFormat: 
                    @"Content-Disposition: form-data; name=\"%@\"\r\n", 
                    multipart.name] 
                        dataUsingEncoding: NSUTF8StringEncoding]];
            }
            
            // or append file part disposition
            else
            {
                [data appendData: [[NSString stringWithFormat: 
                    @"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",
                    multipart.name, filename]
                        dataUsingEncoding: NSUTF8StringEncoding]];
            }
            
            // append content type if specified
            NSString *contentType = multipart.contentType;
            if (contentType != nil
                && [null isEqual: contentType] == NO)
            {
                [data appendData: [[NSString stringWithFormat:
                    @"Content-Type: %@\r\n", 
                    contentType] 
                        dataUsingEncoding: NSUTF8StringEncoding]];
            }
            
            // end part header
            [data appendData: newlineData];

            
            // append part body
            [data appendData: [multipart data]];
            
            // end part body
            [data appendData: newlineData];
        }
    }
    
    // finalize data
    [data appendData: [[NSString stringWithFormat: @"--%@--\r\n", _partToken] 
        dataUsingEncoding: NSUTF8StringEncoding]];

    // return data
    return data;
}


@end  // @implementation DEMultipartCollection
