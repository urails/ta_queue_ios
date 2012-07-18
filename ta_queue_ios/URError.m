//
//  URError.m
//  ta_queue_ios
//
//  Created by Parker Wightman on 7/6/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import "URError.h"

@implementation URError


+ (NSString *) errorMessageWithResponse:(NSDictionary *)dictionary {
    NSString *message = @"";
    
    for (NSString *mess in [dictionary objectForKey:@"errors"]) {
        message = [message stringByAppendingFormat:@"%@\n", mess];
    }
    
    return message;
}

@end
