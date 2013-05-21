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

#import "DEServiceHelper.h"


#pragma mark Class Variables

static const char *_base64EncodingTable = 
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";


#pragma mark -
#pragma mark Class Definition

@implementation DEServiceHelper


#pragma mark -
#pragma mark Constructors

+ (id)alloc
{
    // disallow allocation (static class)
    return nil;
}


#pragma mark -
#pragma mark Public Methods

+ (NSString *)base64EncodeString: (NSString *)string
{
    NSData *data = [string dataUsingEncoding: NSUTF8StringEncoding];
    return [self base64Encode: data];
}

+ (NSString *)base64Encode: (NSData *)data
{
    // skip if no data
    int bytesRemaining = [data length];
    if (bytesRemaining == 0)
    {
        return nil;
    }
    
    // create input/output buffers
    const unsigned char *inputReader = [data bytes];
    char *outputBuffer = (char *)calloc((int)(ceilf((((float)bytesRemaining + 2) * 4) / 3)) + 1,
        sizeof(char));
    char *outputWriter = outputBuffer;

    // convert until less than 3 bytes remain
    const char * const encodingTable = _base64EncodingTable;
    while (bytesRemaining > 2) 
    {
        // convert
        *outputWriter++ = encodingTable[inputReader[0] >> 2];
        *outputWriter++ = encodingTable[((inputReader[0] & 0x03) << 4) 
            + (inputReader[1] >> 4)];
        *outputWriter++ = encodingTable[((inputReader[1] & 0x0f) << 2) 
            + (inputReader[2] >> 6)];
        *outputWriter++ = encodingTable[inputReader[2] & 0x3f];

        // update trackers
        inputReader += 3;
        bytesRemaining -= 3; 
    }

    // finalize conversion
    if (bytesRemaining > 0) 
    {
        // convert first byte
        *outputWriter++ = encodingTable[inputReader[0] >> 2];
        
        // convert remaining (if more than 1)
        if (bytesRemaining > 1) 
        {
            *outputWriter++ = encodingTable[((inputReader[0] & 0x03) << 4) 
                + (inputReader[1] >> 4)];
            *outputWriter++ = encodingTable[(inputReader[1] & 0x0f) << 2];
            *outputWriter++ = '=';
        } 
        
        // or convert last byte and pad
        else 
        {
            *outputWriter++ = encodingTable[(inputReader[0] & 0x03) << 4];
            *outputWriter++ = '=';
            *outputWriter++ = '=';
        }
    }

    // terminate with eos (null character)
    *outputWriter = '\0';

    // encode output and release buffer
    NSString *encodedData = [NSString stringWithCString: outputBuffer
        encoding: NSASCIIStringEncoding];
    free(outputBuffer);
    
    // return encoded data
    return encodedData;
}

static const short _base64DecodingTable[256] =
{
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -2, -1, -1, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, -2, -2, 63,
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, -2, -2, -2,
    -2,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, -2,
    -2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
};

+ (NSString *)stringByEscapingURLArgument: (NSString *)argument
{
    CFStringRef string = CFURLCreateStringByAddingPercentEscapes(
        kCFAllocatorDefault, (__bridge CFStringRef)argument, NULL,
        (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    return (__bridge_transfer NSString *)string;
}

+ (NSString *)stringByUnescapingURLArgument: (NSString *)argument
{
    // unescape encoded spaces
    NSMutableString *string = [NSMutableString stringWithString: argument];
    [string replaceOccurrencesOfString: @"+" 
        withString: @" " 
        options: NSLiteralSearch 
        range: (NSRange){0, [string length]}];
        
    // unescape remaining characters
    return [string 
        stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
}

+ (NSString *)URLArgumentsFromDictionary: (NSDictionary *)dictionary
{
    // return nil if no arguments specified
    NSUInteger argumentCount = [dictionary count];
    if (argumentCount == 0)
    {
        return nil;
    }

    // create mutable string for concatenating args
    const NSUInteger capacityPerArg = 20;
    NSMutableString *arguments = [[NSMutableString alloc]
        initWithCapacity: capacityPerArg * argumentCount];
        
    // build arguments
    NSUInteger keyIndex = 0;
    for (NSString *key in dictionary)
    {
        // append separator (if required)
        if (keyIndex++ > 0)
        {
            [arguments appendString: @"&"];
        }
        
        // append key
        [arguments appendString: [self stringByEscapingURLArgument: key]];
    
        // append value (if specified)
        NSObject *value = [dictionary objectForKey: key];
        if (value != nil
            && [[NSNull null] isEqual: value] == NO)
        {
            // append separator
            [arguments appendString: @"="];
            
            // escape value
            NSString *escapedValue = [value description];
            escapedValue = [self stringByEscapingURLArgument: escapedValue];
            
            // append value
            [arguments appendString: escapedValue];
        }
    }    
    
    // return args
    return arguments;
}

+ (NSDictionary *)dictionaryFromURLArguments: (NSString *)arguments
{
    // create dictionary
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    // evaluate tokenized components
    NSArray *components = [arguments componentsSeparatedByString: @"&"];
    for (NSString *component in components)
    {
        // skip if component is empty
        if ([component length] == 0)
        {
            continue;
        }
        
        // resolve key/value
        NSRange separatorPosition = [component rangeOfString: @"="];
        NSString *key;
        NSString *value;
        if (separatorPosition.location == NSNotFound)
        {
            key = [self stringByUnescapingURLArgument: component];
            value = @"";
        }
        else
        {
            key = [self stringByUnescapingURLArgument: [component 
                substringToIndex: separatorPosition.location]];
            value = [self stringByUnescapingURLArgument: [component 
                substringFromIndex: separatorPosition.location
                    + separatorPosition.length]];
        }

        // add key/value to dictionary
        [dictionary setObject: value 
            forKey: key];
    }
    
    // return dictionary
    return dictionary;
}

+ (void)updateRequest: (NSMutableURLRequest *)request
    setParameter: (NSString *)key
    toValue: (NSString *)value
{
    // extract query parameters
    NSURL *url = request.URL;
    NSString *query = url.query;
    NSMutableDictionary *parameters = [NSMutableDictionary
        dictionaryWithDictionary: [self dictionaryFromURLArguments: query]];
    
    // update specified parameter
    [parameters setObject: value
        forKey: key];
    
    // remove existing query from uri (if required)
    NSString *uri = url.absoluteString;
    if (query != nil
        && query.length > 0)
    {
        NSRange queryRange = [uri rangeOfString: query];
        uri = [uri substringToIndex: queryRange.location - 1];
    }

    // append new query to uri
    query = [self URLArgumentsFromDictionary: parameters];
    uri = [NSString stringWithFormat: @"%@?%@", uri, query];
    
    // update request
    request.URL = [NSURL URLWithString: uri];
}

+ (void)updateRequest: (NSMutableURLRequest *)request
    deleteParameter: (NSString *)key
{
}


@end  // @implementation DEServiceHelper
