//
//  URQueue.h
//  ta_queue_ios
//
//  Created by Parker Wightman on 5/4/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URInstructor.h"
#import "URObject.h"
#import "URUser.h"

@class URTa;
@class URStudent;

@interface URQueue : URObject 

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, assign) BOOL frozen;
@property (nonatomic, retain) NSString *classNumber;
@property (nonatomic, retain) NSArray  *students;
@property (nonatomic, retain) NSArray  *studentsInQueue;
@property (nonatomic, retain) NSArray  *tas;
@property (nonatomic, retain) NSArray  *users;
@property (nonatomic, retain) URInstructor* instructor;
@property (nonatomic, retain) URUser* currentUser;

+ (URQueue*) sharedQueue;

- (URTa *)taWithID:(NSString *)userID;
- (URStudent *)studentWithID:(NSString *)userID;
- (URUser *)userWithID:(NSString *)userID;

@end
