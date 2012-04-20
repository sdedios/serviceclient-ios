//
//  DEViewController.m
//  ServiceClientDemo
//
//  Created by Simeon de Dios on 12-04-19.
//  Copyright (c) 2012 Nascent Digital. All rights reserved.
//

#import "DEViewController.h"

@interface DEViewController ()

@end

@implementation DEViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
