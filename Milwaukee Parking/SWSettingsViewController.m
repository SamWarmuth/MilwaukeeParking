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
    self.navigationController.navigationBar.translucent = NO;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.emailSwitch.on = [defaults boolForKey:@"SWSendEmailConfirmation"];
    self.emailField.text = (NSString *)[defaults objectForKey:@"SWEmail"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleEmailSwitchIfEmailExists) name:UITextFieldTextDidChangeNotification object:self.emailField];
}

- (IBAction)cancel:(id)sender
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender
{
    if (self.emailSwitch.isOn && self.emailField.text.length == 0){
        [SVProgressHUD show];
        [SVProgressHUD dismissWithError:@"Please enter an email address, or turn off email confirmation." afterDelay:3.0];
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:self.emailSwitch.isOn forKey:@"SWSendEmailConfirmation"];
    [defaults setObject:self.emailField.text forKey:@"SWEmail"];

    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@" "]) return FALSE;
    return TRUE;
}

- (void)toggleEmailSwitchIfEmailExists
{
    if (self.emailField.text.length != 0) [self.emailSwitch setOn:TRUE animated:TRUE];
    else [self.emailSwitch setOn:FALSE animated:TRUE];
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
