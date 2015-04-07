//
//  URViewController.m
//  ta_queue_ios
//
//  Created by Parker Wightman on 4/25/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import "URViewController.h"
#import "URSchool.h"
#import "URStudent.h"
#import "URInstructor.h"
#import "URQueue.h"
#import "URLoginViewController.h"
#import "SSPullToRefresh.h"
#import "SSPullToRefreshSimpleContentView.h"

@interface URViewController () <SSPullToRefreshViewDelegate>

@property (strong) SSPullToRefreshView *pullToRefreshView;

@end

@implementation URViewController

- (void)viewDidLoad
{
    _networkManager = [[URLoginNetworkManager alloc] init];
    _networkManager.delegate = self;

    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews {
    if(self.pullToRefreshView == nil) {
        self.pullToRefreshView = [[SSPullToRefreshView alloc] initWithScrollView:self.tableView delegate:self];
        self.pullToRefreshView.contentView = [[SSPullToRefreshSimpleContentView alloc] initWithFrame:CGRectZero];
    }
}

- (void)refresh {
    [self.pullToRefreshView startLoading];
    [self.networkManager fetchSchools];
}

- (void) viewWillAppear:(BOOL)animated {
    [_networkManager fetchSchools];    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _networkManager.delegate = nil;
    [self setNetworkManager:nil];
}

#pragma mark SSPullToRefreshViewDelegate

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view {
    [self refresh];
}

#pragma mark Networking

- (void) networkManager:(URLoginNetworkManager *)manager didFetchSchools:(NSArray *)schools {
    _schools = schools;
    [self.pullToRefreshView finishLoading];
    [self.tableView reloadData];
}

- (void) networkManager:(URLoginNetworkManager *)manager didReceiveConnectionError:(NSString *)error {
	[URAlertView showMessage:error];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath* indexPath = [self.tableView indexPathForCell:sender];
    
            
    if ([segue.identifier isEqualToString:@"queueLogin"]) {

        URQueue* queue = [[[_schools objectAtIndex:indexPath.section] aggregatedQueues] objectAtIndex:indexPath.row];

        URLoginViewController *viewController = (URLoginViewController *) segue.destinationViewController;
        [viewController setSchoolQueue:queue];
        
    } else if ([segue.identifier isEqualToString:@"schoolSettings"]) {

        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        URSchoolSettingsViewController *viewController = (URSchoolSettingsViewController *)navController.viewControllers[0];
        
        viewController.didFinish = ^{
			[self.networkManager setBasePath:[URDefaults currentBaseURL]];
            [self dismissViewControllerAnimated:true completion:^{ }];
        };
    }
}

#pragma mark UITableViewDelegate Methods

#pragma mark UITableViewDataSource Methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[_schools objectAtIndex:section] aggregatedQueues] count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {

    
    return [_schools count];
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[_schools objectAtIndex:section] name];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* identifier = @"schoolCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    URQueue* queue = [[[_schools objectAtIndex:indexPath.section] aggregatedQueues] objectAtIndex:indexPath.row];
    
    [[cell textLabel] setText:[NSString stringWithFormat:@"%@ - %@", queue.classNumber, queue.title]];

    [[cell detailTextLabel] setText:queue.instructor.name];
    
    return cell;
}

@end
