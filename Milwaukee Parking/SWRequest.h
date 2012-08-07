//
//  SWRequest.h
//  Milwaukee Parking
//
//  Created by Samuel Warmuth on 8/7/12.
//  Copyright (c) 2012 Samuel Warmuth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SWCar.h"

@interface SWRequest : NSObject

@property (nonatomic, strong) NSString *houseNumber, *direction, *streetName, *suffix, *fullAddress, *confirmationNumber;
@property (nonatomic, strong) NSNumber *nightCount;


- (void)sendRequestWithCar:(SWCar *)car andCompletionBlock:(void (^)(NSError *error, NSString *confirmationCode))completed;

@end
