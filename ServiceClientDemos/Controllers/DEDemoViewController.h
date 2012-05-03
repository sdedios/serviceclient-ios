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
 
#pragma mark Class Declaration
 
@interface DEDemoViewController : UIViewController

#pragma mark -
#pragma mark Properties

@property (nonatomic, weak) IBOutlet UIView *messagePanel;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *messageIndicator;


#pragma mark -
#pragma mark Methods

- (IBAction)dismissErrorMessage;

- (void)showProgressMessage: (NSString *)message
    animated: (BOOL)animated;

- (void)showErrorMessage: (NSString *)message
    animated: (BOOL)animated;

- (void)showErrorMessage:(NSString *)message
    withDetails: (NSString *)messageDetails
    animated: (BOOL)animated;

- (void)hideMessage: (BOOL)animated;


@end  // @interface DEDemoViewController
