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

#import "DEMultipartViewController.h"
#import "DEServiceClient.h"


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

@interface DEMultipartViewController ()
{
    @private __weak UITableView *_tableView;
    @private __weak UIView *_addPartView;
    @private __weak UITextField *_partNameField;
    @private __weak UITextField *_partValueField;
    @private __weak UIButton *_partSubmitButton;
    @private __weak UIBarButtonItem *_postButton;
    
    @private __strong NSMutableArray *_parts;
}

#pragma mark -
#pragma mark Properties

@property (nonatomic, weak) IBOutlet UIView *addPartView;
@property (nonatomic, weak) IBOutlet UITextField *partNameField;
@property (nonatomic, weak) IBOutlet UITextField *partValueField;
@property (nonatomic, weak) IBOutlet UIButton *partSubmitButton;


#pragma mark -
#pragma mark Methods

- (IBAction)addFilePart;
- (IBAction)addTextPart;
- (IBAction)addPartChanged;
- (IBAction)addPartSubmit;
- (IBAction)addPartCancel;
- (void)postParts;

@end  // @interface DEMultipartViewController ()


#pragma mark -
#pragma mark Class Definition

@implementation DEMultipartViewController


#pragma mark -
#pragma mark Properties

@synthesize tableView = _tableView;
@synthesize addPartView = _addPartView;
@synthesize partNameField = _partNameField;
@synthesize partValueField = _partValueField;
@synthesize partSubmitButton = _partSubmitButton;


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
    _parts = [[NSMutableArray alloc]
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
    self.title = @"Multipart Post";
    
    // add navigation button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
        initWithTitle: @"Post"
        style: UIBarButtonItemStyleDone
        target: self
        action: @selector(postParts)];
    _postButton = self.navigationItem.rightBarButtonItem;
    _postButton.tintColor = [UIColor colorWithRed: 0.95f
        green: 0.81f
        blue: 0.03f
        alpha: 1.f];
    _postButton.enabled = NO;
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

- (IBAction)addFilePart
{
    // create image picker
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]
        init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePicker.modalPresentationStyle = UIModalPresentationFormSheet;
    imagePicker.allowsEditing = YES;
    imagePicker.delegate = self;
    
    // present
    [self presentViewController: imagePicker
        animated: YES
        completion: ^
        {
            
        }];
}

- (IBAction)addTextPart
{
    // reset form
    _partNameField.text = nil;
    _partValueField.text = nil;
    _partSubmitButton.enabled = NO;
    
    // show view
    _addPartView.hidden = NO;    
}

- (IBAction)addPartChanged
{
    _partSubmitButton.enabled = [_partNameField.text length] > 0
        && [_partValueField.text length] > 0;
}

- (IBAction)addPartSubmit
{
    // hide keyboard
    [_partNameField resignFirstResponder];
    [_partValueField resignFirstResponder];

    // hide view
    _addPartView.hidden = YES;
    
    // add part to table
    [_tableView beginUpdates];
    [_parts addObject: [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInt: PART_TYPE_TEXT], PartTypeKey,
        _partNameField.text, PartNameKey,
        _partValueField.text, PartValueKey,
        nil]];
    [_tableView
        insertRowsAtIndexPaths: [NSArray arrayWithObjects:
            [NSIndexPath indexPathForRow: [_parts count] - 1
                inSection: 0],
            nil]
        withRowAnimation: UITableViewRowAnimationTop];
    [_tableView endUpdates];
    
    // enable post button
    _postButton.enabled = YES;
}

- (IBAction)addPartCancel
{
    // hide keyboard
    [_partNameField resignFirstResponder];
    [_partValueField resignFirstResponder];

    // hide view
    _addPartView.hidden = YES;
}

