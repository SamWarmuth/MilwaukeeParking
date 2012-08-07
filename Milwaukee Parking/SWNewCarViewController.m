//
//  SWNewCarViewController.m
//  Milwaukee Parking
//
//  Created by Samuel Warmuth on 8/3/12.
//  Copyright (c) 2012 Samuel Warmuth. All rights reserved.
//

#import "SWNewCarViewController.h"
#import "SWAppDelegate.h"
#import "SVProgressHUD.h"
#import "SWNewRequestViewController.h"

@interface SWNewCarViewController ()

@end

@implementation SWNewCarViewController

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
    [super viewWillAppear:animated];
    [self.nicknameField becomeFirstResponder];
}

- (IBAction)tappedStateButton:(id)sender
{
    
}

- (IBAction)changedVehicleType:(UISegmentedControl *)sender
{
    NSArray *types = [NSArray arrayWithObjects:@"PC", @"TK", @"MC", nil];
    self.car.vehicleType = [types objectAtIndex:sender.selectedSegmentIndex];
}

- (IBAction)tappedDoneButton:(id)sender
{
    if (self.licensePlateField.text.length == 0){
        [SVProgressHUD show];
        [SVProgressHUD dismissWithError:@"You need to enter your license plate number."];
        return;
    }
    SWAppDelegate *appDelegate = (SWAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    SWCar *car = [SWCar new];
    car.licensePlateNumber = self.licensePlateField.text;
    car.stateAbbreviation = [self.stateButton titleForState:UIControlStateNormal];
    if (self.nicknameField.text.length != 0) car.nickname = self.nicknameField.text;
        
    @synchronized (appDelegate.cars) {
        [appDelegate.cars addObject:car];
        [appDelegate saveCarsToDefaults];
    }
    [self performSegueWithIdentifier:@"SWNewCarToNewRequest" sender:self];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SWNewCarToNewRequest"]){
        SWNewRequestViewController *destinationController = [segue destinationViewController];
        destinationController.car = self.car;
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
