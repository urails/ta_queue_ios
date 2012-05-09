//
//  URObject.m
//  ta_queue_ios
//
//  Created by Parker Wightman on 5/4/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import "URObject.h"

@implementation URObject

+ (id) withAttributes:(NSDictionary *)attributes {
    id obj = [[[self class] alloc] init];
    
    [obj parse:attributes];
    
    return obj;
}

@end
