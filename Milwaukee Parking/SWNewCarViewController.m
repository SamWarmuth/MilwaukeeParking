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
    self.stateButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.stateButton.titleLabel.adjustsFontSizeToFitWidth = TRUE;
    
    self.states = @[@[@"AL", @"Alabama"], @[@"AK", @"Alaska"], @[@"AZ", @"Arizona"], @[@"AR", @"Arkansas"], @[@"CA", @"California"], @[@"CO", @"Colorado"], @[@"CT", @"Connecticut"], @[@"DE", @"Delaware"], @[@"DC", @"District of Columbia"], @[@"FL", @"Florida"], @[@"GA", @"Georgia"], @[@"HI", @"Hawaii"], @[@"ID", @"Idaho"], @[@"IL", @"Illinois"], @[@"IN", @"Indiana"], @[@"IA", @"Iowa"], @[@"KS", @"Kansas"], @[@"KY", @"Kentucky"], @[@"LA", @"Louisiana"], @[@"ME", @"Maine"], @[@"MD", @"Maryland"], @[@"MA", @"Massachusetts"], @[@"MI", @"Michigan"], @[@"MN", @"Minnesota"], @[@"MS", @"Mississippi"], @[@"MO", @"Missouri"], @[@"MT", @"Montana"], @[@"NE", @"Nebraska"], @[@"NV", @"Nevada"], @[@"NH", @"New Hampshire"], @[@"NJ", @"New Jersey"], @[@"NM", @"New Mexico"], @[@"NY", @"New York"], @[@"NC", @"North Carolina"], @[@"ND", @"North Dakota"], @[@"OH", @"Ohio"], @[@"OK", @"Oklahoma"], @[@"OR", @"Oregon"], @[@"PA", @"Pennsylvania"], @[@"RI", @"Rhode Island"], @[@"SC", @"South Carolina"], @[@"SD", @"South Dakota"], @[@"TN", @"Tennessee"], @[@"TX", @"Texas"], @[@"UT", @"Utah"], @[@"VT", @"Vermont"], @[@"VA", @"Virginia"], @[@"WA", @"Washington"], @[@"WV", @"West Virginia"], @[@"WI", @"Wisconsin"], @[@"WY", @"Wyoming"]];
    self.statePicker = [[UIPickerView alloc] init];
    self.statePicker.frame = CGRectMake(0.0, 200.0, 320.0, 216.0);
    self.statePicker.dataSource = self;
    self.statePicker.delegate = self;
    self.statePicker.showsSelectionIndicator = YES;
    [self.statePicker reloadAllComponents];
    [self.statePicker selectRow:49 inComponent:0 animated:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.nicknameField becomeFirstResponder];
}

- (IBAction)tappedStateButton:(id)sender
{
    [self.view endEditing:YES];
    [self.view addSubview:self.statePicker];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.states.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSArray *state = [self.states objectAtIndex:row];
    return [state objectAtIndex:1];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSArray *state = [self.states objectAtIndex:row];
    [self.stateButton setTitle:[state objectAtIndex:1] forState:UIControlStateNormal];
}

/*
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    NSArray *state = [self.states objectAtIndex:row];
    
    UILabel *abbreviationLabel = [[UILabel alloc] initWithFrame:CGRectMake(25.0, 0.0, 50.0, 44.0)];
    abbreviationLabel.font = [UIFont boldSystemFontOfSize:20.0];
    abbreviationLabel.backgroundColor = [UIColor clearColor];
    abbreviationLabel.text = [state objectAtIndex:0];
    [containerView addSubview:abbreviationLabel];
    
    UILabel *fullLabel = [[UILabel alloc] initWithFrame:CGRectMake(84.0, 0.0, 240.0, 44.0)];
    fullLabel.font = [UIFont boldSystemFontOfSize:20.0];
    fullLabel.backgroundColor = [UIColor clearColor];
    fullLabel.text = [state objectAtIndex:1];
    [containerView addSubview:fullLabel];
    
    return containerView;
}
*/
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
    self.car.stateAbbreviation = [[self.states objectAtIndex:[self.statePicker selectedRowInComponent:0]] objectAtIndex:0];
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
    } else if (textField == self.nicknameField){
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        if (newLength > 15) return NO;
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
