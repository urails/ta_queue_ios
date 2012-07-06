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
#import "URQueueNetworkManager.h"

@protocol URQueueViewControllerDelegate;

@interface URQueueViewController : UITableViewController <URQueueNetworkManagerDelegate>

@property (strong) URQueue *queue;
@property (assign) URUser *currentUser;
@property (strong) NSTimer *timer;
@property (strong) URQueueNetworkManager *networkManager;
@property (assign) NSObject<URQueueViewControllerDelegate> *delegate;

- (void) refreshTimerFired:(NSTimer*)timer;

- (void) acceptTapped:(id)sender;
- (void) removeTapped:(id)sender;

@end

@protocol URQueueViewControllerDelegate <NSObject>

- (void) queueViewController:(URQueueViewController *)controller didLogoutUser:(URUser *)user;
                              
@end
