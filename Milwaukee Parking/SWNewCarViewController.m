//
//  SWNewCarViewController.m
//  Milwaukee Parking
//
//  Created by Samuel Warmuth on 8/3/12.
//  Copyright (c) 2012 Samuel Warmuth. All rights reserved.
//

#import "SWNewRequestViewController.h"
#import "SWNewCarViewController.h"
#import "SWAppDelegate.h"

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.nicknameField becomeFirstResponder];
}

- (IBAction)tappedStateButton:(id)sender
{
#warning can't set state yet
}

- (IBAction)tappedDoneButton:(id)sender
{
    SWAppDelegate *appDelegate = (SWAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSCharacterSet *nonAlphanumericSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    NSString *licensePlateString = [[self.licensePlateField.text componentsSeparatedByCharactersInSet:nonAlphanumericSet] componentsJoinedByString:@""];
                              
    if (licensePlateString.length == 0){
        [SVProgressHUD show];
        [SVProgressHUD dismissWithError:@"You need to enter your license plate number."];
        return;
    }
    
    if ([appDelegate findCarWithLicensePlate:licensePlateString]){
        [SVProgressHUD show];
        [SVProgressHUD dismissWithError:@"A car with this license plate already exists."];
        return;
    }
    
    self.car = [SWCar new];
    if (self.nicknameField.text.length != 0) self.car.nickname = self.nicknameField.text;

    self.car.licensePlateNumber = [licensePlateString uppercaseString];
    self.car.stateAbbreviation = @"WI";
    NSArray *types = @[@"PC", @"TK", @"MC"];
    self.car.vehicleType = [types objectAtIndex:self.vehicleTypeSegControl.selectedSegmentIndex];
    
    @synchronized (appDelegate.cars) {
        [appDelegate.cars addObject:self.car];
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.licensePlateField){
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        if (newLength > 10) return NO;
    }
    return YES;
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
