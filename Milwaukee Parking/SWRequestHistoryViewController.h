//
//  SWRequestHistoryViewController.h
//  Milwaukee Parking
//
//  Created by Samuel Warmuth on 8/3/12.
//  Copyright (c) 2012 Samuel Warmuth. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWRequestHistoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tv;

@end
