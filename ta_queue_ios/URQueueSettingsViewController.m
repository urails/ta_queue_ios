//
//  URQueueSettingsViewController.m
//  ta_queue_ios
//
//  Created by Parker Wightman on 7/18/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import "URQueueSettingsViewController.h"
#import "URDefaults.h"

@interface URQueueSettingsViewController ()


@property (strong, nonatomic) IBOutlet UIStepper *stepper;

@end

@implementation URQueueSettingsViewController

@synthesize delegate = _delegate;
@synthesize secondsLabel = _secondsLabel;
@synthesize stepper = _stepper;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setSecondsLabel:nil];
    [self setStepper:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated {
    _stepper.value = [URDefaults currentQueryInterval];
    [self updateQueryLabel];
}

#pragma mark Instance Methods

- (void) updateQueryLabel {
    _secondsLabel.text = [NSString stringWithFormat:@"%is", [URDefaults currentQueryInterval]];    
}

#pragma mark IBActions

- (IBAction)doneTapped:(id)sender {
    [_delegate settingsViewControllerDidFinish:self];
}

- (IBAction)stepperValueChanged:(id)sender {
    UIStepper *stepper = (UIStepper *)sender;
    [URDefaults setCurrentQueryInterval:(NSUInteger)stepper.value];
    [self updateQueryLabel];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
