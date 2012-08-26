//
//  SWChooseCarViewController.m
//  Milwaukee Parking
//
//  Created by Samuel Warmuth on 8/3/12.
//  Copyright (c) 2012 Samuel Warmuth. All rights reserved.
//

#import "SWNewRequestViewController.h"
#import "SWCarHistoryViewController.h"
#import "SWChooseCarViewController.h"
#import "MAConfirmButton.h"
#import "SWAppDelegate.h"
#import "SWCar.h"


@interface SWChooseCarViewController ()
@end

@implementation SWChooseCarViewController

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
    @synchronized (self.cars) {
        self.cars =  [[(SWAppDelegate *)[[UIApplication sharedApplication] delegate] cars] mutableCopy];
    }
    [self.tv reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tv deselectRowAtIndexPath:[self.tv indexPathForSelectedRow] animated:animated];
}

- (IBAction)newButtonPressed:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:@"SWChooseCarToNewCar" sender:self];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cars.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SWCarCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        MAConfirmButton *historyButton = [MAConfirmButton buttonWithTitle:@"History" confirm:nil];
        [historyButton setAnchor:CGPointMake(315.0, 9.0)];
        [historyButton addTarget:self action:@selector(historyPressed:) forControlEvents:UIControlEventTouchUpInside];
        [historyButton setTintColor: [UIColor colorWithWhite:0.75 alpha:1]];
        [cell addSubview:historyButton];
    }
    
    SWCar *car = [self.cars objectAtIndex:indexPath.row];
    if (car.nickname) cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", car.nickname, car.licensePlateNumber];
    else cell.textLabel.text = car.licensePlateNumber;
    
    return cell;
}

- (void)historyPressed:(MAConfirmButton *)sender
{
    NSLog(@"History");
    UITableViewCell *cell = (UITableViewCell *)sender.superview;
    NSInteger carIndex = [self.tv indexPathForCell:cell].row;
    SWCar *car = [self.cars objectAtIndex:carIndex];
    [self performSegueWithIdentifier:@"SWChooseCarToHistory" sender:car];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"SWChooseCarToNewRequest" sender:[self.cars objectAtIndex:indexPath.row]];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.cars.count) return NO;
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SWChooseCarToNewRequest"]){
        SWNewRequestViewController *destinationController = [segue destinationViewController];
        destinationController.car = (SWCar *)sender;
    } else if ([[segue identifier] isEqualToString:@"SWChooseCarToHistory"]){
        SWCarHistoryViewController *destinationController = [segue destinationViewController];
        destinationController.car = sender;
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
