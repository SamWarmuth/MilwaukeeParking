//
//  SWRequestCompletedViewController.m
//  Milwaukee Parking
//
//  Created by Samuel Warmuth on 8/3/12.
//  Copyright (c) 2012 Samuel Warmuth. All rights reserved.
//

#import "SWRequestCompletedViewController.h"

@interface SWRequestCompletedViewController ()

@end

@implementation SWRequestCompletedViewController

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
	// Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.hidesBackButton = TRUE;
    //@property (nonatomic, strong) IBOutlet UILabel *carNameLabel, *addressLabel, *dateLabel, *confirmationLabel;
    if (self.car.nickname) self.carNameLabel.text = [NSString stringWithFormat:@"%@ (%@)", self.car.nickname, self.car.licensePlateNumber];
    else self.carNameLabel.text = self.car.licensePlateNumber;
    
    self.addressLabel.text = self.request.fullAddress;
    self.dateLabel.text = self.request.serverDate;
    self.numNightsLabel.text = [NSString stringWithFormat:@"%@", self.request.nightCount];
    self.confirmationLabel.text = self.request.confirmationNumber;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.request.location.coordinate, 400, 400);
    [self.mapView setRegion:region animated:NO];
    
}
- (IBAction)tappedDoneButton:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:TRUE];
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
