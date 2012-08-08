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
#import "NSString+Levenshtein.h"

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
        //NSDictionary *response = [NSJSONSerialization JSONObjectWithData:rawResponseData options:kNilOptions error:nil];
        //NSLog(@"RESPO: %@", request.responseString);
        
        
        NSError *error;
        HTMLParser *parser = [[HTMLParser alloc] initWithString:request.responseString error:&error];
        if (error) {
            NSLog(@"Error: %@", error);
            return;
        }
        HTMLNode *bodyNode = [parser body];
        
        
        NSMutableArray *addresses = [NSMutableArray new];
        
        NSArray *inputNodes = [bodyNode findChildTags:@"a"];
        for (HTMLNode *inputNode in inputNodes) {
            NSMutableDictionary *components = [NSMutableDictionary new];
            NSString *href = [inputNode getAttributeNamed:@"href"];
            
            //NSLog(@"href: '%@'", href);
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@".*\\(\"(.*)\", \"(.*)\", \"(.*)\"\\);" options:0 error:NULL];
            NSTextCheckingResult *match = [regex firstMatchInString:href options:0 range:NSMakeRange(0, [href length])];
            
            if (!match || match == (id)[NSNull null]) continue;
            
            NSString *fullName = [[inputNode.contents uppercaseString]  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
            [components setObject:fullName forKey:@"full"];
            [components setObject:[href substringWithRange:[match rangeAtIndex:1]] forKey:@"direction"];
            [components setObject:[href substringWithRange:[match rangeAtIndex:2]] forKey:@"street"];
            [components setObject:[href substringWithRange:[match rangeAtIndex:3]] forKey:@"suffix"];
            
            //NSLog(@"node: %@", components);
            
            [addresses addObject:components];
        }
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

+ (NSDictionary *)findMatchingStreetComponents:(NSString *)streetName
{

    SWAddressMatcher *sharedInstance = [self sharedInstance];
    
    if (!sharedInstance.addresses) return nil;
    
    streetName = [streetName uppercaseString];
    streetName = [streetName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    streetName = [streetName stringByReplacingOccurrencesOfString:@" AVE" withString:@" AV"];
    streetName = [streetName stringByReplacingOccurrencesOfString:@" BLVD" withString:@" BL"];
    streetName = [streetName stringByReplacingOccurrencesOfString:@" SAINT " withString:@" ST "];
    
    NSDictionary *match;
    
    for (NSDictionary *address in sharedInstance.addresses) {
        // note the modified weighting, this ends up working similiar to Alfred / TextMate searching method
        // TextMate takes into account camelcase while matching and is a little smarter, but you get the idea
        //NSLog(@"%@ vs %@", [address objectForKey:@"full"], streetName);
        if ([(NSString *)[address objectForKey:@"full"] isEqualToString:streetName]){
            match = address;
            break;
        }
    }

    //NSLog(@"%@", match);
    
    
    return match;
}

@end
