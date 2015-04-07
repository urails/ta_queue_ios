//
//  URLoginNetworkManager.m
//  ta_queue_ios
//
//  Created by Parker Wightman on 7/6/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import "URLoginNetworkManager.h"
#import "URUser.h"
#import "URStudent.h"
#import "URTa.h"
#import "URDefaults.h"

@interface URLoginNetworkManager ()

@property (nonatomic, strong) NSString *basePath;
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation URLoginNetworkManager

- (id) init {
    self = [super init];
    
    if (self) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        _basePath = [URDefaults currentBaseURL];
    }
    
    return self;
}

#pragma mark Configuration

- (void) setBasePath:(NSString *)basePath {
    _basePath = basePath;
    [self fetchSchools];
}

- (void) refreshBasePath {
    [self setBasePath:[URDefaults currentBaseURL]];
}

- (NSURL *)URLForPath:(NSString *)path {
    return [NSURL URLWithString:[self.basePath stringByAppendingPathComponent:path]];
}

#pragma mark API calls

- (void) fetchSchools {
    [[self.session dataTaskWithURL:[self URLForPath:@"schools.json"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [_delegate networkManager:self didReceiveConnectionError:error.localizedDescription];
            } else {
                NSMutableArray *schools = [NSMutableArray array];
                NSArray *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

                for (NSDictionary *school in JSON) {
                    [schools addObject:[URSchool withAttributes:school]];
                }

                [_delegate networkManager:self didFetchSchools:schools];
            }
        });
    }] resume];
}

- (void) loginStudentWithUsername:(NSString *)username andLocation:(NSString *)location toQueue:(URQueue *)queue {
    NSString* url = [NSString stringWithFormat:@"/schools/%@/%@/%@/students", 
                     queue.instructor.school.abbreviation, 
                     queue.instructor.username,
                     queue.classNumber];
    
    NSDictionary *params = @{
        @"student": @{
            @"username": username,
            @"location": location
        }
    };

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self URLForPath:url]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:[NSJSONSerialization dataWithJSONObject:params options:0 error:nil] options:0 error:nil]);

    [[self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        /* If there's a connection error, render it */
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [_delegate networkManager:self didReceiveConnectionError:[error localizedDescription]];
            } else {
                /* If we didn't get the expected status code, render the rails errors */
                /* TODO: Unify error reporting here, similar to URQueueNetworkManager
                 and unify the error reporting on the server */
                NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
                if (statusCode != 201) {
                    if ([_delegate respondsToSelector:@selector(networkManager:didReceiveErrorCode:response:)]) {
                        id responseObject = nil;
                        if (data && data.length > 0) {
                            responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        }
                        [_delegate networkManager:self didReceiveErrorCode:statusCode response:responseObject];
                    }
                } else {
                    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                    URUser *user = [URStudent withAttributes:JSON];
                    [_delegate networkManager:self didLoginUser:user];
                }
            }
        });
    }] resume];
}

- (void) loginTaWithUsername:(NSString *)username andPassword:(NSString *)password toQueue:(URQueue *)queue {
    NSString* url = [NSString stringWithFormat:@"/schools/%@/%@/%@/tas", 
                     queue.instructor.school.abbreviation, 
                     queue.instructor.username,
                     queue.classNumber];
    
    NSDictionary *params = @{
        @"ta": @{
            @"username": username,
            @"password": password
        }
    };

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self URLForPath:url]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    [[self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
            if (error) {
                [_delegate networkManager:self didReceiveConnectionError:[error localizedDescription]];
            } else if (statusCode != 201) {
                id responseObject = nil;
                if (data && data.length > 0) {
                    responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                }
                [_delegate networkManager:self didReceiveErrorCode:statusCode response:responseObject];
            } else {
                NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                URUser *user = [URTa withAttributes:JSON];
                [_delegate networkManager:self didLoginUser:user];
            }
        });
    }] resume];
}

@end
