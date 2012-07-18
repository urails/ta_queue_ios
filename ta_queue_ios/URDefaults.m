//
//  URDefaults.m
//  ta_queue_ios
//
//  Created by Parker Wightman on 7/17/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import "URDefaults.h"

#define UR_BASE_URL_KEY @"baseURL"
#define UR_QUERY_INTERVAL_KEY @"queryInterval"

#if IS_LOCAL
    #define UR_DEFAULT_BASE_URL @"http://localhost:3000"
#else
    #define UR_DEFAULT_BASE_URL @"http://nine.eng.utah.edu"
#endif

#define UR_DEFAULT_QUERY_INTERVAL 30

@implementation URDefaults

+ (NSString *)currentBaseURL {
    NSString *baseURL;
    if ( (baseURL = [[NSUserDefaults standardUserDefaults] objectForKey:UR_BASE_URL_KEY]) ) {
        return baseURL;
    } else {
        return UR_DEFAULT_BASE_URL;
    }
}

+ (void)setCurrentBaseURL:(NSString *)baseURL {
    [[NSUserDefaults standardUserDefaults] setObject:baseURL
                                              forKey:UR_BASE_URL_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSUInteger)currentQueryInterval {
    NSNumber *queryInterval = nil;
    if ( (queryInterval = [[NSUserDefaults standardUserDefaults] objectForKey:UR_QUERY_INTERVAL_KEY]) ) {
        return [queryInterval unsignedIntValue];
    } else {
        return UR_DEFAULT_QUERY_INTERVAL;
    }
}

+ (void)setCurrentQueryInterval:(NSUInteger)interval {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedInteger:interval]
                                              forKey:UR_QUERY_INTERVAL_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
