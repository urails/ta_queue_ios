//
//  URAboutViewController.h
//  ta_queue_ios
//
//  Created by Parker Wightman on 8/3/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@protocol URAboutViewControllerDelegate;

@interface URAboutViewController : UIViewController <MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) id<URAboutViewControllerDelegate> delegate;
@end

@protocol URAboutViewControllerDelegate <NSObject>

- (void) aboutViewControllerDidFinish:(URAboutViewController *)controller;

@end
