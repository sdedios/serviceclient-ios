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

#import "DEServiceClient.h"
 
 
#pragma mark Class Declaration
 
@interface DEGithubClient : DEServiceClient

#pragma mark -
#pragma mark Properties

@property (nonatomic, copy) NSString *accessToken;


#pragma mark -
#pragma mark Methods

- (void)loginWithUsername: (NSString *)username
    password: (NSString *)password
    completion: (void (^)(DEServiceResult result, NSInteger statusCode))completion;

- (void)getReposWithCompletion: (void (^)(DEServiceResult result, NSArray *repos))completion;

@end  // @interface DEGithubClient