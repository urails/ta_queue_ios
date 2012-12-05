//
//  URTa.h
//  ta_queue_ios
//
//  Created by Parker Wightman on 5/4/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URUser.h"
#import "URStudent.h"

@interface URTa : URUser

@property (strong, nonatomic) URStudent *student;
@property (strong, nonatomic) UIColor *color;

+ (UIColor *)colorForIndex:(NSInteger)index;

@end
