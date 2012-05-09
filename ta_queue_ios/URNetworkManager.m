//
//  URNetworkManager.m
//  ta_queue_ios
//
//  Created by Parker Wightman on 5/7/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import "URNetworkManager.h"

@implementation URNetworkManager

@synthesize delegate, client, userId, token, proxy;

- (id) initWithId:(NSString*) userId andToken:(NSString*) token {
    
    self = [super init];
    
    if (self) {
        self.proxy = [[URNetworkProxy alloc] init];
        [self.proxy setDelegate:self];
        
        self.userId = userId;
        self.token = token;
        
        client = [RKClient clientWithBaseURLString:gBaseUrl];
        client.username = userId;
        client.password = token;
        client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    }
    
    return self;
}

static URNetworkManager *_sharedNetworkManager = nil;
+ (URNetworkManager*) sharedManager {
    if (!_sharedNetworkManager) {
        _sharedNetworkManager = [[URNetworkManager alloc] init];
    }
    
    return _sharedNetworkManager;
}

+ (void) setSharedManager:(URNetworkManager*) manager {
    _sharedNetworkManager = manager;
}

#pragma mark URQueue methods

- (void) updateQueue {
    [client get:@"/queue" delegate:self];
}

- (void) enterQueue {
    [client get:@"/queue/enter_queue" delegate:self];
}

- (void) exitQueue {
    [client get:@"/queue/exit_queue" delegate:self];
}

- (void) updateQueueAttributes:(NSDictionary*) attributes {
    [client put:@"/queue" params:attributes delegate:proxy];
}

#pragma mark URStudent methods

- (void) acceptStudent:(URStudent*) student {
    [client get:[NSString stringWithFormat:@"/students/%@/ta_accept", student.userId] delegate:proxy];
}
- (void) removeStudent:(URStudent*) student {
    [client get:[NSString stringWithFormat:@"/students/%@/ta_remove", student.userId] delegate:proxy];
}

#pragma mark RKRequestDelegate methods

/**
 Sent when a request has finished loading
 
 @param request The RKRequest object that was handling the loading.
 @param response The RKResponse object containing the result of the request.
 */
- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response {
    URQueue *queue = [URQueue withAttributes:[response parsedBody:nil]];
    [delegate networkManager:self updatedQueue:queue];
}

/**
 Sent when a request has failed due to an error
 
 @param request The RKRequest object that was handling the loading.
 @param error An NSError object containing the RKRestKitError that triggered
 the callback.
 */
- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error {
    
}

#pragma mark URNetworkProxy

- (void) networkProxy:(URNetworkProxy *)proxy returnedResponse:(RKResponse *)response {
    [self updateQueue];
}


@end
