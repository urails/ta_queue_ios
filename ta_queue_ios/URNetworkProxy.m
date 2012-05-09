//
//  URNetworkProxy.m
//  ta_queue_ios
//
//  Created by Parker Wightman on 5/7/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import "URNetworkProxy.h"

@implementation URNetworkProxy

@synthesize delegate;

- (void) request:(RKRequest *)request didFailLoadWithError:(NSError *)error {
    
}

- (void) request:(RKRequest *)request didLoadResponse:(RKResponse *)response {
    [delegate networkProxy:self returnedResponse:response];
}

@end
