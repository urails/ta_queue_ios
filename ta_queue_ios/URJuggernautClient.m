//
//  URJuggernautClient.m
//  ta_queue_ios
//
//  Created by Parker Wightman on 5/6/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import "URJuggernautClient.h"

@implementation URJuggernautClient

@synthesize webView, connectionString;

- (id) initWithURLString:(NSString*) url {
    self = [super init];
    
    if (self) {
        webView = [[UIWebView alloc] init];
        
        connectionString = url;

        
        NSLog(@"Loading URL: %@", url);
        
        [webView setDelegate:self];
    }
    
    return self;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"Received Juggernaut Data: %@", request.URL.path);
    
    if ([request.URL.path isEqualToString:connectionString]) {
        NSLog(@"Returning YES");
        
        return YES;
    }
    
    return NO;
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
//    NSLog(@"Web View failed to load %@", error);
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
//    NSLog(@"Web View finished loading page: %@", webView);
}


@end
