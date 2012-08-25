//
//  SWCar.m
//  Milwaukee Parking
//
//  Created by Samuel Warmuth on 8/3/12.
//  Copyright (c) 2012 Samuel Warmuth. All rights reserved.
//

#import "SWCar.h"

@implementation SWCar

- (id)init
{
    if (self = [super init]) {
        self.requests = [NSMutableArray new];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.nickname forKey:@"nickname"];
    [encoder encodeObject:self.licensePlateNumber forKey:@"licensePlateNumber"];
    [encoder encodeObject:self.stateAbbreviation forKey:@"stateAbbreviation"];
    [encoder encodeObject:self.vehicleType forKey:@"vehicleType"];
    [encoder encodeObject:self.requests forKey:@"requests"];

}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        //decode properties, other class vars
        self.nickname = [decoder decodeObjectForKey:@"nickname"];
        self.licensePlateNumber = [decoder decodeObjectForKey:@"licensePlateNumber"];
        self.stateAbbreviation = [decoder decodeObjectForKey:@"stateAbbreviation"];
        self.vehicleType = [decoder decodeObjectForKey:@"vehicleType"];
        self.requests = [decoder decodeObjectForKey:@"requests"];
    }
    return self;
}

@end
