//
//  SWSettingsViewController.h
//  Milwaukee Parking
//
//  Created by Samuel Warmuth on 8/24/12.
//  Copyright (c) 2012 Samuel Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWSettingsViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *emailField;
@property (nonatomic, strong) IBOutlet UISwitch *emailSwitch;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@end
