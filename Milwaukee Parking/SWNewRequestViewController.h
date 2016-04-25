//
//  SWNewRequestViewController.h
//  Milwaukee Parking
//
//  Created by Samuel Warmuth on 8/3/12.
//  Copyright (c) 2012 Samuel Warmuth. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>
#import "SWRequest.h"
#import "SWCar.h"

#define SWNewRequestAlertTag      12301
@interface SWNewRequestViewController : UIViewController <MKMapViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UIView *pin;

@property (nonatomic, strong) IBOutlet UILabel *carNameLabel, *addressLabel;
@property (nonatomic, strong) IBOutlet UISegmentedControl *nightCountSegControl;

@property (nonatomic, strong) SWRequest *request;
@property (nonatomic, strong) SWCar *car;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property BOOL userMovedMap;

- (IBAction)tappedCancelButton:(id)sender;
- (IBAction)tappedCenterOnUser:(id)sender;
- (IBAction)tappedRequestButton:(id)sender;

@end
