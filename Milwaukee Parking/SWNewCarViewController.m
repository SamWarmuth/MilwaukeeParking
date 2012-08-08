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


- (IBAction)tappedDoneButton:(id)sender
{
    if (self.licensePlateField.text.length == 0){
        [SVProgressHUD show];
        [SVProgressHUD dismissWithError:@"You need to enter your license plate number."];
        return;
    }
    SWAppDelegate *appDelegate = (SWAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.car = [SWCar new];
    if (self.nicknameField.text.length != 0) self.car.nickname = self.nicknameField.text;

    self.car.licensePlateNumber = self.licensePlateField.text;
    self.car.stateAbbreviation = @"WI";
            
        
    NSArray *types = [NSArray arrayWithObjects:@"PC", @"TK", @"MC", nil];
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
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
