//
//  URAlertView.h
//  ta_queue_ios
//
//  Created by Parker Wightman on 7/6/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface URAlertView : UIAlertView <UIAlertViewDelegate>

+ (void) showMessage:(NSString *)message
           withStyle:(UIAlertViewStyle)style
                  ok:(void (^)(UIAlertView *alertView, NSString *text))okBlock
              cancel:(void (^)(UIAlertView *alertView))cancelBlock;

+ (void) showMessage:(NSString *)message;

@end
