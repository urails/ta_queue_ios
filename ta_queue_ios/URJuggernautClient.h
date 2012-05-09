//
//  URJuggernautClient.h
//  ta_queue_ios
//
//  Created by Parker Wightman on 5/6/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import <Foundation/Foundation.h>

@class URJuggernautClient;

@protocol URJuggernautClientDelegate

- (void) juggernautClient:(URJuggernautClient*)client didRecieveData:(NSString*) string;

@end

@interface URJuggernautClient : NSObject <UIWebViewDelegate>

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) NSString* connectionString;

- (id) initWithURLString:(NSString*) url;

@end
