//
//  SWCar.h
//  Milwaukee Parking
//
//  Created by Samuel Warmuth on 8/3/12.
//  Copyright (c) 2012 Samuel Warmuth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SWCar : NSObject

@property (nonatomic, strong) NSString *nickname, *licensePlateNumber, *stateAbbreviation, *vehicleType;
@property (nonatomic, strong) NSMutableArray *requests;

@end
