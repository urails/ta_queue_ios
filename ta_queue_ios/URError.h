//
//  URError.h
//  ta_queue_ios
//
//  Created by Parker Wightman on 7/6/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URError : NSObject

/*
 
 Error messages come in as JSON like so:
 
 {
    errors: [
        "Some error",
        "Another error"
    ]
 }
 
 Calling errorMessageWithResponse: will parse the array into a single string, each message
 separated by a new line.
 
 */
+ (NSString *) errorMessageWithResponse:(NSDictionary *)dictionary;

@end
