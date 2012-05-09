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

@interface URLoginViewController : UITableViewController <UITextFieldDelegate, RKRequestDelegate>

#pragma mark IBOutlets

@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *locationField;
@property (strong, nonatomic) IBOutlet UISegmentedControl *typeControl;
@property (strong, nonatomic) RKClient* client;

#pragma mark  Properties

@property (nonatomic, retain) URQueue* schoolQueue;

#pragma mark IBAction methods

- (IBAction)loginTapped:(id)sender;
- (void) logout:(URUser*)user;

@end
