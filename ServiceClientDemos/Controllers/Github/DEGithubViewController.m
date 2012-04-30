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
 
#import "DEGithubViewController.h"


#pragma mark Constants

//static NSString * const SomeString = @"";
//#define SomeContant 1.0


#pragma mark -
#pragma mark Internal Interface

@interface DEGithubViewController ()
{
    @private __weak UITableView *_tableView;
    @private __weak UIView *_loginPanel;
    @private __weak UITextField *_usernameField;
    @private __weak UITextField *_passwordField;
    @private __weak UIView *_messagePanel;
    @private __weak UILabel *_messageLabel;
    @private __weak UITextField *_firstResponder;
}

@end  // @interface DEGithubViewController ()


#pragma mark -
#pragma mark Class Definition

@implementation DEGithubViewController


#pragma mark -
#pragma mark Properties

@synthesize tableView = _tableView;
@synthesize loginPanel = _loginPanel;
@synthesize usernameField = _usernameField;
@synthesize passwordField = _passwordField;
@synthesize messagePanel = _messagePanel;
@synthesize messageLabel = _messageLabel;


#pragma mark -
#pragma mark Constructors

- (id)initWithNibName: (NSString *)nibNameOrNil 
	bundle: (NSBundle *)nibBundleOrNil
{
    // abort if base initializer fails
    if ((self = [super initWithNibName: nibNameOrNil 
		bundle: nibBundleOrNil]) == nil)
	{
		return nil;
    }
	
	// TODO: initialize instance variables
	
    return self;
}

#pragma mark -
#pragma mark Public Methods

- (IBAction)login
{
    // show message
    _messageLabel.text = @"Logging into Github...";
    _messagePanel.hidden = NO;
}

- (IBAction)resignResponder
{
    [_firstResponder resignFirstResponder];
}


#pragma mark -
#pragma mark Overridden Methods

- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
    {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } 
    else 
    {
        return YES;
    }
}

- (void)viewDidLoad 
{
	// call base implementation
    [super viewDidLoad];
	
	// set title
    self.title = @"Github Client";
    
    // show login if not authenticated
    if (YES)
    {
        _loginPanel.hidden = NO;
    }
}

- (void)viewWillAppear: (BOOL)animated
{
	// call base implementation
	[super viewWillAppear: animated];

	// TODO: prepare controls before display
}

- (void)viewWillDisappear: (BOOL)animated
{
	// call base implementation
	[super viewWillDisappear: animated];

	// TODO: prepare controls before hiding
}

- (void)viewDidUnload 
{
	// call base implementation
    [super viewDidUnload];
}


#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)tableView: (UITableView *)tableView 
    numberOfRowsInSection: (NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView: (UITableView *)tableView 
    cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    // reuse cell if possible (or create one)
    static NSString *cellIdentifier = @"link";
    UITableViewCell *cell = [tableView 
        dequeueReusableCellWithIdentifier: cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]
            initWithStyle: UITableViewCellStyleDefault 
            reuseIdentifier: cellIdentifier];
    }
    
    // initialize cell
    switch (indexPath.row)
    {
        case 0:
            cell.textLabel.text = @"Twitter Client";
            break;
            
        case 1:
            cell.textLabel.text = @"QR Code Client";
            break;
            
        case 2:
            cell.textLabel.text = @"Random Client";
            break;
    }
    
    // return cell
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate Methods

- (void)tableView: (UITableView *)tableView 
    didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath 
        animated: YES];
}


#pragma mark -
#pragma mark UITextFieldDelegate Methods

- (void)textFieldDidBeginEditing: (UITextField *)textField
{
    _firstResponder = textField;
}

- (void)textFieldDidEndEditing: (UITextField *)textField
{
    _firstResponder = nil;
}

- (BOOL)textFieldShouldReturn: (UITextField *)textField
{
    if (textField == _usernameField)
    {
        [_passwordField becomeFirstResponder];
    }
    else if (textField == _passwordField)
    {
        // release keyboard focus
        [_passwordField resignFirstResponder];
        
        // login
        [self login];
    }
    
    return YES;
}


@end  // @interface DEGithubViewController