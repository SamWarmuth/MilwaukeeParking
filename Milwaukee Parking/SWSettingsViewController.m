//
//  SWSettingsViewController.m
//  Milwaukee Parking
//
//  Created by Samuel Warmuth on 8/24/12.
//  Copyright (c) 2012 Samuel Warmuth. All rights reserved.
//

#import "SWSettingsViewController.h"

@interface SWSettingsViewController ()

@end

@implementation SWSettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.emailSwitch.on = [defaults boolForKey:@"SWSendEmailConfirmation"];
    self.emailField.text = (NSString *)[defaults objectForKey:@"SWEmail"];
}

- (IBAction)cancel:(id)sender
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:self.emailSwitch.isOn forKey:@"SWSendEmailConfirmation"];
    [defaults setObject:self.emailField.text forKey:@"SWEmail"];

    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
