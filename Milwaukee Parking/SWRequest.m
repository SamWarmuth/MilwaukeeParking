//
//  SWRequest.m
//  Milwaukee Parking
//
//  Created by Samuel Warmuth on 8/7/12.
//  Copyright (c) 2012 Samuel Warmuth. All rights reserved.
//

#import "SWRequest.h"
#import "AFNetworking.h"
#import "HTMLParser.h"

@implementation SWRequest

//@property (nonatomic, strong) NSString *houseNumber, *direction, *streetName, *suffix, *fullAddress;
//@property (nonatomic, strong) NSNumber *nightCount;
//@property BOOL requestGranted;


- (void)sendRequestWithCar:(SWCar *)car andCompletionBlock:(void (^)(NSError *error, NSString *confirmationCode))completed
{
    NSLog(@"hi.");
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://mpw.milwaukee.gov/services/np_permission"]];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setObject:self.houseNumber              forKey:@"laddr"];
    [parameters setObject:self.direction                forKey:@"sdir"];
    [parameters setObject:self.streetName               forKey:@"sname"];
    [parameters setObject:self.suffix                   forKey:@"stype"];

    [parameters setObject:[self.nightCount stringValue] forKey:@"numdays"];

    [parameters setObject:car.stateAbbreviation forKey:@"state"];
    [parameters setObject:car.tag               forKey:@"tagID"];
    [parameters setObject:car.vehicleType       forKey:@"vType"];


    
    
    [httpClient postPath:@"" parameters:parameters success:^(AFHTTPRequestOperation *request, id rawResponseData) {
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
        NSLog(@"Done Loading.");
        
        
    } failure:^(AFHTTPRequestOperation *request, NSError *error) {
        NSLog(@"REQ: %@", request);
        NSLog(@"ERR: %@", error);
    }];
    
    
    
    completed(nil, @"ABC");
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.houseNumber forKey:@"houseNumber"];
    [encoder encodeObject:self.direction forKey:@"direction"];
    [encoder encodeObject:self.streetName forKey:@"streetName"];
    [encoder encodeObject:self.suffix forKey:@"suffix"];
    [encoder encodeObject:self.fullAddress forKey:@"fullAddress"];
    [encoder encodeObject:self.confirmationNumber forKey:@"confirmationNumber"];

}

- (id)initWithCoder:(NSCoder *)decoder {
    if(self = [super init]) {
        //decode properties, other class vars
        self.houseNumber = [decoder decodeObjectForKey:@"houseNumber"];
        self.direction = [decoder decodeObjectForKey:@"direction"];
        self.streetName = [decoder decodeObjectForKey:@"streetName"];
        self.suffix = [decoder decodeObjectForKey:@"suffix"];
        self.fullAddress = [decoder decodeObjectForKey:@"fullAddress"];
        self.confirmationNumber = [decoder decodeObjectForKey:@"confirmationNumber"];
        
}
    return self;
}

@end
