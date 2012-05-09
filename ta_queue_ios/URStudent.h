//
//  URStudent.h
//  ta_queue_ios
//
//  Created by Parker Wightman on 5/4/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URUser.h"

@interface URStudent : URUser

@property (nonatomic, retain) NSString* question;
@property (nonatomic, retain) NSNumber* inQueue;
@property (nonatomic, retain) NSString* taId;

@end
