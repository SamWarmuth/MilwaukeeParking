//
//  SWAddressMatcher.m
//  Milwaukee Parking
//
//  Created by Samuel Warmuth on 8/7/12.
//  Copyright (c) 2012 Samuel Warmuth. All rights reserved.
//

#import "SWAddressMatcher.h"
#import "AFNetworking.h"
#import "HTMLParser.h"

@implementation SWAddressMatcher

+ (SWAddressMatcher *)sharedInstance
{
	static SWAddressMatcher *sharedInstance;
	@synchronized (self) {
		if (!sharedInstance) sharedInstance = [[SWAddressMatcher alloc] init];
		return sharedInstance;
	}
}

+ (void)loadStreetsFromServer
{
    //first, load local copy for immediate use
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *streetData = [defaults objectForKey:@"SWNightParkingStreetData"];
    SWAddressMatcher *sharedInstance = [self sharedInstance];
    
    if (!streetData || streetData == (id)[NSNull null]){
        NSLog(@"No street data found.");
    } else {
        NSLog(@"Local street data loaded.");
        sharedInstance.addresses = (NSMutableArray *)[NSKeyedUnarchiver unarchiveObjectWithData:streetData];
    }
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://mpw.milwaukee.gov/services/street_picker"]];
    [httpClient getPath:@"" parameters:nil success:^(AFHTTPRequestOperation *request, id rawResponseData) {
        NSArray *addresses = [self parseAddresses:request.responseString];
        NSLog(@"Street data refreshed.");
        SWAddressMatcher *sharedInstance = [self sharedInstance];
        sharedInstance.addresses = addresses;
        
        //Save to defaults to be loaded at startup.
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *streetData = [NSKeyedArchiver archivedDataWithRootObject:sharedInstance.addresses];
        [defaults setObject:streetData forKey:@"SWNightParkingStreetData"];
        [defaults synchronize];
    } failure:^(AFHTTPRequestOperation *request, NSError *error) {
        NSLog(@"REQ: %@", request);
        NSLog(@"ERR: %@", error);
    }];
}

+ (NSArray *)parseAddresses:(NSString *)body
{
    NSMutableArray *addresses = [NSMutableArray new];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"selectStreet\\('(\\w*)', '(\\w*)', '(\\w*)'" options:0 error:NULL];
    NSArray *matches = [regex matchesInString:body options:0 range:NSMakeRange(0, body.length)];
    for (NSTextCheckingResult *match in matches) {
        NSString *direction = [body substringWithRange:[match rangeAtIndex:1]];
        NSString *street = [body substringWithRange:[match rangeAtIndex:2]];
        NSString *suffix = [body substringWithRange:[match rangeAtIndex:3]];
        NSString *full = [@[direction, street, suffix] componentsJoinedByString:@" "];
        [addresses addObject:@{@"full": full, @"direction": direction, @"street": street, @"suffix": suffix}];
    }

    return addresses;
}

+ (NSDictionary *)findMatchingStreetComponents:(NSString *)streetName
{
    SWAddressMatcher *sharedInstance = [self sharedInstance];
    if (!sharedInstance.addresses) return nil;
    
    streetName = [streetName uppercaseString];
    streetName = [streetName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    streetName = [streetName stringByReplacingOccurrencesOfString:@" AVE" withString:@" AV"];
    streetName = [streetName stringByReplacingOccurrencesOfString:@" BLVD" withString:@" BL"];
    streetName = [streetName stringByReplacingOccurrencesOfString:@" SAINT " withString:@" ST "];
    streetName = [streetName stringByReplacingOccurrencesOfString:@" ADJ" withString:@""];
    
    NSDictionary *match;
    
    for (NSDictionary *address in sharedInstance.addresses) {
        if ([(NSString *)[address objectForKey:@"full"] isEqualToString:streetName]){
            match = address;
            break;
        }
    }

    return match;
}

@end
