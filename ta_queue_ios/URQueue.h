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

@interface URQueue : URObject {

}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSNumber *active;
@property (nonatomic, retain) NSNumber *frozen;
@property (nonatomic, retain) NSString *classNumber;
@property (nonatomic, retain) NSArray  *students;
@property (nonatomic, retain) NSArray  *studentsInQueue;
@property (nonatomic, retain) NSArray  *tas;
@property (nonatomic, retain) NSArray  *users;
@property (nonatomic, retain) URInstructor* instructor;
@property (nonatomic, retain) URUser* currentUser;

+ (RKObjectMapping*) mapping;
+ (URQueue*) sharedQueue;

- (void) invalidate;

@end
