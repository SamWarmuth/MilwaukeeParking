//
//  SWNewCarViewController.h
//  Milwaukee Parking
//
//  Created by Samuel Warmuth on 8/3/12.
//  Copyright (c) 2012 Samuel Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWCar.h"
#import "SWNewRequestViewController.h"

@interface SWNewCarViewController : UIViewController

@property (nonatomic, strong) SWCar *car;

@property (nonatomic, strong) IBOutlet UITextField *nicknameField, *licensePlateField;
@property (nonatomic, strong) IBOutlet UIButton *stateButton;
@property (nonatomic, strong) IBOutlet UISegmentedControl *vehicleTypeSegControl;


- (IBAction)tappedStateButton:(id)sender;
- (IBAction)tappedDoneButton:(id)sender;

@end
