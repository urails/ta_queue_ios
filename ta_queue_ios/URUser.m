//
//  URUser.m
//  ta_queue_ios
//
//  Created by Parker Wightman on 5/4/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import "URUser.h"

@implementation URUser

@synthesize userId, token, username, location;

- (BOOL) isTa {
    return NO;
}

- (BOOL) isStudent {
    return NO;
}

- (void) parse:(NSDictionary *)attributes {
    location = [attributes valueForKey:@"location"];
    token = [attributes valueForKey:@"token"];
    username = [attributes valueForKey:@"username"];
    userId = [attributes valueForKey:@"id"];
}

static URUser* _currentUser = nil;

+ (URUser*) currentUser {
    return _currentUser;
}

+ (void) setCurrentUser:(URUser *)user {
    _currentUser = user;
}


@end
