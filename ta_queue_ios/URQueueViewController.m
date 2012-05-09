//
//  URQueueViewController.m
//  ta_queue_ios
//
//  Created by Parker Wightman on 5/4/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import "URQueueViewController.h"
#import "SVPullToRefresh.h"
#import "URStudentCell.h"
#import "URTACell.h"

#define TA_SECTION 0
#define STUDENT_SECTION 1

@interface URQueueViewController ()

@end

@implementation URQueueViewController

@synthesize queue, currentUser, timer, networkManager;

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
    
    networkManager = [[URNetworkManager alloc] initWithId:currentUser.userId andToken:currentUser.token];
    
    URNetworkManager *tempManager = networkManager;
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        [tempManager updateQueue];
    }];
    
    [networkManager updateQueue];
    
    [networkManager setDelegate:self];
    
    //timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(refreshTimerFired:) userInfo:nil repeats:YES];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [timer invalidate];
    timer = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark NSTimer Methods

- (void) refreshTimerFired:(NSTimer *)timer {
    [networkManager updateQueue];
}

#pragma mark RKRequestDelegate methods

- (void) networkManager:(URNetworkManager*) manager updatedQueue:(URQueue*) updatedQueue {
    self.queue = updatedQueue;
    
    [self.tableView reloadData];
    [self.tableView.pullToRefreshView stopAnimating];
}

#pragma mark 

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return queue.tas.count;
    }
    
    return queue.studentsInQueue.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [self cellForIndexPath:indexPath];
    
    
    // Configure the cell...
    
    return cell;
}

- (UITableViewCell*) cellForIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *studentIdentifier = @"studentCell";
    static NSString *taIdentifier = @"taCell";
    
    UITableViewCell *cell = nil;
    
    
    
    if (indexPath.section == TA_SECTION) {
        URTACell *_cell = [self.tableView dequeueReusableCellWithIdentifier:taIdentifier];
        _cell.textLabel.text = [[queue.tas objectAtIndex:indexPath.row] username];
        
        cell = _cell;
    }
    else {
        URStudent *student = [queue.studentsInQueue objectAtIndex:indexPath.row];
        URStudentCell *_cell = [self.tableView dequeueReusableCellWithIdentifier:studentIdentifier];
        _cell.textLabel.text = [[queue.studentsInQueue objectAtIndex:indexPath.row] username];
        
        if (!student.taId) {
            [_cell.acceptButton addTarget:self action:@selector(acceptTapped:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            _cell.acceptButton.hidden = YES;
        }

        
        [_cell.acceptButton addTarget:self action:@selector(removeTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        cell = _cell;
    }

    

    
    return cell;
    
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return @"TAs";
    else
        return @"Students";
}

- (void) acceptTapped:(id)sender {
    NSLog(@"Accept Tapped");
}

- (void) removePressed:(id)sender {
    
}

- (IBAction)toggleEnterQueue:(id)sender {
    if ([[queue currentUser] isStudent]) {
        if ([((URStudent*)[queue currentUser]).inQueue boolValue]) {
            [networkManager exitQueue];   
        }
        else {
            [networkManager enterQueue];
        }
    }

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
