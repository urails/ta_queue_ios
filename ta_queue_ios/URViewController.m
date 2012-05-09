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

@synthesize schools;

- (void)viewDidLoad
{
    URViewController* this = self;
    
    [self.tableView addPullToRefreshWithActionHandler:^(void) {
        [this fetchSchools];
    }];
    
    [self fetchSchools];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void) fetchSchools {
    [[RKClient sharedClient] get:@"/schools" delegate:self];
}

- (void) request:(RKRequest *)request didFailLoadWithError:(NSError *)error {
    
}

- (void) request:(RKRequest *)request didLoadResponse:(RKResponse *)response {
    NSLog(@"%@", request.URL.path);
    
    NSArray* _schools = [response parsedBody:nil];
    
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:5];
        
    for (NSDictionary *dict in _schools) {
        [array addObject:[URSchool withAttributes:dict]];
    }
    
    schools = array;
    
    [self.tableView reloadData];
    [self.tableView.pullToRefreshView stopAnimating];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath* indexPath = [self.tableView indexPathForCell:sender];
    
    URQueue* queue = [[[schools objectAtIndex:indexPath.section] aggregatedQueues] objectAtIndex:indexPath.row];
        
    if ([segue.identifier isEqualToString:@"queueLogin"]) {
        URLoginViewController* viewController = (URLoginViewController*) segue.destinationViewController;
        [viewController setSchoolQueue:queue];
    }
}

#pragma mark UITableViewDelegate Methods

#pragma mark UITableViewDataSource Methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[schools objectAtIndex:section] aggregatedQueues] count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {

    
    return [schools count];
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[schools objectAtIndex:section] name];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* identifier = @"schoolCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    URQueue* queue = [[[schools objectAtIndex:indexPath.section] aggregatedQueues] objectAtIndex:indexPath.row];
    
    [[cell textLabel] setText:[NSString stringWithFormat:@"%@ - %@", queue.classNumber, queue.title]];

    [[cell detailTextLabel] setText:queue.instructor.name];
    
    return cell;
}


#pragma mark RKObjectLoaderDelegate Methods


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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
