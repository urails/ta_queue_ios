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
#import "URQueueSettingsViewController.h"

@protocol URQueueViewControllerDelegate;

@interface URQueueViewController : UIViewController <URQueueNetworkManagerDelegate, URQueueSettingsViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong) URQueue *queue;
@property (assign) URUser *currentUser;
@property (strong) NSTimer *timer;
@property (strong) URQueueNetworkManager *networkManager;
@property (assign) NSObject<URQueueViewControllerDelegate> *delegate;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;

- (void) setupUserActionToolbar;
- (void) refreshQueue;

+ (URQueueViewController*) currentQueueController;
+ (void) setCurrentQueueController:(URQueueViewController *)queueController;


@end

@protocol URQueueViewControllerDelegate <NSObject>

- (void) queueViewController:(URQueueViewController *)controller didLogoutUser:(URUser *)user;
                              
@end
