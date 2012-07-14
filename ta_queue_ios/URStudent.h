//
//  URStudent.h
//  ta_queue_ios
//
//  Created by Parker Wightman on 5/4/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URUser.h"

@class URTa;

@interface URStudent : URUser

@property (nonatomic, strong) NSString* question;
@property (nonatomic, assign) BOOL inQueue;
@property (nonatomic, strong) NSString* taId;
@property (nonatomic, strong) URTa *ta;

@end
