//
//  SWRequest.m
//  Milwaukee Parking
//
//  Created by Samuel Warmuth on 8/7/12.
//  Copyright (c) 2012 Samuel Warmuth. All rights reserved.
//

#import "AFNetworking.h"
#import "HTMLParser.h"
#import "SWRequest.h"

@implementation SWRequest

- (void)sendRequestWithCar:(SWCar *)car andCompletionBlock:(void (^)(NSError *error, NSString *confirmationCode))completed
{
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setObject:self.houseNumber              forKey:@"laddr"];
    [parameters setObject:self.direction                forKey:@"sdir"];
    [parameters setObject:self.streetName               forKey:@"sname"];
    [parameters setObject:self.suffix                   forKey:@"stype"];
    [parameters setObject:[NSString stringWithFormat:@"%@", self.nightCount] forKey:@"numdays"];
    
    [parameters setObject:car.stateAbbreviation         forKey:@"state"];
    [parameters setObject:car.licensePlateNumber        forKey:@"tagID"];
    [parameters setObject:car.vehicleType               forKey:@"vType"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults boolForKey:@"SWSendEmailConfirmation"] && [defaults objectForKey:@"SWEmail"] && [[defaults objectForKey:@"SWEmail"] length] != 0){
        [parameters setObject:[defaults objectForKey:@"SWEmail"] forKey:@"email"];
    }
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://mpw.milwaukee.gov/services/np_permission"]];
    [httpClient postPath:@"" parameters:parameters success:^(AFHTTPRequestOperation *request, id rawResponseData) {
        [self sendConfirmationWithIntitialResponse:request.responseString withParams:parameters andCompletionBlock:^(NSError *error, NSString *confirmationCode) {
            NSLog(@"Request completed.");
            completed(error, confirmationCode);
        }];
    } failure:^(AFHTTPRequestOperation *request, NSError *error) {
        NSLog(@"REQ: %@", request);
        NSLog(@"ERR: %@", error);
        completed(nil, nil);
    }];
}


- (void)sendConfirmationWithIntitialResponse:(NSString *)responseHTML withParams:(NSMutableDictionary *)parameters andCompletionBlock:(void (^)(NSError *error, NSString *confirmationCode))completed
{
    //laddr changes into houseNum, email into emailaddr
    [parameters setObject:[parameters objectForKey:@"laddr"] forKey:@"houseNum"];
    [parameters removeObjectForKey:@"laddr"];

    if ([parameters objectForKey:@"email"]) {
        [parameters setObject:[parameters objectForKey:@"email"] forKey:@"emailaddr"];
        [parameters removeObjectForKey:@"email"];
    }
    
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:responseHTML error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
        return;
    }
    HTMLNode *bodyNode = [parser body];
    HTMLNode *form = [bodyNode findChildWithAttribute:@"id" matchingName:@"nConf" allowPartial:FALSE];
    self.serverDate = [[form findChildWithAttribute:@"name" matchingName:@"rdate" allowPartial:FALSE] getAttributeNamed:@"value"];
    self.district =   [[form findChildWithAttribute:@"name" matchingName:@"dist" allowPartial:FALSE]  getAttributeNamed:@"value"];
    
    [parameters setObject:self.serverDate forKey:@"rdate"];
    [parameters setObject:self.district forKey:@"dist"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://mpw.milwaukee.gov/services/np_confirmation"]];
    [httpClient postPath:@"" parameters:parameters success:^(AFHTTPRequestOperation *request, id rawResponseData) {
        NSLog(@"RESPO: %@", request.responseString);
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<strong>(\\d+)<\\/strong>" options:0 error:NULL];
        NSTextCheckingResult *match = [regex firstMatchInString:request.responseString options:0 range:NSMakeRange(0, [request.responseString length])];
        if (!match || match == (id)[NSNull null]){
            NSError *error = [self findErrorInResponse:request.responseString];
            NSLog(@"ERR:%@", error);
            NSLog(@"Error, request wasn't successful.");
            completed(error, nil);
        } else {
            self.confirmationNumber = [request.responseString substringWithRange:[match rangeAtIndex:1]];
            completed(nil, self.confirmationNumber);
        }
    } failure:^(AFHTTPRequestOperation *request, NSError *error) {
        NSLog(@"REQ: %@", request);
        NSLog(@"ERR: %@", error);
        completed(nil, nil);
    }];
}

- (NSError *)findErrorInResponse:(NSString *)response
{
    NSError *error;
    
    NSRange registeredRange = [response rangeOfString: @"This license plate is already registered"];
    if (registeredRange.location != NSNotFound){
        error = [NSError errorWithDomain:@"SWError" code:SWAlreadyRegisteredError userInfo:nil];
        return error;
    }
    
    NSRange monthlyRange = [response rangeOfString: @"You are only allowed"];
    if (monthlyRange.location != NSNotFound){
        error = [NSError errorWithDomain:@"SWError" code:SWHitMonthlyLimitError userInfo:nil];
        return error;
    }
    
    NSRange unpaidRange = [response rangeOfString: @"unpaid citations in excess"];
    if (unpaidRange.location != NSNotFound){
        error = [NSError errorWithDomain:@"SWError" code:SWUnpaidCitationsError userInfo:nil];
        return error;
    }
    
    
    
    error = [NSError errorWithDomain:@"SWError" code:SWUnknownError userInfo:nil];
    return error;
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
    [encoder encodeObject:self.date forKey:@"date"];
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
        self.date = [decoder decodeObjectForKey:@"date"];
    }
    return self;
}

@end
