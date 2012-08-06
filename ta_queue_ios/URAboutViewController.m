//
//  URAboutViewController.m
//  ta_queue_ios
//
//  Created by Parker Wightman on 8/3/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import "URAboutViewController.h"

@interface URAboutViewController ()

@end

@implementation URAboutViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
- (IBAction)gotoApp:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/urails/ta_queue_ios/"]];
}
- (IBAction)gotoWebService:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/urails/ta_queue/"]];
}
- (IBAction)mailParker:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setToRecipients:[NSArray arrayWithObject:@"uofu.ta.queue@gmail.com"]];
        [self presentModalViewController:controller
                                animated:YES];
    }

}
- (IBAction)gotoWebClient:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://nine.eng.utah.edu/"]];
}

- (IBAction)doneTapped:(id)sender {
    [_delegate aboutViewControllerDidFinish:self];
}


#pragma mark MFMailComposeViewControllerDelegate methods

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
