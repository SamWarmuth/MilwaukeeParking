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


- (void)sendRequestWithCar:(SWCar *)car andCompletionBlock:(void (^)(NSError *error, NSString *confirmationCode))completed
{
    NSLog(@"hi.");
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setObject:self.houseNumber              forKey:@"laddr"];
    [parameters setObject:self.direction                forKey:@"sdir"];
    [parameters setObject:self.streetName               forKey:@"sname"];
    [parameters setObject:self.suffix                   forKey:@"stype"];

    [parameters setObject:[NSString stringWithFormat:@"%@", self.nightCount] forKey:@"numdays"];

    [parameters setObject:car.stateAbbreviation         forKey:@"state"];
    [parameters setObject:car.licensePlateNumber        forKey:@"tagID"];
    [parameters setObject:car.vehicleType               forKey:@"vType"];


    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://mpw.milwaukee.gov/services/np_permission"]];
    [httpClient postPath:@"" parameters:parameters success:^(AFHTTPRequestOperation *request, id rawResponseData) {
        //NSDictionary *response = [NSJSONSerialization JSONObjectWithData:rawResponseData options:kNilOptions error:nil];
        //NSLog(@"RESPO: %@", request.responseString);
        
        [self sendConfirmationWithIntitialResponse:request.responseString withParams:parameters andCompletionBlock:^(NSError *error, NSString *confirmationCode) {
            NSLog(@"Ok, actually done.");
            completed(nil, confirmationCode);

        }];
        
        

        
        
    } failure:^(AFHTTPRequestOperation *request, NSError *error) {
        NSLog(@"REQ: %@", request);
        NSLog(@"ERR: %@", error);
        completed(nil, nil);

    }];
    
}


- (void)sendConfirmationWithIntitialResponse:(NSString *)responseHTML withParams:(NSMutableDictionary *)parameters andCompletionBlock:(void (^)(NSError *error, NSString *confirmationCode))completed
{
    //laddr changes into houseNum
    [parameters setObject:[parameters objectForKey:@"laddr"] forKey:@"houseNum"];
    [parameters removeObjectForKey:@"laddr"];
    
    
    
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:responseHTML error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
        return;
    }
    HTMLNode *bodyNode = [parser body];
    
    
    HTMLNode *form = [bodyNode findChildWithAttribute:@"id" matchingName:@"nConf" allowPartial:FALSE];
    //NSArray *inputNodes = [bodyNode findChildTags:@"input"];
    //for (HTMLNode *node in inputNodes){
        //NSLog(@"Ok, this node's name is ")
    //}
    
    self.serverDate = [[form findChildWithAttribute:@"name" matchingName:@"rdate" allowPartial:FALSE] getAttributeNamed:@"value"];
    self.district = [[form findChildWithAttribute:@"name" matchingName:@"dist" allowPartial:FALSE] getAttributeNamed:@"value"];
    
    
    [parameters setObject:self.serverDate forKey:@"rdate"];
    [parameters setObject:self.district forKey:@"dist"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://mpw.milwaukee.gov/services/np_confirmation"]];
    [httpClient postPath:@"" parameters:parameters success:^(AFHTTPRequestOperation *request, id rawResponseData) {
        //NSDictionary *response = [NSJSONSerialization JSONObjectWithData:rawResponseData options:kNilOptions error:nil];
        NSLog(@"RESPO: %@", request.responseString);
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<b>(\\d{7})<\\/b>" options:0 error:NULL];
        NSTextCheckingResult *match = [regex firstMatchInString:request.responseString options:0 range:NSMakeRange(0, [request.responseString length])];
        
        if (!match || match == (id)[NSNull null]){
            NSLog(@"Error, request wasn't successful. Maybe you've already requested permission for tonight?");
            completed(nil, nil);
            return;
        }
        
        self.confirmationNumber = [request.responseString substringWithRange:[match rangeAtIndex:1]];

        NSLog(@"Confirmation? A:%@", self.confirmationNumber);
        
        completed(nil, self.confirmationNumber);
    } failure:^(AFHTTPRequestOperation *request, NSError *error) {
        NSLog(@"REQ: %@", request);
        NSLog(@"ERR: %@", error);
        completed(nil, nil);
    }];
        
}



- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.houseNumber forKey:@"houseNumber"];
    [encoder encodeObject:self.direction forKey:@"direction"];
    [encoder encodeObject:self.streetName forKey:@"streetName"];
    [encoder encodeObject:self.suffix forKey:@"suffix"];
    [encoder encodeObject:self.fullAddress forKey:@"fullAddress"];
    [encoder encodeObject:self.district forKey:@"district"];
    [encoder encodeObject:self.serverDate forKey:@"serverDate"];
    [encoder encodeObject:self.confirmationNumber forKey:@"confirmationNumber"];
    [encoder encodeObject:self.location forKey:@"location"];
    [encoder encodeObject:self.nightCount forKey:@"nightCount"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        //decode properties, other class vars
        self.houseNumber = [decoder decodeObjectForKey:@"houseNumber"];
        self.direction = [decoder decodeObjectForKey:@"direction"];
        self.streetName = [decoder decodeObjectForKey:@"streetName"];
        self.suffix = [decoder decodeObjectForKey:@"suffix"];
        self.fullAddress = [decoder decodeObjectForKey:@"fullAddress"];
        self.district = [decoder decodeObjectForKey:@"district"];
        self.serverDate = [decoder decodeObjectForKey:@"serverDate"];
        self.confirmationNumber = [decoder decodeObjectForKey:@"confirmationNumber"];
        self.location = [decoder decodeObjectForKey:@"location"];
        self.nightCount = [decoder decodeObjectForKey:@"nightCount"];
    }
    return self;
}

@end
