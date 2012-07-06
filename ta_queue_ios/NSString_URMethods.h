//
//  NSString_URMethods.h
//  ta_queue_ios
//
//  Created by Parker Wightman on 7/6/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URMethods)

- (NSString *) formalizedString;

@end

@implementation NSString (URMethods)

- (NSString *) formalizedString {
    NSString *newString = [self capitalizedString];
    newString = [newString stringByReplacingOccurrencesOfString:@"_" 
                                                     withString:@" "];
    
    return newString;
}

@end
