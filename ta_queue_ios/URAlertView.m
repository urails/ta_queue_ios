//
//  URAlertView.m
//  ta_queue_ios
//
//  Created by Parker Wightman on 7/6/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import "URAlertView.h"

@interface URAlertView ()

@property (nonatomic, strong) void (^okBlock)(UIAlertView *alertView, NSString * text);
@property (nonatomic, strong) void (^cancelBlock)(UIAlertView *alertView);

@end

@implementation URAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (void) showMessage:(NSString *)message
           withStyle:(UIAlertViewStyle)style
                  ok:(void (^)(UIAlertView *alertView, NSString *text))okBlock
              cancel:(void (^)(UIAlertView *alertView))cancelBlock {
     
    URAlertView *alertView = nil;
    
    if (style == UIAlertViewStyleDefault) {
        alertView = [[URAlertView alloc] initWithTitle:@"Friendly Message" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    } else {
        alertView = [[URAlertView alloc] initWithTitle:@"Friendly Message" message:message delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    }
    
    alertView.delegate = alertView;
    alertView.alertViewStyle = style;
    
    alertView.okBlock = okBlock;
    alertView.cancelBlock = cancelBlock;
    
    [alertView show];
}

+ (void) showMessage:(NSString *)message {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
														message:message
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[alertView show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if (_cancelBlock) {
            _cancelBlock(alertView);
        }
    } else {
        if (_okBlock) {
            _okBlock(alertView, [alertView textFieldAtIndex:0].text);
        }
    }
}

- (void) alertViewCancel:(UIAlertView *)alertView {
    if (_cancelBlock) {
        _cancelBlock(alertView);
    }
}

@end
