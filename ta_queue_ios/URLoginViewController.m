//
//  URLoginViewController.m
//  ta_queue_ios
//
//  Created by Parker Wightman on 5/4/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import "URLoginViewController.h"



@interface URLoginViewController ()

@end

@implementation URLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [_nameField setDelegate:self];
	_nameField.text = [URDefaults username];
	
    [_locationField setDelegate:self];
	_locationField.text = [URDefaults location];
	
    _networkManager = [[URLoginNetworkManager alloc] init];
    [_networkManager setDelegate:self];
	
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidUnload
{
    [self setNameField:nil];
    [self setLocationField:nil];
    [self setTypeControl:nil];
    [self setNetworkManager:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (textField == _nameField) {
        [_locationField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
        [self loginTapped:self];
    }

    return YES;
}

- (IBAction)loginTapped:(id)sender {
    [_locationField resignFirstResponder];
    [_nameField resignFirstResponder];
    
    if (_typeControl.selectedSegmentIndex == 0) {
        [_networkManager loginStudentWithUsername:_nameField.text 
                                      andLocation:_locationField.text 
                                          toQueue:_schoolQueue];
    }
    else {
        [_networkManager loginTaWithUsername:_nameField.text
                                 andPassword:_locationField.text 
                                     toQueue:_schoolQueue];
    }
}

- (void) networkManager:(URLoginNetworkManager *)manager didLoginUser:(URUser *)user {
    _loggedInUser = user;
	[URDefaults setUsername:_nameField.text];
	if (user.isStudent) {
		[URDefaults setLocation:_locationField.text];
	}
    [self performSegueWithIdentifier:@"loggedIn" sender:self];
}

- (void) networkManager:(URLoginNetworkManager *)manager didReceiveConnectionError:(NSString *)error {
    [URAlertView showMessage:error withStyle:UIAlertViewStyleDefault ok:nil cancel:nil];
}

- (void) networkManager:(URLoginNetworkManager *)manager didReceiveErrorCode:(NSInteger)code response:(id)response {
    [URAlertView showMessage:[URError errorMessageWithResponse:response] withStyle:UIAlertViewStyleDefault ok:nil cancel:nil];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"loggedIn"]) {
        URQueueViewController* controller = (URQueueViewController*)segue.destinationViewController;
        
        controller.didFinish = ^{
            [self.navigationController popViewControllerAnimated:YES];
        };
        controller.currentUser = _loggedInUser;
    }
}

- (IBAction)segmentChanged:(id)sender {
	_locationField.text = nil;
    if (_typeControl.selectedSegmentIndex == 0) {
        _locationField.placeholder = @"Location";
        _locationField.secureTextEntry = NO;
    }
    else {
        _locationField.placeholder = @"Password";
        _locationField.enabled = NO;
        _locationField.secureTextEntry = YES;
        _locationField.enabled = YES;
    }
}


@end
