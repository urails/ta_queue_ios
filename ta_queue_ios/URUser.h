//
//  URUser.h
//  ta_queue_ios
//
//  Created by Parker Wightman on 5/4/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URObject.h"

@interface URUser : URObject

@property (nonatomic, retain) NSString* username;
@property (nonatomic, retain) NSString* userId;
@property (nonatomic, retain) NSString* token;
@property (nonatomic, retain) NSString* location;

- (BOOL) isStudent;
- (BOOL) isTa;

+ (URUser*) currentUser;
+ (void) setCurrentUser:(URUser*)user;

@end
