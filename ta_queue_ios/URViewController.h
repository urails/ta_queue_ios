//
//  URViewController.h
//  ta_queue_ios
//
//  Created by Parker Wightman on 4/25/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URLoginNetworkManager.h"

@interface URViewController : UITableViewController <URLoginNetworkManagerDelegate>

@property (nonatomic, retain) NSArray* schools;
@property (strong) URLoginNetworkManager *networkManager;

@end
