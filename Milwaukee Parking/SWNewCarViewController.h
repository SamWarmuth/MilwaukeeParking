//
//  SWNewCarViewController.h
//  Milwaukee Parking
//
//  Created by Samuel Warmuth on 8/3/12.
//  Copyright (c) 2012 Samuel Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWNewCarViewController : UIViewController

@property (nonatomic, strong) NSString *state, *vehicleType;
@property (nonatomic, strong) IBOutlet UITextField *nicknameField, *licensePlateField;

- (IBAction)tappedStateButton:(id)sender;
- (IBAction)changedVehicleType:(id)sender;

@end
