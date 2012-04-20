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


#pragma Class Definition

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


@end  // @implementation DEServiceHelper
