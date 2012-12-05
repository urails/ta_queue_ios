//
//  URTa.m
//  ta_queue_ios
//
//  Created by Parker Wightman on 5/4/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import "URTa.h"

@implementation URTa

@synthesize student = _student;
@synthesize color = _color;

- (BOOL) isTa {
    return YES;
}

- (BOOL) isStudent {
    return NO;
}

+ (UIColor *)colorForIndex:(NSInteger)index {
	return [[self colors] objectAtIndex:index % [self colors].count];
}

+ (NSArray *) colors {
	static NSArray *colors = nil;
	
	if (!colors) {
		colors = @[
			[UIColor colorWithRed:1.00 green:0.85 blue:0.42 alpha:0.3],
			[UIColor colorWithRed:0.87 green:0.53 blue:0.51 alpha:0.3],
			[UIColor colorWithRed:0.51 green:0.69 blue:0.89 alpha:0.3],
			[UIColor colorWithRed:0.87 green:0.53 blue:0.67 alpha:0.3],
			[UIColor colorWithRed:0.52 green:0.86 blue:0.88 alpha:0.3],
			[UIColor colorWithRed:0.86 green:0.53 blue:0.89 alpha:0.3],
			[UIColor colorWithRed:0.52 green:0.52 blue:0.89 alpha:0.3]
		];
	}
	
	return colors;
}

@end
