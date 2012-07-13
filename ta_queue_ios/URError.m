//
//  URError.m
//  ta_queue_ios
//
//  Created by Parker Wightman on 7/6/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import "URError.h"

@implementation URError

+ (NSError *) initWithMessage:(NSString *)string {
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    [details setValue:string forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:@"world" code:200 userInfo:details];

    return error;
}

+ (NSError *) initWithErrorAttributes:(NSDictionary *)string {

    
    return nil;
}

@end
