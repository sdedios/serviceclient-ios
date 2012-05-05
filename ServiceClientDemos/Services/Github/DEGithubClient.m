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
 
#import "DEGithubClient.h"
#import "DEGithubRepo.h"
#import "DENetworkIndicatorHelper.h"


#pragma mark Constants

static NSString * const DEGithubTokenKey = @"github.accessToken";

static NSString * const DEGithubUri = @"https://api.github.com";
static NSString * const DEGithubAuthorizePath = @"authorizations";
static NSString * const DEGithubReposPath = @"user/repos";



#pragma mark -
#pragma mark Internal Interface

@interface DEGithubClient ()
{
    @private __strong NSString *_accessToken;
}

#pragma mark -
#pragma mark Properties

@property (nonatomic, strong) NSString *persistedToken;


#pragma mark -
#pragma mark Methods

- (void)createAuthorization: (NSString *)authorizationId
    headers: (NSDictionary *)headers
    completion: (void (^)(DEServiceResult, NSInteger))completion;


@end  // @interface DEGithubClient ()


#pragma mark -
#pragma mark Class Definition

@implementation DEGithubClient


#pragma mark -
#pragma mark Properties

@synthesize accessToken = _accessToken;

@dynamic persistedToken;
- (NSString *)persistedToken
{
    // TODO: use keychain
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults stringForKey: DEGithubTokenKey];
}
- (void)setPersistedToken:(NSString *) persistedToken
{
    // TODO: use keychain
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue: persistedToken 
        forKey: DEGithubTokenKey];
    [userDefaults synchronize];
}


#pragma mark -
#pragma mark Constructors

- (id)initWithRequestQueue: (NSOperationQueue *)requestQueue
{
    // abort base constructor fails
    if ((self = [super initWithRequestQueue: requestQueue]) == nil)
    {
        return nil;
    }
    
    // initialize instance variables
    self.accessToken = self.persistedToken;    
    
    // return self
    return self;
}


#pragma mark -
#pragma mark Public Methods

- (void)loginWithUsername: (NSString *)username
    password: (NSString *)password
    completion: (void (^)(DEServiceResult, NSInteger))completion
{
    // clear previous token (if any)
    self.persistedToken = nil;
    self.accessToken = nil;

    // create request data
    NSDictionary *headers = [[NSDictionary alloc]
        initWithObjectsAndKeys:
            [NSString stringWithFormat: @"Basic %@",
                [DEServiceHelper base64EncodeString:
                    [NSString stringWithFormat: @"%@:%@", username, password]]],
                @"Authorization",
            @"application/json", @"Content-Type",
            @"application/json", @"Accept",
            nil];
            
    // send request to enumerate existing authorizations
    NSString *authorizationId = [NSString 
        stringWithFormat: @"http://dedios.org/%@",
            [NSBundle mainBundle].bundleIdentifier];
    NSString *endpoint = [[NSString alloc]
        initWithFormat: @"%@/%@", DEGithubUri, DEGithubAuthorizePath];
    [self beginRequestWithURL: endpoint
        method: DEServiceMethodGet
        headers: headers 
        parameters: nil 
        bodyData: nil
        format: DEServiceFormatJson 
        transform: ^id(NSHTTPURLResponse *response, id data) 
        {
            // find access token for authorization matching bundle
            NSString *accessToken = nil;
            for (NSDictionary *authorization in data) 
            {
                NSString *noteUrl = [authorization objectForKey: @"note_url"];
                if ([noteUrl isEqualToString: authorizationId] == YES)
                {
                    accessToken = [authorization objectForKey: @"token"];
                    break;
                }
            }
            
            // return token
            return accessToken;
        } 
        completion: ^(DEServiceResult result, NSHTTPURLResponse *response, 
            id accessToken) 
        {
            // handle success
            if (accessToken != nil
                && [[NSNull null] isEqual: accessToken] == NO)
            {
                // persist token locally
                self.accessToken = accessToken;
                
                // persist token
                self.persistedToken = accessToken;
            
                // callback completion (if any)
                if (completion != nil)
                {
                    completion(result, response.statusCode);
                }
            }
            
            // or try to create token
            else 
            {
                [self createAuthorization: authorizationId 
                    headers: headers 
                    completion: completion];
            }
        }         
        context: nil];
}

