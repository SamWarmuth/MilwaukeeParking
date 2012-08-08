//
//  SWRequestCompletedViewController.h
//  Milwaukee Parking
//
//  Created by Samuel Warmuth on 8/3/12.
//  Copyright (c) 2012 Samuel Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWCar.h"
#import "SWRequest.h"
#import <MapKit/MapKit.h>

@interface SWRequestCompletedViewController : UIViewController

@property (nonatomic, strong) SWCar *car;
@property (nonatomic, strong) SWRequest *request;

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UILabel *carNameLabel, *addressLabel, *dateLabel, *confirmationLabel;

- (IBAction)tappedDoneButton:(id)sender;

@end
