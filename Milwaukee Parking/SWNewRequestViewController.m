//
//  SWNewRequestViewController.m
//  Milwaukee Parking
//
//  Created by Samuel Warmuth on 8/3/12.
//  Copyright (c) 2012 Samuel Warmuth. All rights reserved.
//

#import "SWRequestCompletedViewController.h"
#import "SWNewRequestViewController.h"
#import "SWAddressMatcher.h"
#import "SWAppDelegate.h"


@interface SWNewRequestViewController ()

@end

@implementation SWNewRequestViewController

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
    [[CLLocationManager new] requestWhenInUseAuthorization];

    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(userUpdatedMap)];
    panGesture.delegate = self;
    [self.mapView addGestureRecognizer:panGesture];
    
    self.geocoder = [CLGeocoder new];
    self.request = [SWRequest new];
    CLLocation *milwaukeeCenter = [[CLLocation alloc] initWithLatitude:43.05 longitude:-87.92];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(milwaukeeCenter.coordinate, 8000, 8000);
    [self.mapView setRegion:region animated:NO];
    [self updateAddress:milwaukeeCenter];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.pin.alpha = 0.0;
    
    if (self.car.nickname) self.carNameLabel.text = [NSString stringWithFormat:@"%@ (%@)", self.car.nickname, self.car.licensePlateNumber];
    else self.carNameLabel.text = self.car.licensePlateNumber;
    
    self.userMovedMap = FALSE;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updatePinLocation];
    [UIView animateWithDuration:1.0 delay:0.5 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.pin.alpha = 1.0;
    } completion:NULL];
}

- (void)updatePinLocation
{
    CGFloat mapCenterX = CGRectGetMidX(self.mapView.frame);
    CGFloat mapCenterY = CGRectGetMidY(self.mapView.frame);
    CGRect pinFrame = self.pin.frame;
    pinFrame.origin.x = mapCenterX - pinFrame.size.width/2.0;
    pinFrame.origin.y = mapCenterY - pinFrame.size.height;
    self.pin.frame = pinFrame;
}

- (void)userUpdatedMap
{
    self.userMovedMap = TRUE;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (self.userMovedMap) return;
    if (userLocation.coordinate.latitude == 0.0) return;
    
    CLLocationDegrees lat = userLocation.coordinate.latitude;
    CLLocationDegrees lng = userLocation.coordinate.longitude;
    
    if (lat > 43.25 || lat < 42.85 || lng > -87.52 || lng < -88.15){
        //If innacurate, just ignore
        if (userLocation.location.horizontalAccuracy > 100) return;
        [SVProgressHUD show];
        [SVProgressHUD dismissWithError:@"Your current location isn't in Milwaukee. Move the map to choose a parking spot." afterDelay:3.5];
        return;
    }
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 400, 400);
    [mapView setRegion:region animated:YES];
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

        //kludge to fix sticky location bug
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        if ([placemark.thoroughfare isEqualToString:@"Bee Creek"]){
            CLLocationCoordinate2D centerCoord = self.mapView.centerCoordinate;
            CLLocation *location = [[CLLocation alloc] initWithLatitude:centerCoord.latitude longitude:centerCoord.longitude];
            [self updateAddress:location];
            return;
        }
        
        NSDictionary *components = [SWAddressMatcher findMatchingStreetComponents:placemark.thoroughfare];
        
        if (!components){
            self.addressLabel.text = @"Not a valid Milwaukee address.";
            self.request.location = nil;
            NSLog(@"Error: %@", placemark.thoroughfare);
            return;
        }
        
        NSString *singleNumberAddress = [[NSNumber numberWithInt:[placemark.subThoroughfare integerValue]] stringValue];
        NSString *addressString = [NSString stringWithFormat:@"%@ %@", singleNumberAddress, placemark.thoroughfare];
        
        self.addressLabel.text = addressString;
        self.request.houseNumber = singleNumberAddress;
        self.request.direction = [components objectForKey:@"direction"];
        self.request.streetName = [components objectForKey:@"street"];
        self.request.suffix = [components objectForKey:@"suffix"];
        self.request.fullAddress = addressString;
        self.request.location = location;
    }];
}

