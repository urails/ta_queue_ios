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

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, assign, getter = isActive) BOOL active;
@property (nonatomic, assign, getter = isFrozen) BOOL frozen;
@property (nonatomic, strong) NSString *classNumber;
@property (nonatomic, assign, getter = isQuestionBased) BOOL questionBased;
@property (nonatomic, strong) NSArray  *students;
@property (nonatomic, strong) NSArray  *studentsInQueue;
@property (nonatomic, strong) NSArray  *tas;
@property (nonatomic, strong) NSArray  *users;
@property (nonatomic, strong) URInstructor* instructor;
@property (nonatomic, strong) URUser* currentUser;

+ (URQueue*) sharedQueue;

- (URTa *)taWithID:(NSString *)userID;
- (URStudent *)studentWithID:(NSString *)userID;
- (URUser *)userWithID:(NSString *)userID;

@end
