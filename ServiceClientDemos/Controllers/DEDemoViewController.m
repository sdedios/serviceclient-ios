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
 
#import "DEDemoViewController.h"


#pragma mark Class Extension

@interface DEDemoViewController ()
{
    @private __weak UIView *_messagePanel;
    @private __weak UILabel *_messageLabel;
    @private __weak UIActivityIndicatorView *_messageIndicator;
}

@end  // @interface DEDemoViewController ()


#pragma mark -
#pragma mark Class Definition

@implementation DEDemoViewController


#pragma mark -
#pragma mark Properties

@synthesize messageLabel = _messageLabel;
@synthesize messagePanel = _messagePanel;
@synthesize messageIndicator = _messageIndicator;


#pragma mark -
#pragma mark Public Methods

- (IBAction)dismissErrorMessage
{
    if (_messagePanel.hidden == NO
        && _messagePanel.userInteractionEnabled == YES)
    {
        [self hideMessage: YES];
    }
}

- (void)showProgressMessage: (NSString *)message
    animated: (BOOL)animated
{
    // initialize panel
    BOOL wasHidden = _messagePanel.hidden;
    _messagePanel.hidden = NO;
    _messagePanel.userInteractionEnabled = NO;
    _messageLabel.text = message;
    _messageIndicator.hidden = NO;

    // animate (if required)
    if (animated
        && wasHidden)
    {
        _messagePanel.alpha = 0.f;
        [UIView animateWithDuration: 0.5 
            animations: ^
            {
                _messagePanel.alpha = 1.f;
            }];
    }
}

- (void)showErrorMessage: (NSString *)message
    animated: (BOOL)animated
{
    // initialize panel
    BOOL wasHidden = _messagePanel.hidden;
    _messagePanel.hidden = NO;
    _messagePanel.userInteractionEnabled = YES;
    _messageLabel.text = message;
    _messageIndicator.hidden = YES;

    // animate (if required)
    if (animated
        && wasHidden)
    {
        _messagePanel.alpha = 0.f;
        [UIView animateWithDuration: 0.5 
            animations: ^
            {
                _messagePanel.alpha = 1.f;
            }];
    }
}

- (void)showErrorMessage:(NSString *)message
    withDetails: (NSString *)messageDetails
    animated: (BOOL)animated
{
    // initialize panel
    BOOL wasHidden = _messagePanel.hidden;
    _messagePanel.hidden = NO;
    _messagePanel.userInteractionEnabled = YES;
    _messageLabel.text = message;
    _messageIndicator.hidden = YES;

    // animate (if required)
    if (animated
        && wasHidden)
    {
        _messagePanel.alpha = 0.f;
        [UIView animateWithDuration: 0.5 
            animations: ^
            {
                _messagePanel.alpha = 1.f;
            }];
    }
}

- (void)hideMessage: (BOOL)animated
{
    // hide immediately
    if (animated == NO
        || _messagePanel.hidden == YES)
    {
        _messagePanel.hidden = YES;
    }
    
    // or hide with animation
    else 
    {
        [UIView animateWithDuration: 0.5 
            animations: ^
            {
                _messagePanel.alpha = 0.f;
            } 
            completion: ^(BOOL finished) 
            {
                if (finished)
                {
                    _messagePanel.hidden = YES;
                    _messagePanel.alpha = 1.f;
                }
            }];
    }
}


#pragma mark -
#pragma mark Overridden Methods

- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end   // @implementation DEDemoViewController
