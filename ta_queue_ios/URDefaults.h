//
//  URDefaults.h
//  ta_queue_ios
//
//  Created by Parker Wightman on 7/17/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URDefaults : NSObject

+ (NSString *)currentBaseURL;
+ (void)setCurrentBaseURL:(NSString *)baseURL;

+ (NSUInteger)currentQueryInterval;
+ (void)setCurrentQueryInterval:(NSUInteger)interval;

+ (NSString *)username;
+ (void)setUsername:(NSString *)username;

+ (NSString *)location;
+ (void)setLocation:(NSString *)location;

@end
