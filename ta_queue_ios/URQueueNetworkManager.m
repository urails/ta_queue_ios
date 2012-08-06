//
//  URQueueNetworkManager.m
//  ta_queue_ios
//
//  Created by Parker Wightman on 7/6/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import "URQueueNetworkManager.h"
#import "SVHTTPClient.h"
#import "URDefaults.h"

@interface URQueueNetworkManager ()

@property (strong) URQueue *queue;
@property (strong) URUser *user;
@property (strong) SVHTTPClient *client;

- (void) makeRequest:(URRequestType)type urlString:(NSString *)url withParams:(NSDictionary *)params completion:(void (^)(id response, NSHTTPURLResponse *urlResponse, NSError *error))completionBlock;

@end

@implementation URQueueNetworkManager

@synthesize queue = _queue;
@synthesize user = _user;
@synthesize client = _client;
@synthesize loading = _loading;
@synthesize delegate = _delegate;

- (id) initWithQueue:(URQueue *)queue andUser:(URUser *)user {
    self = [super init];

    if (self) {
        _queue = queue;
        _user = user;
        
        _client = [[SVHTTPClient alloc] init];
        
        [_client setBasePath:[URDefaults currentBaseURL]];
        
        _client.sendParametersAsJSON = YES;
        
        _client.username = user.userId;
        _client.password = user.token;
    }
    
    return self;
}

- (void) makeRequest:(URRequestType)type urlString:(NSString *)url 
          withParams:(NSDictionary *)params 
          completion:(void (^)(id, NSHTTPURLResponse *, NSError *))completionBlock {

    if (_loading) {
        return;
    }
    
    self.loading = YES;
    
    if (type == URRequestTypeGET) {
        [_client GET:url 
          parameters:params 
          completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
            [self finishRequestWithResponse:response 
                                urlResponse:urlResponse 
                                      error:error 
                              andCompletion:completionBlock];
        }];
    } else if (type == URRequestTypePOST) {
        [_client POST:url 
           parameters:params 
           completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
            [self finishRequestWithResponse:response 
                                urlResponse:urlResponse 
                                      error:error 
                              andCompletion:completionBlock];
        }];
    } else if (type == URRequestTypePUT) {
        [_client PUT:url 
          parameters:params 
          completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
            [self finishRequestWithResponse:response 
                                urlResponse:urlResponse 
                                      error:error 
                              andCompletion:completionBlock];
        }];
    } else if (type == URRequestTypeDELETE) {
        [_client DELETE:url 
             parameters:params 
             completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
            [self finishRequestWithResponse:response 
                                urlResponse:urlResponse 
                                      error:error 
                              andCompletion:completionBlock];
        }];
    }
}

- (void) finishRequestWithResponse:(id)response 
                       urlResponse:(NSHTTPURLResponse *)urlResponse 
                             error:(NSError *)error 
                     andCompletion:(void (^)(id, NSHTTPURLResponse *, NSError *))completionBlock {
    self.loading = NO;
    if (error) {
        [_delegate networkManager:self didReceiveConnectionError:error];
    } else if (urlResponse.statusCode >= 400) {
        [_delegate networkManager:self didReceiveErrorCode:urlResponse.statusCode response:response];
    } else {
        completionBlock(response, urlResponse, nil);
    }
}

#pragma mark Student Actions
- (void) enterQueue {
    [self enterQueueWithQuestion:nil];
}

- (void) enterQueueWithQuestion:(NSString *)question {
    NSDictionary *params = nil;
    
    if (question) {
        params = @{ @"question": question };
    }

    [self makeRequest:URRequestTypeGET urlString:@"/queue/enter_queue" withParams:params completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        self.queue = [URQueue withAttributes:response];
        [_delegate networkManager:self didReceiveQueueUpdate:self.queue];
    }];
}

- (void) exitQueue {
    [self makeRequest:URRequestTypeGET urlString:@"/queue/exit_queue" withParams:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        self.queue = [URQueue withAttributes:response];
        [_delegate networkManager:self didReceiveQueueUpdate:self.queue];
    }];
}

#pragma mark TA Actions

- (void) acceptStudent:(URStudent *)student {
    NSString* url = [NSString stringWithFormat:@"/students/%@/ta_accept", student.userId];
    
    [self makeRequest:URRequestTypeGET urlString:url withParams:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        [self refreshQueue];
    }];
}

- (void) removeStudent:(URStudent *)student {
    NSString* url = [NSString stringWithFormat:@"/students/%@/ta_remove", student.userId];
    
    [self makeRequest:URRequestTypeGET urlString:url withParams:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        [self refreshQueue];
    }];
}

- (void) putBackStudent:(URStudent *)student {
    NSString* url = [NSString stringWithFormat:@"/students/%@/ta_putback", student.userId];
    
    [self makeRequest:URRequestTypeGET urlString:url withParams:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        [self refreshQueue];
    }];
}

- (void) updateQueueStatus:(NSString *)status {
    NSString *url = @"/queue";
    
    NSDictionary *params = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:status forKey:@"status"] forKey:@"queue"];
    
    [self makeRequest:URRequestTypePUT urlString:url withParams:params completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        [self refreshQueue];
    }];
}

#pragma mark Queue Actions
- (void) refreshQueue {
    [self makeRequest:URRequestTypeGET urlString:@"/queue" withParams:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        self.queue = [URQueue withAttributes:response];
        [_delegate networkManager:self didReceiveQueueUpdate:self.queue];
    }];
}

- (void) toggleFrozen {
    BOOL frozen = !_queue.frozen;
    NSDictionary *params = [NSDictionary dictionaryWithObject:
                            [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:frozen] 
                                                        forKey:@"frozen"] 
                                                       forKey:@"queue"];
    [self makeRequest:URRequestTypePUT urlString:@"/queue" withParams:params completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        [self refreshQueue];
    }];
    
    
}

- (void) toggleActive {
    BOOL active = !_queue.active;
    NSDictionary *params = [NSDictionary dictionaryWithObject:
                            [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:active] 
                                                        forKey:@"active"] 
                                                       forKey:@"queue"];
    [self makeRequest:URRequestTypePUT urlString:@"/queue" withParams:params completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        [self refreshQueue];
    }];
}

- (void) logout {
    NSString *userType = ([_user isTa] ? @"tas" : @"students");
    NSString *url = [NSString stringWithFormat:@"/%@/%@", userType, _user.userId];
    
    [self makeRequest:URRequestTypeDELETE urlString:url withParams:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (urlResponse.statusCode == 204) {
            [_delegate networkManager:self didLogoutUser:_user];
        }
    }];
}



@end
