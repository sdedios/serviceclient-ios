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
#import "DEGithubClient.h"
#import "DEGithubRepo.h"


#pragma mark Class Extension

@interface DEGithubViewController ()
{
    @private __weak UITableView *_tableView;
    @private __weak UIView *_loginPanel;
    @private __weak UITextField *_usernameField;
    @private __weak UITextField *_passwordField;
    @private __weak UIView *_messagePanel;
    @private __weak UILabel *_messageLabel;
    @private __weak UITextField *_firstResponder;
    
    @private __strong DEGithubClient *_githubClient;
    @private __strong NSMutableArray *_repos;
}

#pragma mark -
#pragma mark Methods

- (void)refreshRepos;


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
	
	// initialize instance variables
    _githubClient = [[DEGithubClient alloc]
        init];
    _repos = [[NSMutableArray alloc]
        initWithCapacity: 10];
	
    return self;
}

#pragma mark -
#pragma mark Public Methods

- (IBAction)login
{
    // show message
    _messageLabel.text = @"Logging into Github...";
    _messagePanel.hidden = NO;
    
    // TODO: validate crendentials
    NSString *username = _usernameField.text;
    NSString *password = _passwordField.text;
    
    // login with client
    [_githubClient loginWithUsername: username 
        password: password 
        completion: ^(DEServiceResult result, NSInteger statusCode) 
        {
            // handle success
            NSInteger statusFamily = statusCode / 100;
            if (result == DEServiceResultSuccess
                && statusFamily == 2)
            {
                // hide message and login
                _messagePanel.hidden = YES;
                _loginPanel.hidden = YES;
                
                // load repos
                [self refreshRepos];
            }
            
            // github uses 400-series for invalid creds
            else if (statusFamily == 4)
            {
                _messageLabel.text = @"Invalid username or password.";
            }
            
            // handle service unavailable
            else if (statusFamily == 5)
            {
                _messageLabel.text = @"The server is currently unavailable, please try again later.";
            }
            
            // handle unexpected error
            else 
            {
                _messageLabel.text = @"An unexpected error occurred.";
            }
        }];
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
    NSString *accessToken = _githubClient.accessToken;
    if (accessToken == nil
        || [[NSNull null] isEqual: accessToken] == YES)
    {
        _loginPanel.hidden = NO;
        _usernameField.text = @"sdedios";
    }
    
    // otherwise, load repos
    else 
    {
       [self refreshRepos];
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
#pragma mark Private Methods

- (void)refreshRepos
{
    // show message
    _messageLabel.text = @"Fetching repos...";
    _messagePanel.hidden = NO;

    // request repos
    [_githubClient getReposWithCompletion:^(DEServiceResult result, 
        NSArray *repos) 
    {
        // repopulate repos
        [_repos removeAllObjects];
        [_repos addObjectsFromArray: repos];
        
        // refresh table
        [_tableView reloadData];

        // hide message
        _messagePanel.hidden = YES;
    }];
}


#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)tableView: (UITableView *)tableView 
    numberOfRowsInSection: (NSInteger)section
{
    return [_repos count];
}

- (UITableViewCell *)tableView: (UITableView *)tableView 
    cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    // reuse cell if possible (or create one)
    static NSString *cellIdentifier = @"repo";
    UITableViewCell *cell = [tableView 
        dequeueReusableCellWithIdentifier: cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]
            initWithStyle: UITableViewCellStyleSubtitle 
            reuseIdentifier: cellIdentifier];
    }

    // fetch entity
    DEGithubRepo *repo = [_repos objectAtIndex: indexPath.row];
    cell.textLabel.text = repo.name;
    cell.detailTextLabel.text = repo.desc;

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