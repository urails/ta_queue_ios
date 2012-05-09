//
//  URSchool.m
//  ta_queue_ios
//
//  Created by Parker Wightman on 5/4/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import "URSchool.h"
#import "URInstructor.h"
#import "URQueue.h"

@implementation URSchool 

@synthesize name;
@synthesize abbreviation;
@synthesize instructors;

- (id) init {
    self = [super init];
    if (self) {
        _aggregatedQueues = nil;
    }
    
    return self;
}

- (NSArray*) aggregatedQueues {
    
    if (!_aggregatedQueues) {
        _aggregatedQueues = [[NSMutableArray alloc] init];
        for (URInstructor* instructor in self.instructors) {
            instructor.school = self;
            for (URQueue *queue in instructor.queues) {
                queue.instructor = instructor;
            }
            _aggregatedQueues = [_aggregatedQueues arrayByAddingObjectsFromArray:instructor.queues];
        }
    }
    
    return _aggregatedQueues;
}

- (void) parse:(NSDictionary*)attributes {
    name = [attributes valueForKey:@"name"];
    abbreviation = [attributes valueForKey:@"abbreviation"];
    
    if ([attributes valueForKey:@"instructors"]) {
        NSMutableArray* _instructors = [NSMutableArray arrayWithCapacity:3];
        for (NSDictionary *instructor in [attributes valueForKey:@"instructors"]) {
            [_instructors addObject:[URInstructor withAttributes:instructor]];
        }
        instructors = _instructors;
    }
}

//+ (id) withAttributes:(NSDictionary *)attributes {
//    URSchool* school = [[URSchool alloc] init];
//    [school parse:attributes];
//    
//    return school;
//}

+ (RKObjectMapping*) mapping {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[URSchool class]];
    
    [mapping mapAttributes:@"name", @"abbreviation", nil];
    [mapping setSetNilForMissingRelationships:YES];
    [mapping hasMany:@"instructors" withMapping:[URInstructor mapping]];
    
    return mapping;
}

@end
