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
#import "SVPullToRefresh.h"
#import "URLoginViewController.h"

@interface URViewController ()

@end

@implementation URViewController

@synthesize schools = _schools;
@synthesize networkManager = _networkManager;

- (void)viewDidLoad
{
    _networkManager = [[URLoginNetworkManager alloc] init];
    _networkManager.delegate = self;
    __weak URLoginNetworkManager *weakManager = _networkManager;
    
    [self.tableView addPullToRefreshWithActionHandler:^(void) {
        [weakManager fetchSchools];
    }];
    
    [_networkManager fetchSchools];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void) networkManager:(URLoginNetworkManager *)manager didFetchSchools:(NSArray *)schools {
    _schools = schools;
    [self.tableView.pullToRefreshView stopAnimating];
    [self.tableView reloadData];
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath* indexPath = [self.tableView indexPathForCell:sender];
    
    URQueue* queue = [[[_schools objectAtIndex:indexPath.section] aggregatedQueues] objectAtIndex:indexPath.row];
        
    if ([segue.identifier isEqualToString:@"queueLogin"]) {
        URLoginViewController* viewController = (URLoginViewController*) segue.destinationViewController;
        [viewController setSchoolQueue:queue];
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

//    [[cell detailTextLabel] setText:queue.instructor.name];
    
    return cell;
}


#pragma mark RKObjectLoaderDelegate Methods


- (void)viewDidUnload
{
    [super viewDidUnload];
    _networkManager.delegate = nil;
    [self setNetworkManager:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
