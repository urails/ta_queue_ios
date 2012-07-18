//
//  URQueueNetworkManager.h
//  ta_queue_ios
//
//  Created by Parker Wightman on 7/6/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URQueue.h"
#import "URUser.h"
#import "URStudent.h"
#import "URTa.h"


typedef enum {
    URRequestTypeGET,
    URRequestTypePOST,
    URRequestTypePUT,
    URRequestTypeDELETE
} URRequestType;

@protocol URQueueNetworkManagerDelegate;

@interface URQueueNetworkManager : NSObject

- (id) initWithQueue:(URQueue *)queue andUser:(URUser *)user;

#pragma mark Student Actions
- (void) enterQueue;
- (void) exitQueue;

#pragma mark TA Actions
- (void) acceptStudent:(URStudent *)student;
- (void) removeStudent:(URStudent *)student;
- (void) putBackStudent:(URStudent *)student;
- (void) updateQueueStatus:(NSString *)status;

#pragma mark Queue Actions
- (void) refreshQueue;
- (void) toggleFrozen;
- (void) toggleActive;
- (void) logout;

@property (assign, atomic) BOOL loading;
@property (assign) NSObject<URQueueNetworkManagerDelegate> *delegate;

@end

@protocol URQueueNetworkManagerDelegate <NSObject>

- (void) networkManager:(URQueueNetworkManager *)manager didReceiveQueueUpdate:(URQueue *)queue;
- (void) networkManager:(URQueueNetworkManager *)manager didReceiveErrorCode:(NSInteger)code response:(id)response;
- (void) networkManager:(URQueueNetworkManager *)manager didReceiveConnectionError:(NSError *)error;
- (void) networkManager:(URQueueNetworkManager *)manager didLogoutUser:(URUser *)user;

@end
