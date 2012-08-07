//
//  SWAddressMatcher.h
//  Milwaukee Parking
//
//  Created by Samuel Warmuth on 8/7/12.
//  Copyright (c) 2012 Samuel Warmuth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SWAddressMatcher : NSObject

//addresses is an array of dictionarys that look like this: {:full => "N Cass St", :direction => "N", :street => "Cass", :suffix => "St"}
@property (nonatomic, strong) NSMutableArray *addresses;

+ (SWAddressMatcher *)sharedInstance;
+ (void)loadStreetsFromServer;
+ (NSDictionary *)findMatchingStreetComponents:(NSString *)streetName;

@end
