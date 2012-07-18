//
//  URLoginNetworkManager.h
//  ta_queue_ios
//
//  Created by Parker Wightman on 7/6/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVHTTPClient.h"
#import "URQueue.h"

@protocol URLoginNetworkManagerDelegate;

@interface URLoginNetworkManager : NSObject

@property (strong) NSObject<URLoginNetworkManagerDelegate> *delegate;

- (void) fetchSchools;
- (void) loginStudentWithUsername:(NSString *)username andLocation:(NSString *)location toQueue:(URQueue *)queue;
- (void) loginTaWithUsername:(NSString *)username andPassword:(NSString *)password toQueue:(URQueue *)queue;
- (void) setBasePath:(NSString *)basePath;
- (void) refreshBasePath;

@end







@protocol URLoginNetworkManagerDelegate <NSObject>

@optional

- (void) networkManager:(URLoginNetworkManager *)manager didFetchSchools:(NSArray *)schools;
- (void) networkManager:(URLoginNetworkManager *)manager didLoginUser:(URUser *)user;
- (void) networkManager:(URLoginNetworkManager *)manager didReceiveErrorCode:(NSInteger)code response:(id)response;
- (void) networkManager:(URLoginNetworkManager *)manager didReceiveConnectionError:(NSString *)error;

@end