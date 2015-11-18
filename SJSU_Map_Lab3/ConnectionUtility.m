//
//  ConnectionUtility.m
//  SJSU_Map_Lab3
//
//  Created by TUSHAR KHONDE on 11/12/15.
//  Copyright © 2015 TUSHAR KHONDE. All rights reserved.
//

#import "ConnectionUtility.h"

static NSString *BASE_URL = @"https://maps.googleapis.com/maps/api/";
static NSString *PATH = @"distancematrix/";
static NSString *RESPONSE_TYPE = @"json";
static NSString *API_KEY = @"AIzaSyAUurVkgnqbYTTRU07--X8NT4caH0iNQzY";

@implementation ConnectionUtility

+ (void)getDataFrom:(NSURL *)url onCompletion:(void (^) (NSDictionary *response, NSError *error))onCompletion {
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithURL:url
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                
                if (error) {
                    
                    onCompletion(nil, error);
                } else {
                    
                    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    
                    onCompletion(responseDictionary, nil);
                }
            }] resume];
}

+ (NSURL *)prepareUrlUsingFrom:(NSString *)fromLocation to:(NSString *)toLocation {
    
    NSString *stringUrl = [NSString stringWithFormat:@"%@%@%@?origins=%@&destinations=%@&key=%@", BASE_URL, PATH, RESPONSE_TYPE, fromLocation, toLocation, API_KEY];
    stringUrl = [stringUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return [NSURL URLWithString:stringUrl];
}

@end