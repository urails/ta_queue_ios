//
//  URStudent.m
//  ta_queue_ios
//
//  Created by Parker Wightman on 5/4/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import "URStudent.h"

@implementation URStudent

@synthesize inQueue, taId, question;

- (void) mapLoginResponse:(NSDictionary *)response {
    
}

- (void) parse:(NSDictionary *)attributes {
    taId = [attributes valueForKey:@"ta_id"];
    question = [attributes valueForKey:@"question"];
    inQueue = [attributes valueForKey:@"in_queue"];
    
    [super parse:attributes];
}

- (BOOL) isTa {
    return NO;
}

- (BOOL) isStudent {
    return YES;
}

@end
