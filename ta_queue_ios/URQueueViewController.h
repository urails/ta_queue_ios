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

@interface URQueueViewController : UIViewController <URQueueNetworkManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong) URQueue *queue;
@property (strong) URUser *currentUser;
@property (strong) URQueueNetworkManager *networkManager;
@property (copy, nonatomic) void (^didFinish)();

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;

- (void) setupUserActionToolbar;
- (void) refreshQueue;

+ (URQueueViewController*) currentQueueController;
+ (void) setCurrentQueueController:(URQueueViewController *)queueController;


@end