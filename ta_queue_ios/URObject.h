//
//  URObject.h
//  ta_queue_ios
//
//  Created by Parker Wightman on 5/4/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URObject : NSObject

@end

@interface URObject (Abstract)

+ (id) withAttributes:(NSDictionary*) attributes;
- (void) parse:(NSDictionary*) attributes;

@end
