//
//  SWCarHistoryViewController.m
//  Milwaukee Parking
//
//  Created by Samuel Warmuth on 8/8/12.
//  Copyright (c) 2012 Samuel Warmuth. All rights reserved.
//

#import "SWCarHistoryViewController.h"
#import "SWRequestHistoryCell.h"

@interface SWCarHistoryViewController ()

@end

@implementation SWCarHistoryViewController

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
    [self.tv reloadData];
}

#pragma mark -
#pragma mark Table View DataSource/Delegate Methods


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.car.requests.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"SWRequestHistoryCell";
    SWRequestHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[SWRequestHistoryCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    SWRequest *request = [self.car.requests objectAtIndex:(self.car.requests.count - indexPath.row - 1)];
    cell.addressLabel.text = request.fullAddress;
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"MMM d";
    
    if ([request.nightCount intValue] == 1){
        cell.nightsLabel.text = [dateFormatter stringFromDate:request.date];
    } else {
        NSString *startString = [dateFormatter stringFromDate:request.date];
        NSString *endString = [dateFormatter stringFromDate:[NSDate dateWithTimeInterval: 86400.0f*([request.nightCount intValue]-1) sinceDate:request.date]];
        cell.nightsLabel.text = [NSString stringWithFormat:@"%@ - %@", startString, endString];
    }
    
    cell.confirmationLabel.text = request.confirmationNumber;

    return cell;
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
