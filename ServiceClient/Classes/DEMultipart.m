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
#import "DEMultipart_Internal.h"
#import "DEServiceHelper.h"


#pragma mark Class Extension

@interface DEMultipart()
{
    @private __strong NSString *_name;
    @private __strong NSString *_filename;
    @private __strong NSString *_contentType;
    @private NSData * (__strong ^_dataProvider)();
}
@end  // @interface DEMultipart()


#pragma mark -
#pragma mark Class Definition

@implementation DEMultipart


#pragma mark -
#pragma mark Properties

@synthesize name = _name;
@synthesize filename = _filename;
@synthesize contentType = _contentType;


#pragma mark -
#pragma mark Constructors

- (id)initWithString: (NSString *)string
    name: (NSString *)name
    contentType: (NSString *)contentType
{
    NSData *providerData = [string dataUsingEncoding: NSUTF8StringEncoding];
    return [self initWithDataProvider: ^NSData *
        {
            return providerData;
        } 
        name: name
        filename: nil
        contentType: contentType];
}

- (id)initWithData: (NSData *)data
    name: (NSString *)name
    contentType: (NSString *)contentType
{
    NSData *providerData = [data copy];
    return [self initWithDataProvider: ^NSData *
        {
            return providerData;
        } 
        name: name
        filename: nil
        contentType: contentType];
}

- (id)initWithContentsOfFile: (NSString *)path
    name: (NSString *)name
    filename: (NSString *)filename
    contentType: (NSString *)contentType
{
    NSString *providerDataPath = [path copy];
    return [self initWithDataProvider: ^NSData *
        {
            NSData *providerData = [NSData
                dataWithContentsOfFile: providerDataPath];
            return providerData;
        } 
        name: name
        filename: filename
        contentType: contentType];
}

- (id)initWithDataOfFile: (NSData *)data
    name: (NSString *)name
    filename: (NSString *)filename
    contentType: (NSString *)contentType
{
    NSData *providerData = [data copy];
    return [self initWithDataProvider: ^NSData *
        {
            return providerData;
        } 
        name: name
        filename: filename
        contentType: contentType];
}

- (id)initWithDataProvider: (NSData *(^)())dataProvider
    name: (NSString *)name
    filename: (NSString *)filename
    contentType: (NSString *)contentType
{
    // abort if allocation fails
    if ((self = [super init]) == nil)
    {
        return nil;
    }
    
    // initialize instance variables
    _name = [name copy];
    _filename = filename == nil ? nil : [filename copy];
    _contentType = [contentType copy];
    _dataProvider = [dataProvider copy];
    
    // return instance
    return self;
}


#pragma mark -
#pragma mark Public Methods

+ (DEMultipart *)multipartWithString: (NSString *)string
    name: (NSString *)name
    contentType: (NSString *)contentType
{
    DEMultipart *multipart = [[DEMultipart alloc]
        initWithString: string 
        name: name 
        contentType: contentType];
    return multipart;
}

+ (DEMultipart *)multipartWithData: (NSData *)data
    name: (NSString *)name
    contentType: (NSString *)contentType
{
    DEMultipart *multipart = [[DEMultipart alloc]
        initWithData: data
        name: name 
        contentType: contentType];
    return multipart;
}

+ (DEMultipart *)multipartWithDataOfFile: (NSData *)data
    name: (NSString *)name
    filename: (NSString *)filename
    contentType: (NSString *)contentType
{
    DEMultipart *multipart = [[DEMultipart alloc]
        initWithDataOfFile: data
        name: name
        filename: filename
        contentType: contentType];
    return multipart;
}

+ (DEMultipart *)multipartWithContentsOfFile: (NSString *)path
    name: (NSString *)name
    filename: (NSString *)filename
    contentType: (NSString *)contentType
{
    DEMultipart *multipart = [[DEMultipart alloc]
        initWithContentsOfFile: path
        name: name
        filename: filename
        contentType: contentType];
    return multipart;
}

+ (DEMultipart *)multipartWithDataProvider: (NSData *(^)())dataProvider
    name: (NSString *)name
    filename: (NSString *)filename
    contentType: (NSString *)contentType
{
    DEMultipart *multipart = [[DEMultipart alloc]
        initWithDataProvider: dataProvider
        name: name
        filename: filename
        contentType: contentType];
    return multipart;
}


#pragma mark -
#pragma mark Internal Methods

- (NSData *)data
{
    return _dataProvider == nil
        ? nil
        : _dataProvider();
}


@end  // @implementation DEMultipart
