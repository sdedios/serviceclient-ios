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

#import "DESecureServiceClient.h"


#pragma mark -
#pragma mark Class Definition

@implementation DESecureServiceClient


#pragma mark -
#pragma mark Public Methods

- (BOOL)requireValidCertificateForDomain: (NSString *)domain
{
    return YES;
}

- (NSURLCredential *)credentialForServiceOperation: (DEServiceOperation *)operation
    challenge: (NSURLAuthenticationChallenge *)challenge
{
    // handle whitelisted SSL challenges
    NSURLCredential *credential = nil;
    NSURLProtectionSpace *protectionSpace = challenge.protectionSpace;
    if ([protectionSpace.authenticationMethod 
            isEqualToString: NSURLAuthenticationMethodServerTrust]
        && [self requireValidCertificateForDomain: operation.request.URL.host] == NO)
    {
        credential = [NSURLCredential 
            credentialForTrust: challenge.protectionSpace.serverTrust];
    }
    
    // or use default handling
    else 
    {
        credential = [super credentialForServiceOperation: operation 
            challenge: challenge];
    }
    
    // return credential
    return credential;
}


@end  // @implementation DESecureServiceClient
