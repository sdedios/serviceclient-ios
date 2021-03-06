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
 
#import "DEDemosViewController.h"
#import "DEGithubViewController.h"
#import "DEMultipartViewController.h"
#import "DERetryViewController.h"


#pragma mark Class Extension

@interface DEDemosViewController ()
{
    @private __weak UITableView *_tableView;
}

@end  // @interface DEDemosViewController ()


#pragma mark -
#pragma mark Class Definition

@implementation DEDemosViewController


#pragma mark -
#pragma mark Properties

@synthesize tableView = _tableView;


#pragma mark -
#pragma mark Overridden Methods

- (void)viewDidLoad
{
    // call base implementation
    [super viewDidLoad];

    // set title
    self.title = @"ServiceClient Demos";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] 
        initWithTitle: @"Back" 
        style: UIBarButtonItemStylePlain 
        target: nil 
        action: nil];
}

- (void)viewDidUnload
{
    // call base implementation
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation
{
    return YES;
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
            cell.textLabel.text = @"Github Client";
            break;
            
        case 1:
            cell.textLabel.text = @"Multipart Post";
            break;
            
        case 2:
            cell.textLabel.text = @"Retry Test";
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
    // handle selection
    switch (indexPath.row)
    {            
        case 0:
        {
            // create controller
            DEGithubViewController *controller = 
                [[DEGithubViewController alloc]
                    initWithNibName: @"DEGithubView" 
                    bundle: nil];
                    
            // push onto navigation
            [self.navigationController pushViewController: controller 
                animated: YES];
            break;
        }

        case 1:
        {
            // create controller
            DEMultipartViewController *controller = 
                [[DEMultipartViewController alloc]
                    initWithNibName: @"DEMultipartView" 
                    bundle: nil];
                    
            // push onto navigation
            [self.navigationController pushViewController: controller 
                animated: YES];
            break;
        }

        case 2:
        {
            // create controller
            DERetryViewController *controller =
                [[DERetryViewController alloc]
                    initWithNibName: @"DERetryView" 
                    bundle: nil];
                    
            // push onto navigation
            [self.navigationController pushViewController: controller 
                animated: YES];
            break;
        }
    }

    // deselect row
    [tableView deselectRowAtIndexPath: indexPath 
        animated: YES];
}


@end   // @implementation DEDemosViewController
