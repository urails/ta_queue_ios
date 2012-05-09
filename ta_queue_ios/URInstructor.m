//
//  URInstructor.m
//  ta_queue_ios
//
//  Created by Parker Wightman on 5/4/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import "URInstructor.h"
#import "URQueue.h"

@implementation URInstructor
@synthesize name;
@synthesize username;
@synthesize queues;
@synthesize school;

+ (RKObjectMapping*) mapping {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[self class]];

    [mapping mapAttributes:@"name", @"username", nil];
    [mapping hasMany:@"queues" withMapping:[URQueue mapping]];
    [mapping setSetNilForMissingRelationships:YES];
    
    return mapping;
}

- (void) parse:(NSDictionary *)attributes {
    name = [attributes valueForKey:@"name"];
    username = [attributes valueForKey:@"username"];
    
    NSArray *_queues = [attributes valueForKey:@"queues"];
    
    if (_queues) {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:5];
        for (NSDictionary *queue in _queues) {
            [arr addObject:[URQueue withAttributes:queue]];
        }
        
        queues = arr;
    }
}

@end
