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

#import "DERetryViewController.h"
#import "DERetryClient.h"


#pragma mark Constants

// TODO: update this to your test URL
static NSString * const MultipartTestUrl = @"http://localhost/~sdedios/upload.php";
static NSString * const PartTypeKey = @"partType";
static NSString * const PartNameKey = @"partName";
static NSString * const PartValueKey = @"partValue";
static NSString * const PartFilenameKey = @"partFilename";

#define PART_TYPE_TEXT  1
#define PART_TYPE_FILE  2


#pragma mark -
#pragma mark Class Extension

@interface DERetryViewController ()
{
    @private __strong DERetryClient *_retryClient;
    @private __weak UITextField *_tokenField;
    @private __weak UITextView *_messageField;
    @private __weak UIImageView *_photo;
}

#pragma mark -
#pragma mark Properties

@property (nonatomic, weak) IBOutlet UITextField *tokenField;
@property (nonatomic, weak) IBOutlet UITextView *messageField;
@property (nonatomic, weak) IBOutlet UIImageView *photo;


#pragma mark -
#pragma mark Methods

- (void)refresh;
- (IBAction)login;

@end  // @interface DERetryViewController ()


#pragma mark -
#pragma mark Class Definition

@implementation DERetryViewController


#pragma mark -
#pragma mark Properties

@synthesize tokenField = _tokenField;
@synthesize messageField = _messageField;


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
    _retryClient = [[DERetryClient alloc]
        init];
	
    // return instance
    return self;
}

#pragma mark -
#pragma mark Public Methods

#pragma mark -
#pragma mark Overridden Methods

- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewDidLoad 
{
	// call base implementation
    [super viewDidLoad];
	
	// set title
    self.title = @"Retry Test";
    
    // add navigation button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
        initWithTitle: @"Post"
        style: UIBarButtonItemStyleDone
        target: self
        action: @selector(refresh)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor
        colorWithRed: 0.95f
        green: 0.81f
        blue: 0.03f
        alpha: 1.f];
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
#pragma mark Helper Methods

- (void)refresh
{
    // ensure keyboard is dismissed
    [_tokenField resignFirstResponder];
    
    // update access token
    _retryClient.accessToken = _tokenField.text;
    
    // send request
    [_retryClient testWithCompletion:
        ^(DEServiceResult result, NSInteger statusCode, NSString *message)
        {
            _messageField.text = message;
        }];
}

- (IBAction)login
{
    _messageField.text = @"It worked!";
}

#pragma mark -
#pragma mark UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn: (UITextField *)textField
{
    [textField resignFirstResponder];
    
    return NO;
}


@end  // @interface DERetryViewController