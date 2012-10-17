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

@interface DEMultipart : NSObject


#pragma mark -
#pragma mark Properties

@property (nonatomic, readonly) NSString *name;

@property (nonatomic, readonly) NSString *filename;

@property (nonatomic, readonly) NSString *contentType;


#pragma mark -
#pragma mark Constructors

- (id)initWithString: (NSString *)string
    name: (NSString *)name
    contentType: (NSString *)contentType;

- (id)initWithData: (NSData *)data
    name: (NSString *)name
    contentType: (NSString *)contentType;

- (id)initWithDataOfFile: (NSData *)data
    name: (NSString *)name
    filename: (NSString *)filename
    contentType: (NSString *)contentType;

- (id)initWithContentsOfFile: (NSString *)path
    name: (NSString *)name
    filename: (NSString *)filename
    contentType: (NSString *)contentType;

- (id)initWithDataProvider: (NSData *(^)())dataProvider
    name: (NSString *)name
    filename: (NSString *)filename
    contentType: (NSString *)contentType;

#pragma mark -
#pragma mark Static Methods

+ (DEMultipart *)multipartWithString: (NSString *)string
    name: (NSString *)name
    contentType: (NSString *)contentType;

+ (DEMultipart *)multipartWithData: (NSData *)data
    name: (NSString *)name
    contentType: (NSString *)contentType;

+ (DEMultipart *)multipartWithDataOfFile: (NSData *)data
    name: (NSString *)name
    filename: (NSString *)filename
    contentType: (NSString *)contentType;

+ (DEMultipart *)multipartWithContentsOfFile: (NSString *)path
    name: (NSString *)name
    filename: (NSString *)filename
    contentType: (NSString *)contentType;

+ (DEMultipart *)multipartWithDataProvider: (NSData *(^)())dataProvider
    name: (NSString *)name
    filename: (NSString *)filename
    contentType: (NSString *)contentType;


@end  // @interface DEMultipart
