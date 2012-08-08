//
//  SWCarHistoryViewController.m
//  Milwaukee Parking
//
//  Created by Samuel Warmuth on 8/8/12.
//  Copyright (c) 2012 Samuel Warmuth. All rights reserved.
//

#import "SWCarHistoryViewController.h"

@interface SWCarHistoryViewController ()

@end

@implementation SWCarHistoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
