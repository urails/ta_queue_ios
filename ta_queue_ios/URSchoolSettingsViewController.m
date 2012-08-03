//
//  URSchoolSettingsViewController.m
//  ta_queue_ios
//
//  Created by Parker Wightman on 7/17/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import "URSchoolSettingsViewController.h"
#import "URDefaults.h"


@interface URSchoolSettingsViewController ()

@end

@implementation URSchoolSettingsViewController

@synthesize delegate = _delegate;
@synthesize baseURLField = _baseURLField;

- (void)viewDidLoad
{
    [super viewDidLoad];
    _baseURLField.text = [URDefaults currentBaseURL];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setBaseURLField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (IBAction)doneTapped:(id)sender {
    [URDefaults setCurrentBaseURL:_baseURLField.text];
    [_delegate settingsViewControllerDidFinish:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"about"]) {
        URAboutViewController *controller = (URAboutViewController *)segue.destinationViewController;
        
        controller.delegate = self;
    }
}

- (void) aboutViewControllerDidFinish:(URAboutViewController *)controller {
    [self dismissModalViewControllerAnimated:YES];
}

@end
