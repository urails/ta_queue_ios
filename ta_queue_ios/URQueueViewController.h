//
//  URQueueViewController.h
//  ta_queue_ios
//
//  Created by Parker Wightman on 5/4/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URUser.h"
#import "URQueue.h"
#import "URStudent.h"
#import "URTa.h"
#import "URNetworkManager.h"

@interface URQueueViewController : UITableViewController <URNetworkManagerDelegate, UINavigationBarDelegate>

@property (nonatomic, retain) URQueue *queue;
@property (nonatomic, retain) URUser *currentUser;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) URNetworkManager *networkManager;

- (void) refreshTimerFired:(NSTimer*)timer;

- (void) acceptTapped:(id)sender;
- (void) removeTapped:(id)sender;

- (UITableViewCell*) cellForIndexPath:(NSIndexPath*) indexPath;

@end
