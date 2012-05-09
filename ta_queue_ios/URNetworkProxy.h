//
//  URNetworkProxy.h
//  ta_queue_ios
//
//  Created by Parker Wightman on 5/7/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import <Foundation/Foundation.h>

@class URNetworkProxy;

@protocol URNetworkProxyDelegate

- (void) networkProxy:(URNetworkProxy*)proxy returnedResponse:(RKResponse*)response;

@end

@interface URNetworkProxy : NSObject <RKRequestDelegate>

@property (nonatomic, retain) NSObject<URNetworkProxyDelegate> *delegate;

@end
