//
//  SWNewRequestViewController.m
//  Milwaukee Parking
//
//  Created by Samuel Warmuth on 8/3/12.
//  Copyright (c) 2012 Samuel Warmuth. All rights reserved.
//

#import "SWNewRequestViewController.h"
#import "SWAddressMatcher.h"
#import "SWRequestCompletedViewController.h"
#import "SWAppDelegate.h"
#import "SVProgressHUD.h"


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
    CLLocation *milwaukeeCenter = [[CLLocation alloc] initWithLatitude:43.05 longitude:-87.92];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(milwaukeeCenter.coordinate, 8000, 8000);
    [self.mapView setRegion:region animated:NO];
    [self updateAddress:milwaukeeCenter];
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
    if (userLocation.coordinate.latitude == 0.0) return;
    
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
        
        //Get nearby address
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        if ([placemark.thoroughfare isEqualToString:@"Bee Creek"]){
            CLLocationCoordinate2D centerCoord = self.mapView.centerCoordinate;
            CLLocation *location = [[CLLocation alloc] initWithLatitude:centerCoord.latitude longitude:centerCoord.longitude];
            [self updateAddress:location];
            return;
        }
        
        NSDictionary *components = [SWAddressMatcher findMatchingStreetComponents:placemark.thoroughfare];
        
        if (!components){
            self.addressLabel.text = @"Not a valid address.";
            NSLog(@"ER %@", placemark.thoroughfare);

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
    self.request.nightCount = [NSNumber numberWithInteger:self.nightCountSegControl.selectedSegmentIndex + 1];
    
    NSString *nightPlural = @"nights";
    if ([self.request.nightCount intValue] == 1) nightPlural = @"night";
    
    NSString *messageText = [NSString stringWithFormat:@"License plate '%@'\n%@\n %@ %@", self.car.licensePlateNumber, self.request.fullAddress, self.request.nightCount, nightPlural ];
        
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Request Permission?"
                                                        message:messageText
                                                       delegate:nil
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Request", nil];
    alertView.delegate = self;
    alertView.tag = SWNewRequestAlertTag;
    
    //this is an ugly hack, but it makes the formatting nicer.
    UILabel *alertViewLabel = (UILabel*)[[alertView subviews] objectAtIndex:1];
    alertViewLabel.textAlignment = UITextAlignmentRight;
    
    [alertView show];
    
    
    

    
        
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex == buttonIndex) return;

    if (alertView.tag == SWNewRequestAlertTag){
        if (!self.car.requests || self.car.requests == (id)[NSNull null]) self.car.requests = [NSMutableArray new];
        [self.car.requests addObject:self.request];
        
        //save basic request, in case we crash or fail to confirm.
        SWAppDelegate *appDelegate = (SWAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate saveCarsToDefaults];
        
        [SVProgressHUD showWithStatus:@"Requesting Parking Permission"];
        
        [self.request sendRequestWithCar:self.car andCompletionBlock:^(NSError *error, NSString *confirmationCode) {
            if (error || !confirmationCode){
                [SVProgressHUD dismissWithError:@"Sorry, your request wasn't successful.\nMaybe you've already requested permission for tonight?" afterDelay:5.0];
                NSLog(@"Oh No! Error.");
            } else {
                [SVProgressHUD dismiss];
                NSLog(@"Done.");
                //This request is now fully complete, save.
                [appDelegate saveCarsToDefaults];
                //[self performSegueWithIdentifier:@"SWNewRequestToRequestCompleted" sender:self];
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
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