- (void)logout
{
    self.accessToken = nil;
    self.persistedToken = nil;
}

- (void)getReposWithCompletion: (void (^)(DEServiceResult, NSInteger, NSArray *))completion
{
    // create request data
    NSDictionary *parameters = [[NSDictionary alloc]
        initWithObjectsAndKeys:
            _accessToken, @"access_token",
            @"all", @"type",
            nil];            
    NSDictionary *headers = [[NSDictionary alloc]
        initWithObjectsAndKeys:
            @"application/json", @"Accept",
            nil];
            
    // send request
    NSString *endpoint = [[NSString alloc]
        initWithFormat: @"%@/%@", DEGithubUri, DEGithubReposPath];
    [self beginRequestWithURL: endpoint
        method: DEServiceMethodGet 
        headers: headers 
        parameters: parameters 
        bodyData: nil
        format: DEServiceFormatJson 
        transform: ^id(NSHTTPURLResponse *response, id reposData) 
        {
            // allocate repo array
            NSUInteger reposCount = [reposData count];
            NSMutableArray *repos = [[NSMutableArray alloc]
                initWithCapacity: MAX(1, reposCount)];
                
            // convert repos
            for (NSDictionary *repoData in reposData) 
            {
                // create repo
                DEGithubRepo *repo = [[DEGithubRepo alloc]
                    init];
                repo.name = [repoData objectForKey: @"name"];
                repo.desc = [repoData objectForKey: @"description"];
                
                // add to array
                [repos addObject: repo];
            }
            
            // return array
            return repos;
        } 
        completion: ^(DEServiceResult result, NSHTTPURLResponse *response, 
            id repos) 
        {
            // callback completion (if any)
            if (completion != nil)
            {
                completion(result, response.statusCode, repos);
            }
        }         
        context: nil];
}


#pragma mark -
#pragma mark Overridden Methods

- (void)serviceOperationDidBegin: (DEServiceOperation *)operation
{
    [DENetworkIndicatorHelper networkOperationBegin];
}

- (void)serviceOperationDidEnd: (DEServiceOperation *)operation
{
    [DENetworkIndicatorHelper networkOperationEnd];
}


#pragma mark -
#pragma mark Private Methods

- (void)createAuthorization: (NSString *)authorizationId
    headers: (NSDictionary *)headers
    completion: (void (^)(DEServiceResult, NSInteger))completion
{
    // create request data
    NSArray *scopes = [[NSArray alloc]
        initWithObjects:
            @"repo",
            nil];
    NSDictionary *body = [[NSDictionary alloc]
        initWithObjectsAndKeys:
            scopes, @"scopes",
            @"DEServiceClient demo app", @"note",
            authorizationId, @"note_url",
            nil];            
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject: body 
        options: 0 
        error: NULL];
        
    // send request to enumerate existing authorizations
    NSString *endpoint = [[NSString alloc]
        initWithFormat: @"%@/%@", DEGithubUri, DEGithubAuthorizePath];
    [self beginRequestWithURL: endpoint
        method: DEServiceMethodPost 
        headers: headers 
        parameters: nil 
        bodyData: bodyData
        format: DEServiceFormatJson 
        transform: ^id(NSHTTPURLResponse *response, id data) 
        {
            // extract token
            NSString *accessToken = [data objectForKey: @"token"];
            
            // return token
            return accessToken;
        } 
        completion: ^(DEServiceResult result, NSHTTPURLResponse *response, 
            id accessToken) 
        {
            // set token on success
            NSInteger statusCode = response.statusCode;
            if (result == DEServiceResultSuccess
                && (statusCode / 100) == 2)
            {
                // persist token locally
                self.accessToken = accessToken;
                
                // persist token
                self.persistedToken = accessToken;
            }
            
            // callback completion (if any)
            if (completion != nil)
            {
                completion(result, statusCode);
            }
        }         
        context: nil];
}


@end  // @interface DEGithubClient