//
//  URSchoolSettingsViewController.h
//  ta_queue_ios
//
//  Created by Parker Wightman on 7/17/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URAboutViewController.h"

@interface URSchoolSettingsViewController : UITableViewController <URAboutViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *baseURLField;
@property (strong, nonatomic) void (^finishedCallback)(URSchoolSettingsViewController *controller);

@end