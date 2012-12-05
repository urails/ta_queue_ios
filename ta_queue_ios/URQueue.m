//
//  URQueue.m
//  ta_queue_ios
//
//  Created by Parker Wightman on 5/4/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import "URQueue.h"
#import "URStudent.h"
#import "URTa.h"

@implementation URQueue

@synthesize title;
@synthesize status;
@synthesize active;
@synthesize frozen;
@synthesize classNumber;
@synthesize students;
@synthesize studentsInQueue;
@synthesize questionBased;
@synthesize tas;
@synthesize users;
@synthesize currentUser;
@synthesize instructor;

- (void) parse:(NSDictionary *)attributes {
    title = [attributes valueForKey:@"title"];
    status = [attributes valueForKey:@"status"];
    active = [[attributes valueForKey:@"active"] boolValue];
    questionBased = [[attributes valueForKey:@"is_question_based"] boolValue];
    frozen = [[attributes valueForKey:@"frozen"] boolValue];

    classNumber = [attributes valueForKey:@"class_number"];
    
    NSArray* _students = [attributes valueForKey:@"students"];
    
    if (_students) {
        NSMutableArray* arr = [NSMutableArray arrayWithCapacity:5];
        for (NSDictionary *dict in _students) {
            [arr addObject:[URStudent withAttributes:dict]];
        }
        
        students = arr;
    }
    
    NSArray* _tas = [attributes valueForKey:@"tas"];
    
    if (_tas) {
        NSMutableArray* arr = [NSMutableArray arrayWithCapacity:5];
        for (NSInteger i = 0; i < _tas.count; i++) {
			NSDictionary *dict = [_tas objectAtIndex:i];
            [arr addObject:[URTa withAttributes:dict]];
			[[arr lastObject] setColor:[URTa colorForIndex:i]];
        }
        
        tas = arr;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject inQueue];
    }];
    
    studentsInQueue = [students filteredArrayUsingPredicate:predicate];
    
    users = [tas arrayByAddingObjectsFromArray:students];
    
    predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [[URUser currentUser].userId isEqualToString:[evaluatedObject userId]];
    }];
    
    currentUser = [[users filteredArrayUsingPredicate:predicate] objectAtIndex:0];
    
    // Hydrate TAs' student association
    
    for (URStudent *student in students) {
        if (student.taId) {

            predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                return [[evaluatedObject userId] isEqualToString:student.taId];
            }];
            
            NSArray *matchingTas = [tas filteredArrayUsingPredicate:predicate];
            
            URTa *ta = [matchingTas objectAtIndex:0];
            
            ta.student = student;
            student.ta = ta;
        }
    }
}

- (URTa *)taWithID:(NSString *)userID {
    return nil;
}
- (URStudent *)studentWithID:(NSString *)userID {
    return nil;
}
- (URUser *)userWithID:(NSString *)userID {
    return nil;
}

static URQueue *_sharedQueue = nil;

+ (URQueue*) sharedQueue {
    if (!_sharedQueue) {
        _sharedQueue = [[URQueue alloc] init];
    }
    
    return _sharedQueue;
}

+ (void) setSharedQueue:(URQueue*) queue {
    _sharedQueue = queue;
}
@end
