//
//  SWNewRequestViewController.m
//  Milwaukee Parking
//
//  Created by Samuel Warmuth on 8/3/12.
//  Copyright (c) 2012 Samuel Warmuth. All rights reserved.
//

#import "SWNewRequestViewController.h"
#import "SWAddressMatcher.h"

@interface SWNewRequestViewController ()

@end

@implementation SWNewRequestViewController
bool userMovedMap;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(userUpdatedMap)];
    panGesture.delegate = self;
    [self.mapView addGestureRecognizer:panGesture];
    
    self.geocoder = [CLGeocoder new];
    self.request = [SWRequest new];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.car.nickname) self.carNameLabel.text = [NSString stringWithFormat:@"%@ (%@)", self.car.nickname, self.car.licensePlateNumber];
    else self.carNameLabel.text = self.car.licensePlateNumber;
    
    userMovedMap = FALSE;
}

- (void)userUpdatedMap
{
    userMovedMap = TRUE;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (userMovedMap) return;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 400, 400);
    [mapView setRegion:region animated:NO];
    [self updateAddress:userLocation.location];

}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
   self.addressLabel.text = @"Finding Address...";
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    CLLocationCoordinate2D centerCoord = self.mapView.centerCoordinate;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:centerCoord.latitude longitude:centerCoord.longitude];
    [self updateAddress:location];
}

- (void)updateAddress:(CLLocation *)location
{
    self.addressLabel.text = @"Finding Address...";
    
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        //Get nearby address
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        if ([placemark.thoroughfare isEqualToString:@"Bee Creek"]){
            CLLocationCoordinate2D centerCoord = self.mapView.centerCoordinate;
            CLLocation *location = [[CLLocation alloc] initWithLatitude:centerCoord.latitude longitude:centerCoord.longitude];
            [self updateAddress:location];
            return;
        }
        
        NSDictionary *components = [SWAddressMatcher findMatchingStreetComponents:placemark.thoroughfare];
        NSString *singleNumberAddress = [[NSNumber numberWithInt:[placemark.subThoroughfare integerValue]] stringValue];
        NSString *addressString = [NSString stringWithFormat:@"%@ %@", singleNumberAddress, placemark.thoroughfare];
        
        self.addressLabel.text = addressString;
        
        self.request.houseNumber = singleNumberAddress;
        self.request.direction = [components objectForKey:@"direction"];
        self.request.streetName = [components objectForKey:@"street"];
        self.request.suffix = [components objectForKey:@"suffix"];
        self.request.fullAddress = addressString;
    }];
}

- (IBAction)tappedCenterOnUser:(id)sender
{
    userMovedMap = FALSE;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.location.coordinate, 400, 400);
    [self.mapView setRegion:region animated:YES];
}


- (IBAction)tappedCancelButton:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:TRUE];
}

- (IBAction)tappedRequestButton:(id)sender
{
    self.request.nightCount = [NSNumber numberWithInteger:self.nightCountSegControl.selectedSegmentIndex];
    
    [self.car.requests addObject:self.request];
    
    [self.request sendRequestWithCar:self.car andCompletionBlock:^(NSError *error, NSString *confirmationCode) {
        if (error || !confirmationCode){
            NSLog(@"Oh No! Error.");
            return;
        }
        
        NSLog(@"Done.");
        [self performSegueWithIdentifier:@"SWNewRequestToRequestCompleted" sender:self];
    }];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
