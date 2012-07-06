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

@synthesize queue = _queue;
@synthesize currentUser = _currentUser;
@synthesize timer = _timer;
@synthesize networkManager = _networkManager;
@synthesize delegate = _delegate;

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
    
    self.tabBarController.navigationItem.hidesBackButton = YES;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutTapped)];
    
    self.tabBarController.navigationItem.leftBarButtonItem = item;
    
    [URUser setCurrentUser:_currentUser];
    
    _networkManager = [[URQueueNetworkManager alloc] initWithQueue:_queue andUser:_currentUser];
    
    [_networkManager refreshQueue];
    
    __weak URQueueNetworkManager *tempManager = _networkManager;
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        [tempManager refreshQueue];
    }];
    
    [_networkManager setDelegate:self];
}

- (void)viewDidUnload
{
    [_timer invalidate];
    [self setTimer:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark NSTimer Methods

- (void) refreshTimerFired:(NSTimer *)timer {
    [_networkManager refreshQueue];
}

#pragma mark RKRequestDelegate methods

- (void) networkManager:(URQueueNetworkManager *)manager didReceiveQueueUpdate:(URQueue *)queue {
    self.queue = queue;
    
    [self.tableView reloadData];
    [self.tableView.pullToRefreshView stopAnimating];
}

- (void) networkManager:(URQueueNetworkManager *)manager didLogoutUser:(URUser *)user {
    [_delegate queueViewController:self didLogoutUser:user];
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
        return _queue.tas.count;
    }
    
    return _queue.studentsInQueue.count;
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
        _cell.textLabel.text = [[_queue.tas objectAtIndex:indexPath.row] username];
        
        cell = _cell;
    }
    else {
        URStudent *student = [_queue.studentsInQueue objectAtIndex:indexPath.row];
        URStudentCell *_cell = [self.tableView dequeueReusableCellWithIdentifier:studentIdentifier];
        _cell.textLabel.text = [[_queue.studentsInQueue objectAtIndex:indexPath.row] username];
        
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
    if ([[_queue currentUser] isStudent]) {
        if ([((URStudent*)[_queue currentUser]).inQueue boolValue]) {
//            [networkManager exitQueue];   
        }
        else {
//            [networkManager enterQueue];
        }
    }

}

- (void) logoutTapped {
    [_networkManager logout];
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
