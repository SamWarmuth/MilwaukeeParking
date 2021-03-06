//
//  SWAppDelegate.m
//  Milwaukee Parking
//
//  Created by Samuel Warmuth on 8/3/12.
//  Copyright (c) 2012 Samuel Warmuth. All rights reserved.
//

#import "SWAppDelegate.h"
#import "SWAddressMatcher.h"
#import <MapKit/MapKit.h>

@interface SWAppDelegate ()
@property(nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation SWAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.locationManager = [CLLocationManager new];
    [self.locationManager requestWhenInUseAuthorization];
    [self loadCars];
    [SWAddressMatcher loadStreetsFromServer];
    return YES;
}

- (void)saveCarsToDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *carData = [NSKeyedArchiver archivedDataWithRootObject:self.cars];
    [defaults setObject:carData forKey:@"SWNightParkingCarData"];
    [defaults synchronize];
}

- (void)loadCars
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *carData = [defaults objectForKey:@"SWNightParkingCarData"];
    if (!carData || carData == (id)[NSNull null]){
        NSLog(@"no car data found.");
        self.cars = [NSMutableArray array];
    } else {
        self.cars = (NSMutableArray *)[NSKeyedUnarchiver unarchiveObjectWithData:carData];
    }
}

- (SWCar *)findCarWithLicensePlate:(NSString *)licensePlate
{
    for (SWCar *car in self.cars){
        if ([car.licensePlateNumber isEqualToString:licensePlate]) return car;
    }
    return nil;
}


							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
