//
//  ConnectionUtility.h
//  SJSU_Map_Lab3
//
//  Created by TUSHAR KHONDE on 11/12/15.
//  Copyright © 2015 TUSHAR KHONDE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectionUtility : NSObject

+ (void)getDataFrom:(NSURL *)url onCompletion:(void (^) (NSDictionary *response, NSError *error))onCompletion;

@end