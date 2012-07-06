//
//  URInstructor.h
//  ta_queue_ios
//
//  Created by Parker Wightman on 5/4/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URSchool.h"
#import "URObject.h"

@interface URInstructor : URObject {
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSArray  *queues;
@property (nonatomic, retain) URSchool *school;

@end
