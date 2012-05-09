//
//  URLoginViewController.m
//  ta_queue_ios
//
//  Created by Parker Wightman on 5/4/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import "URLoginViewController.h"

#import "URQueueViewController.h"

@interface URLoginViewController ()

@end

@implementation URLoginViewController

@synthesize typeControl;
@synthesize nameField;
@synthesize locationField;
@synthesize schoolQueue;
@synthesize client;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil];
    
    [nameField setDelegate:self];
    [locationField setDelegate:self];
}

- (void)viewDidUnload
{
    [self setNameField:nil];
    [self setLocationField:nil];
    [self setTypeControl:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (textField == nameField) {
        [locationField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
        [self loginTapped:self];
    }

    return YES;
}

- (void) viewWillAppear:(BOOL)animated {
    URUser* user;
    if ((user = [URUser currentUser])) {
        [self logout:user];
        
        [URUser setCurrentUser:nil];
    }
}

- (void) logout:(URUser *)user {
    
    NSString* type = @"students";
    if (user.isTa) {
        type = @"tas";
    }
    [[RKClient sharedClient] delete:[NSString stringWithFormat:@"/%@/%@", type, user.userId] delegate:self];
}

#pragma mark - Table view data source


#pragma mark - Table view delegate

- (IBAction)loginTapped:(id)sender {
    [locationField resignFirstResponder];
    [nameField resignFirstResponder];
    
    client = [RKClient clientWithBaseURLString:gBaseUrl];
    
    NSString* type = nil;
    NSString* key = nil;
    NSString* secondaryType = nil;
    
    if (typeControl.selectedSegmentIndex == 0) {
        type = @"students";
        key = @"student";
        secondaryType = @"location";
    }
    else {
        type = @"tas";
        key = @"ta";
        secondaryType = @"password";
    }
    
    NSString* path = [NSString stringWithFormat:@"/schools/%@/%@/%@/%@", [[[schoolQueue instructor] school] abbreviation], [[schoolQueue instructor] username], [schoolQueue classNumber], type];
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[nameField text], @"username", [locationField text], secondaryType, nil];
    
    params = [NSDictionary dictionaryWithObject:params forKey:key];
    
    [client post:path params:params delegate:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"loggedIn"]) {
        URQueueViewController* controller = (URQueueViewController*)[[segue.destinationViewController viewControllers] objectAtIndex:0];
        
        controller.currentUser = sender;
    }
}

/**
 Sent when a request has finished loading
 
 @param request The RKRequest object that was handling the loading.
 @param response The RKResponse object containing the result of the request.
 */
- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response {

    NSError* error = nil;
    NSDictionary* dict = [response parsedBody:&error];

    // This is if the user is joining the queue
    if ([response statusCode] == 201) {

        URUser* user = nil;
        
        if (typeControl.selectedSegmentIndex == 0) {
            user = [URStudent withAttributes:dict];
        }
        else {
            user = [URTa withAttributes:dict];
        }

        
        [URUser setCurrentUser:user];
        
        // PROBABLY NOT SMART TO SEND USER AS SENDER....
        [self performSegueWithIdentifier:@"loggedIn" sender:user];
    }
    else if([response statusCode] == 204) {
        // This was if the user logged out!
    }
    else if ([response isError]) {
        // TODO: Error stuff...
    }
}


///-----------------------------------------------------------------------------
/// @name Handling Failed Requests
///-----------------------------------------------------------------------------

/**
 Sent when a request has failed due to an error
 
 @param request The RKRequest object that was handling the loading.
 @param error An NSError object containing the RKRestKitError that triggered
 the callback.
 */
- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error {
    NSLog(@"%@", error);
}

- (IBAction)segmentChanged:(id)sender {
    if (typeControl.selectedSegmentIndex == 0) {
        locationField.placeholder = @"Location";
    }
    else {
        locationField.placeholder = @"Password";
    }
}


@end
