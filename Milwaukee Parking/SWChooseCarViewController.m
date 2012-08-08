//
//  SWChooseCarViewController.m
//  Milwaukee Parking
//
//  Created by Samuel Warmuth on 8/3/12.
//  Copyright (c) 2012 Samuel Warmuth. All rights reserved.
//

#import "SWChooseCarViewController.h"
#import "SWAppDelegate.h"
#import "SWCar.h"
#import "SWNewRequestViewController.h"

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

- (IBAction)editButtonPressed:(UIBarButtonItem *)sender
{
    bool shouldEdit = !self.tv.editing;
    [self.tv setEditing:shouldEdit animated:TRUE];
    
    if (shouldEdit) sender.title = @"Done";
    else sender.title = @"Edit";
}

- (IBAction)newButtonPressed:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:@"SWChooseCarToNewCar" sender:self];

}

#pragma mark -
#pragma mark Table View DataSource/Delegate Methods


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
    }

    SWCar *car = [self.cars objectAtIndex:indexPath.row];
    
    if (car.nickname) cell.textLabel.text = car.nickname;
    else cell.textLabel.text = car.licensePlateNumber;
    
    cell.detailTextLabel.text = car.licensePlateNumber;
    cell.detailTextLabel.font = [UIFont fontWithName:@"system" size:18.0];
    cell.detailTextLabel.textColor = [UIColor blackColor];
    
    

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self performSegueWithIdentifier:@"SWChooseCarToNewRequest" sender:[self.cars objectAtIndex:indexPath.row]];
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    
}
- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Hi.");
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.cars.count) return NO;
    return YES;
}
/*- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.cars.count) return NO;
    return YES;
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    
}*/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SWChooseCarToNewRequest"]){
        SWNewRequestViewController *destinationController = [segue destinationViewController];
        destinationController.car = (SWCar *)sender;
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
