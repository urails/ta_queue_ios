//
//  URSchoolSettingsViewController.h
//  ta_queue_ios
//
//  Created by Parker Wightman on 7/17/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol URSchoolSettingsViewControllerDelegate;

@interface URSchoolSettingsViewController : UITableViewController

@property (weak) NSObject<URSchoolSettingsViewControllerDelegate> *delegate;
@property (strong, nonatomic) IBOutlet UITextField *baseURLField;

@end

@protocol URSchoolSettingsViewControllerDelegate <NSObject>

- (void)settingsViewControllerDidFinish:(URSchoolSettingsViewController *)controller;

@end