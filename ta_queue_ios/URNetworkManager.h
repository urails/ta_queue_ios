//
//  URNetworkManager.h
//  ta_queue_ios
//
//  Created by Parker Wightman on 5/7/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URQueue.h"
#import "URStudent.h"
#import "URNetworkProxy.h"

@class URNetworkManager;

@protocol URNetworkManagerDelegate

- (void) networkManager:(URNetworkManager*) manager updatedQueue:(URQueue*) updatedQueue;

@end

@interface URNetworkManager : NSObject <RKRequestDelegate, URNetworkProxyDelegate>

@property (nonatomic, retain) RKClient *client;
@property (nonatomic, assign) NSObject<URNetworkManagerDelegate> *delegate;
@property (nonatomic, retain) NSString* userId;
@property (nonatomic, retain) NSString* token;
@property (nonatomic, retain) URNetworkProxy *proxy;

- (id) initWithId:(NSString*) userId andToken:(NSString*) token;

+ (URNetworkManager*) sharedManager;
+ (void) setSharedManager:(URNetworkManager*) manager;

#pragma mark URQueue methods

- (void) updateQueue;
- (void) enterQueue;
- (void) exitQueue;
- (void) updateQueueAttributes:(NSDictionary*) attributes;

#pragma mark URStudent methods

- (void) acceptStudent:(URStudent*) student;
- (void) removeStudent:(URStudent*) student;

@end