- (IBAction)tappedCenterOnUser:(id)sender
{
    if (!self.mapView.userLocation || self.mapView.userLocation.location.coordinate.latitude == 0.0){
        [SVProgressHUD show];
        [SVProgressHUD dismissWithError:@"Current location not available."];
        return;
    }
    
    CLLocationDegrees lat = self.mapView.userLocation.coordinate.latitude;
    CLLocationDegrees lng = self.mapView.userLocation.coordinate.longitude;
    
    if (lat > 43.25 || lat < 42.85 || lng > -87.52 || lng < -88.15){
        //If innacurate, just ignore
        if (self.mapView.userLocation.location.horizontalAccuracy > 100) return;
        [SVProgressHUD show];
        [SVProgressHUD dismissWithError:@"Your current location isn't in Milwaukee. Move the map to choose a parking spot." afterDelay:3];
        return;
    }

    self.userMovedMap = FALSE;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.location.coordinate, 400, 400);
    [self.mapView setRegion:region animated:YES];
}



- (IBAction)tappedCancelButton:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:TRUE];
}

- (IBAction)tappedRequestButton:(id)sender
{
    if (!self.request.location){
        [SVProgressHUD show];
        [SVProgressHUD dismissWithError:@"This location isn't valid."];
        return;
    }
    
    //stop updating map position, so address is fixed
    self.userMovedMap = TRUE;

    self.request.nightCount = @(self.nightCountSegControl.selectedSegmentIndex + 1);
    self.request.date = [NSDate date];
    
    NSString *nightPlural = @"Nights";
    if ([self.request.nightCount intValue] == 1) nightPlural = @"Night";
    
    NSString *messageText = [NSString stringWithFormat:@"License Plate '%@'\n%@\n %@ %@", self.car.licensePlateNumber, self.request.fullAddress, self.request.nightCount, nightPlural ];
        
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Request Permission?"
                                                        message:messageText
                                                       delegate:nil
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Request", nil];
    
    alertView.delegate = self;
    alertView.tag = SWNewRequestAlertTag;
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex == buttonIndex) return;

    if (alertView.tag == SWNewRequestAlertTag){
        if (!self.car.requests || self.car.requests == (id)[NSNull null]) self.car.requests = [NSMutableArray new];
        
        [SVProgressHUD showWithStatus:@"Requesting Parking Permission"];
        
        if ([self.car.licensePlateNumber isEqualToString:@"TESTING"]){
            [SVProgressHUD dismiss];
            self.request.confirmationNumber = @"1876543";
            SWAppDelegate *appDelegate = (SWAppDelegate *)[[UIApplication sharedApplication] delegate];
            [self.car.requests addObject:self.request];
            [appDelegate saveCarsToDefaults];
            [self performSegueWithIdentifier:@"SWNewRequestToRequestCompleted" sender:self];
            return;
        }
        
        [self.request sendRequestWithCar:self.car andCompletionBlock:^(NSError *error, NSString *confirmationCode) {
            if (error || !confirmationCode){
                NSLog(@"%@", error);
                if (error && error.code == SWAlreadyRegisteredError) {
                    [SVProgressHUD dismissWithError:@"Sorry, this license plate already has parking permission for tonight." afterDelay:5.0];
                } else if (error && error.code == SWHitMonthlyLimitError){
                    [SVProgressHUD dismissWithError:@"Sorry, this license plate has already used 3 nights of parking this month." afterDelay:5.0];
                } else if (error && error.code == SWUnpaidCitationsError){
                    [SVProgressHUD dismissWithError:@"Sorry, this license plate has unpaid citations. Parking permission cannot be granted." afterDelay:5.0];
                } else {
                    [SVProgressHUD dismissWithError:@"Sorry, your request wasn't successful.\n Please try again." afterDelay:5.0];
                }
            } else {
                [SVProgressHUD dismiss];
                SWAppDelegate *appDelegate = (SWAppDelegate *)[[UIApplication sharedApplication] delegate];
                [self.car.requests addObject:self.request];
                [appDelegate saveCarsToDefaults];
                [self performSegueWithIdentifier:@"SWNewRequestToRequestCompleted" sender:self];
            }
        }];
    } 
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SWNewRequestToRequestCompleted"]){
        SWRequestCompletedViewController *destinationController = [segue destinationViewController];
        destinationController.car = self.car;
        destinationController.request = self.request;
    }
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
