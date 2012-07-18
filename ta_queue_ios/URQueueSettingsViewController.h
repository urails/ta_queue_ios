//
//  URQueueSettingsViewController.h
//  ta_queue_ios
//
//  Created by Parker Wightman on 7/18/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol URQueueSettingsViewControllerDelegate;

@interface URQueueSettingsViewController : UITableViewController

@property (weak, nonatomic) NSObject<URQueueSettingsViewControllerDelegate> *delegate;

@property (strong, nonatomic) IBOutlet UILabel *secondsLabel;

@end


@protocol URQueueSettingsViewControllerDelegate <NSObject>

- (void)settingsViewControllerDidFinish:(URQueueSettingsViewController *)controller;

@end