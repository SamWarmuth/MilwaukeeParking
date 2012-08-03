//
//  SWAppDelegate.h
//  Milwaukee Parking
//
//  Created by Samuel Warmuth on 8/3/12.
//  Copyright (c) 2012 Samuel Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (NSMutableArray *)cars;
- (void)addCar:(NSDictionary *)car;

@end
