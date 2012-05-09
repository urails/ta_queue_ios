//
//  URSchool.h
//  ta_queue_ios
//
//  Created by Parker Wightman on 5/4/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URObject.h"

@interface URSchool : URObject <RKRequestDelegate> {
    NSArray  *_aggregatedQueues;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *abbreviation;
@property (nonatomic, retain) NSArray  *instructors;


+ (RKObjectMapping*) mapping;

- (NSArray*) aggregatedQueues;

@end
