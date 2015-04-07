//
//  URQueueNetworkManager.m
//  ta_queue_ios
//
//  Created by Parker Wightman on 7/6/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import "URQueueNetworkManager.h"
#import "URDefaults.h"

static NSString * const kAFCharactersToBeEscapedInQueryString = @":/?&=;+!@#$()',*";

static NSString * AFPercentEscapedQueryStringKeyFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    static NSString * const kAFCharactersToLeaveUnescapedInQueryStringPairKey = @"[].";

    return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, (__bridge CFStringRef)kAFCharactersToLeaveUnescapedInQueryStringPairKey, (__bridge CFStringRef)kAFCharactersToBeEscapedInQueryString, CFStringConvertNSStringEncodingToEncoding(encoding));
}

static NSString * AFPercentEscapedQueryStringValueFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, NULL, (__bridge CFStringRef)kAFCharactersToBeEscapedInQueryString, CFStringConvertNSStringEncodingToEncoding(encoding));
}

#pragma mark -

@interface AFQueryStringPair : NSObject
@property (readwrite, nonatomic, strong) id field;
@property (readwrite, nonatomic, strong) id value;

- (id)initWithField:(id)field value:(id)value;

- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding;
@end

@implementation AFQueryStringPair

- (id)initWithField:(id)field value:(id)value {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.field = field;
    self.value = value;

    return self;
}

- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding {
    if (!self.value || [self.value isEqual:[NSNull null]]) {
        return AFPercentEscapedQueryStringKeyFromStringWithEncoding([self.field description], stringEncoding);
    } else {
        return [NSString stringWithFormat:@"%@=%@", AFPercentEscapedQueryStringKeyFromStringWithEncoding([self.field description], stringEncoding), AFPercentEscapedQueryStringValueFromStringWithEncoding([self.value description], stringEncoding)];
    }
}

@end

#pragma mark -

extern NSArray * AFQueryStringPairsFromDictionary(NSDictionary *dictionary);
extern NSArray * AFQueryStringPairsFromKeyAndValue(NSString *key, id value);

static NSString * AFQueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding stringEncoding) {
    NSMutableArray *mutablePairs = [NSMutableArray array];
    for (AFQueryStringPair *pair in AFQueryStringPairsFromDictionary(parameters)) {
        [mutablePairs addObject:[pair URLEncodedStringValueWithEncoding:stringEncoding]];
    }

    return [mutablePairs componentsJoinedByString:@"&"];
}

NSArray * AFQueryStringPairsFromDictionary(NSDictionary *dictionary) {
    return AFQueryStringPairsFromKeyAndValue(nil, dictionary);
}

NSArray * AFQueryStringPairsFromKeyAndValue(NSString *key, id value) {
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];

    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(compare:)];

    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = value;
        // Sort dictionary keys to ensure consistent ordering in query string, which is important when deserializing potentially ambiguous sequences, such as an array of dictionaries
        for (id nestedKey in [dictionary.allKeys sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            id nestedValue = [dictionary objectForKey:nestedKey];
            if (nestedValue) {
                [mutableQueryStringComponents addObjectsFromArray:AFQueryStringPairsFromKeyAndValue((key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey), nestedValue)];
            }
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
        for (id nestedValue in array) {
            [mutableQueryStringComponents addObjectsFromArray:AFQueryStringPairsFromKeyAndValue([NSString stringWithFormat:@"%@[]", key], nestedValue)];
        }
    } else if ([value isKindOfClass:[NSSet class]]) {
        NSSet *set = value;
        for (id obj in [set sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            [mutableQueryStringComponents addObjectsFromArray:AFQueryStringPairsFromKeyAndValue(key, obj)];
        }
    } else {
        [mutableQueryStringComponents addObject:[[AFQueryStringPair alloc] initWithField:key value:value]];
    }

    return mutableQueryStringComponents;
}

@interface URQueueNetworkManager ()

@property (strong) URQueue *queue;
@property (strong) URUser *user;
@property (strong) NSURLSession *session;
@property (strong) NSURL *basePath;

- (void) makeRequest:(URRequestType)type urlString:(NSString *)url withParams:(NSDictionary *)params completion:(void (^)(id response, NSHTTPURLResponse *urlResponse, NSError *error))completionBlock;

@end

@implementation URQueueNetworkManager

- (id) initWithQueue:(URQueue *)queue andUser:(URUser *)user {
    self = [super init];

    if (self) {
        _queue = queue;
        _user = user;
        
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        _basePath = [NSURL URLWithString:[URDefaults currentBaseURL]];

        NSString *encodedAuth = [[[NSString stringWithFormat:@"%@:%@", user.userId, user.token] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];

        _session.configuration.HTTPAdditionalHeaders = @{
            @"Authorization": [NSString stringWithFormat:@"Basic %@", encodedAuth]
        };
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

    NSString *method = nil;
    NSURL *URL = [self.basePath URLByAppendingPathComponent:url];
    NSData *body = nil;

    switch(type) {
        case URRequestTypePOST:
            method = @"POST";
            break;
        case URRequestTypeDELETE:
            method = @"DELETE";
            break;
        case URRequestTypeGET:
            method = @"GET";
            break;
        case URRequestTypePUT:
            method = @"PUT";
            break;
    }

    if (params) {
        switch(type) {
            case URRequestTypePOST:
                body = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
                break;
            case URRequestTypeDELETE:
                body = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
                break;
            case URRequestTypeGET:
                URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", URL.absoluteString, AFQueryStringFromParametersWithEncoding(params, NSUTF8StringEncoding)]];
                break;
            case URRequestTypePUT:
                body = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
                break;
        }
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = method;
    request.HTTPBody = body;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    [[self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        id JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self finishRequestWithResponse:JSON
                                urlResponse:(NSHTTPURLResponse *)response
                                      error:error
                              andCompletion:completionBlock];
        });
    }] resume];
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

    [self makeRequest:URRequestTypePOST urlString:@"/queue/enter_queue" withParams:params completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        self.queue = [URQueue withAttributes:response];
        [_delegate networkManager:self didReceiveQueueUpdate:self.queue];
    }];
}

- (void) exitQueue {
    [self makeRequest:URRequestTypePOST urlString:@"/queue/exit_queue" withParams:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        self.queue = [URQueue withAttributes:response];
        [_delegate networkManager:self didReceiveQueueUpdate:self.queue];
    }];
}

#pragma mark TA Actions

- (void) acceptStudent:(URStudent *)student {
    NSString* url = [NSString stringWithFormat:@"/students/%@/ta_accept", student.userId];
    
    [self makeRequest:URRequestTypePOST urlString:url withParams:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        [self refreshQueue];
    }];
}

- (void) removeStudent:(URStudent *)student {
    NSString* url = [NSString stringWithFormat:@"/students/%@/ta_remove", student.userId];
    
    [self makeRequest:URRequestTypePOST urlString:url withParams:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        [self refreshQueue];
    }];
}

- (void) putBackStudent:(URStudent *)student {
    NSString* url = [NSString stringWithFormat:@"/students/%@/ta_putback", student.userId];
    
    [self makeRequest:URRequestTypePOST urlString:url withParams:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
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