- (void)postParts
{
    [self showProgressMessage: @"Uploading post data..."
        animated: YES];

    // create part collection
    NSMutableArray *parts = [[NSMutableArray alloc]
        init];
    for (NSDictionary *part in _parts)
    {
        switch ([[part objectForKey: PartTypeKey] intValue])
        {
            case PART_TYPE_TEXT:
            {
                [parts
                    addObject: [DEMultipart
                        multipartWithString: [part objectForKey: PartValueKey]
                        name: [part objectForKey: PartNameKey]
                        contentType: @"text/plain"]];
                break;
            }
            
            case PART_TYPE_FILE:
            {
                UIImage *image = [part objectForKey: PartValueKey];
                NSData *imageData = UIImageJPEGRepresentation(image, 0.92f);
                [parts
                    addObject: [DEMultipart
                        multipartWithDataOfFile: imageData
                        name: [part objectForKey: PartNameKey]
                        filename: [part objectForKey: PartNameKey]
                        contentType: @"image/jpeg"]];
                break;
            }
        }
    }

    // post request
    DEServiceClient *client = [[DEServiceClient alloc]
        init];
    [client beginRequestWithURL: MultipartTestUrl
        method: DEServiceMethodPost
        headers: nil
        parameters: nil
        parts: [[DEMultipartCollection alloc]
            initWithPartArray: parts]
        format: DEServiceFormatString
        transform: nil
        completion:
            ^(DEServiceResult result, NSHTTPURLResponse *response, id data)
            {
                NSString *message = result == DEServiceResultSuccess
                    ? @"Request successful"
                    : @"Request failed";
                [self showErrorMessage: message
                    withDetails: data
                    animated: YES];
            }
        queuePriority: NSOperationQueuePriorityNormal
        dispatchPriority: DISPATCH_QUEUE_PRIORITY_DEFAULT
        cachePolicy: NSURLRequestReloadIgnoringCacheData
        context: nil];
}


#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)tableView: (UITableView *)tableView 
    numberOfRowsInSection: (NSInteger)section
{
    return [_parts count];
}

- (UITableViewCell *)tableView: (UITableView *)tableView 
    cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    // reuse cell if possible (or create one)
    static NSString *cellIdentifier = @"tweet";
    UITableViewCell *cell = [tableView 
        dequeueReusableCellWithIdentifier: cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]
            initWithStyle: UITableViewCellStyleSubtitle 
            reuseIdentifier: cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // initialize cell
    NSDictionary *part = [_parts objectAtIndex: indexPath.row];
    if ([[part objectForKey: PartTypeKey] intValue] == PART_TYPE_TEXT)
    {
        cell.textLabel.text = [part objectForKey: PartNameKey];
        cell.detailTextLabel.text = [part objectForKey: PartValueKey];
    }
    else
    {
        UIImage *image = [part objectForKey: PartValueKey];
        CGSize imageSize = image.size;
        cell.textLabel.text = [NSString stringWithFormat: @"%.0fx%.0f image",
            imageSize.width, imageSize.height];
        cell.detailTextLabel.text = @"file";
    }
    
    // return cell
    return cell;
}

- (void)tableView: (UITableView *)tableView
    commitEditingStyle: (UITableViewCellEditingStyle)editingStyle
    forRowAtIndexPath: (NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // delete row
        [tableView beginUpdates];
        [_parts removeObjectAtIndex: indexPath.row];
        [tableView deleteRowsAtIndexPaths: [NSArray arrayWithObject: indexPath]
            withRowAnimation: UITableViewRowAnimationFade];
        [tableView endUpdates];
        
        // disable posting if no parts left
        if ([_parts count] == 0)
        {
            _postButton.enabled = NO;
        }
    }
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
#pragma mark UIImagePickerControllerDelegate Methods

- (void)imagePickerController: (UIImagePickerController *)picker
    didFinishPickingMediaWithInfo: (NSDictionary *)info
{
    // hide modal
    [self dismissModalViewControllerAnimated: YES];

    // determine file index
    NSUInteger fileIndex = 1;
    for (NSDictionary *part in _parts)
    {
        if ([[part objectForKey: PartTypeKey] intValue] == PART_TYPE_FILE)
        {
            ++fileIndex;
        }
    }

    // add part to table
    [_tableView beginUpdates];
    [_parts addObject: [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInt: PART_TYPE_FILE], PartTypeKey,
        [NSString stringWithFormat: @"file%02d.jpg", fileIndex], PartNameKey,
        [info objectForKey: UIImagePickerControllerEditedImage], PartValueKey,
        nil]];
    [_tableView
        insertRowsAtIndexPaths: [NSArray arrayWithObjects:
            [NSIndexPath indexPathForRow: [_parts count] - 1
                inSection: 0],
            nil]
        withRowAnimation: UITableViewRowAnimationTop];
    [_tableView endUpdates];
    
    // enable post button
    _postButton.enabled = YES;
}

- (void)imagePickerControllerDidCancel: (UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated: YES];
}

@end  // @interface DEMultipartViewController