//
//  URLoginViewController.h
//  ta_queue_ios
//
//  Created by Parker Wightman on 5/4/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URQueue.h"
#import "URUser.h"
#import "URLoginNetworkManager.h"
#import "URQueueViewController.h"

@interface URLoginViewController : UIViewController <UITextFieldDelegate, URLoginNetworkManagerDelegate, URQueueViewControllerDelegate>

#pragma mark IBOutlets

@property (strong) IBOutlet UITextField *nameField;
@property (strong) IBOutlet UITextField *locationField;
@property (strong) IBOutlet UISegmentedControl *typeControl;

#pragma mark  Properties

@property (strong) URQueue *schoolQueue;
@property (strong) URLoginNetworkManager *networkManager;
@property (assign) URUser *loggedInUser;

#pragma mark IBAction methods

- (IBAction)loginTapped:(id)sender;

@end
