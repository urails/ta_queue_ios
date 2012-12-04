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

@property (strong) SVHTTPClient *client;

@end

@implementation URLoginNetworkManager

@synthesize client = _client;
@synthesize delegate = _delegate;

- (id) init {
    self = [super init];
    
    if (self) {
        _client = [[SVHTTPClient alloc] init];
        [_client setBasePath:[URDefaults currentBaseURL]];
        [_client setSendParametersAsJSON:YES];
    }
    
    return self;
}

#pragma mark Configuration

- (void) setBasePath:(NSString *)basePath {
    [_client setBasePath:basePath];
    [self fetchSchools];
}

- (void) refreshBasePath {
    [self setBasePath:[URDefaults currentBaseURL]];
}

#pragma mark API calls

- (void) fetchSchools {
    [_client GET:@"/schools.json" parameters:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
		
		if (error) {
			[_delegate networkManager:self didReceiveConnectionError:error.localizedDescription];
		} else {
			NSMutableArray *schools = [NSMutableArray array];
			
			for (NSDictionary *school in response) {
				[schools addObject:[URSchool withAttributes:school]];
			}
			
			[_delegate networkManager:self didFetchSchools:schools];
		}
		
    }];
}

- (void) loginStudentWithUsername:(NSString *)username andLocation:(NSString *)location toQueue:(URQueue *)queue {
    NSString* url = [NSString stringWithFormat:@"/schools/%@/%@/%@/students", 
                     queue.instructor.school.abbreviation, 
                     queue.instructor.username,
                     queue.classNumber];
    
    NSMutableDictionary *fields = [NSMutableDictionary dictionary];
    
    [fields setValue:username forKey:@"username"];
    [fields setValue:location forKey:@"location"];
    
    NSDictionary *params = [NSDictionary dictionaryWithObject:fields forKey:@"student"];
    
    [_client POST:url parameters:params completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        /* If there's a connection error, render it */
        if (error) {
            [_delegate networkManager:self didReceiveConnectionError:[error localizedDescription]];
        } else {
            /* If we didn't get the expected status code, render the rails errors */
            /* TODO: Unify error reporting here, similar to URQueueNetworkManager
               and unify the error reporting on the server */
            if (urlResponse.statusCode != 201) {
				if ([_delegate respondsToSelector:@selector(networkManager:didReceiveErrorCode:response:)]) {
					[_delegate networkManager:self didReceiveErrorCode:urlResponse.statusCode response:response];
				}
            } else {
                URUser *user = [URStudent withAttributes:response];
                [_delegate networkManager:self didLoginUser:user];
            }
        }
    }];
}

- (void) loginTaWithUsername:(NSString *)username andPassword:(NSString *)password toQueue:(URQueue *)queue {
    NSString* url = [NSString stringWithFormat:@"/schools/%@/%@/%@/tas", 
                     queue.instructor.school.abbreviation, 
                     queue.instructor.username,
                     queue.classNumber];
    
    NSMutableDictionary *fields = [NSMutableDictionary dictionary];
    
    [fields setValue:username forKey:@"username"];
    [fields setValue:password forKey:@"password"];
    
    NSDictionary *params = [NSDictionary dictionaryWithObject:fields forKey:@"ta"];
    
    [_client POST:url parameters:params completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            [_delegate networkManager:self didReceiveConnectionError:[error localizedDescription]];
        } else if (urlResponse.statusCode != 201) {
            [_delegate networkManager:self didReceiveErrorCode:urlResponse.statusCode response:response];
        } else {
            URUser *user = [URTa withAttributes:response];
            [_delegate networkManager:self didLoginUser:user];
        }
    }];
}

@end
