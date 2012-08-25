//
//  SWCarHistoryViewController.h
//  Milwaukee Parking
//
//  Created by Samuel Warmuth on 8/8/12.
//  Copyright (c) 2012 Samuel Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRequest.h"
#import "SWCar.h"

@interface SWCarHistoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tv;
@property (nonatomic, strong) SWCar *car;

@end
