//
//  SWRequest.h
//  Milwaukee Parking
//
//  Created by Samuel Warmuth on 8/7/12.
//  Copyright (c) 2012 Samuel Warmuth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "SWCar.h"

typedef enum {
    SWAlreadyRegisteredError,
    SWHitMonthlyLimitError,
    SWUnpaidCitationsError,
    SWUnknownError
} SWErrorType;

@interface SWRequest : NSObject

@property (nonatomic, strong) NSString *houseNumber, *direction, *streetName, *suffix, *fullAddress, *district, *serverDate, *confirmationNumber;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) NSNumber *nightCount;

- (void)sendRequestWithCar:(SWCar *)car andCompletionBlock:(void (^)(NSError *error, NSString *confirmationCode))completed;
- (void)sendConfirmationWithIntitialResponse:(NSString *)responseHTML withParams:(NSMutableDictionary *)parameters andCompletionBlock:(void (^)(NSError *error, NSString *confirmationCode))completed;

@end
