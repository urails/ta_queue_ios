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
    self.didFinish();
}

- (void) aboutViewControllerDidFinish:(URAboutViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:^{ }];
}

@end
