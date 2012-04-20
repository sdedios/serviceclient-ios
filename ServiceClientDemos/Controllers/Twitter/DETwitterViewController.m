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
 
#import "DETwitterViewController.h"


#pragma mark Constants

//static NSString * const SomeString = @"";
//#define SomeContant 1.0


#pragma mark -
#pragma mark Internal Interface

@interface DETwitterViewController ()

@end  // @interface DETwitterViewController ()


#pragma mark -
#pragma mark Class Definition

@implementation DETwitterViewController


#pragma mark -
#pragma mark Properties

@synthesize tableView = _tableView;


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
    self.title = @"Twitter Client";
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
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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


@end  // @interface DETwitterViewController