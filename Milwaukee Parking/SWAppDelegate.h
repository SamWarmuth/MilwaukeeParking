//
//  SWAppDelegate.h
//  Milwaukee Parking
//
//  Created by Samuel Warmuth on 8/3/12.
//  Copyright (c) 2012 Samuel Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWCar.h"

@interface SWAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableArray *cars;

- (void)saveCarsToDefaults;
- (SWCar *)findCarWithLicensePlate:(NSString *)licensePlate;

@end
