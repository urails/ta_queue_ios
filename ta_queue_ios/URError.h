//
//  URError.h
//  ta_queue_ios
//
//  Created by Parker Wightman on 7/6/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URError : NSError

+ (NSError *) initWithMessage:(NSString*)string;

@end
