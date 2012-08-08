//
//  SWRequestHistoryViewController.m
//  Milwaukee Parking
//
//  Created by Samuel Warmuth on 8/3/12.
//  Copyright (c) 2012 Samuel Warmuth. All rights reserved.
//

#import "SWRequestHistoryViewController.h"
#import "SWAppDelegate.h"
#import "SWCar.h"
#import "SWRequest.h"

@interface SWRequestHistoryViewController ()

@end

@implementation SWRequestHistoryViewController

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
    @synchronized (self.cars) {
        self.cars =  [[(SWAppDelegate *)[[UIApplication sharedApplication] delegate] cars] mutableCopy];
    }
    [self.tv reloadData];
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
    if (car.nickname) cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", car.nickname, car.licensePlateNumber];
    else cell.textLabel.text = car.licensePlateNumber;
    
    
    if (car.requests.count == 1) cell.detailTextLabel.text = [NSString stringWithFormat:@"%d Request", car.requests.count];
    else cell.detailTextLabel.text = [NSString stringWithFormat:@"%d Requests", car.requests.count];

    cell.detailTextLabel.font = [UIFont fontWithName:@"system" size:18.0];
    cell.detailTextLabel.textColor = [UIColor blackColor];
        
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self performSegueWithIdentifier:@"SWHistoryToCarHistory" sender:[self.cars objectAtIndex:indexPath.row]];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (IBAction)closeButtonTapped:(id)sender
{
    [self.navigationController dismissModalViewControllerAnimated:TRUE];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
