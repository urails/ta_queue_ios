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
        [_client setBasePath:gBaseUrl];
        [_client setSendParametersAsJSON:YES];
    }
    
    return self;
}

- (void) fetchSchools {
    [_client GET:@"/schools.json" parameters:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        NSMutableArray *schools = [NSMutableArray array];
        
        for (NSDictionary *school in response) {
            [schools addObject:[URSchool withAttributes:school]];
        }
        
        [_delegate networkManager:self didFetchSchools:schools];
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
            [URAlertView showMessage:[response description]];
        } else {
            /* If we didn't get the expected status code, render the rails errors */
            /* TODO: Unify error reporting here, similar to URQueueNetworkManager
               and unify the error reporting on the server */
            if (urlResponse.statusCode != 201) {
                [URAlertView showMessage:[NSString stringWithFormat:@"Got a %i", urlResponse.statusCode]];
            } else {
                URUser *user = [URStudent withAttributes:response];
                [_delegate networkManager:self didLoginUser:user error:error];
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
            [URAlertView showMessage:error.localizedDescription];
        } else if (urlResponse.statusCode != 201) {
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"WTF"
                                                           message:[response description]
                                                          delegate:nil 
                                                 cancelButtonTitle:@"OK" 
                                                 otherButtonTitles:nil];
            [view show];
        } else {
            URUser *user = [URTa withAttributes:response];
            [_delegate networkManager:self didLoginUser:user error:error];
        }
    }];
}

@end
