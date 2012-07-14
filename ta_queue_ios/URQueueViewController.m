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
@synthesize tableView = _tableView;
@synthesize toolbar = _toolbar;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutTapped)];
    
    self.navigationItem.leftBarButtonItem = item;
    
    [URUser setCurrentUser:_currentUser];
    
    _networkManager = [[URQueueNetworkManager alloc] initWithQueue:_queue andUser:_currentUser];
    
    [_networkManager refreshQueue];
    
    __weak URQueueNetworkManager *tempManager = _networkManager;
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        [tempManager refreshQueue];
    }];
    
    if (_queue.studentsInQueue.count > 0) {
        [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:STUDENT_SECTION] animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    

    
    [_networkManager setDelegate:self];
}

- (void) viewWillAppear:(BOOL)animated {
    [URQueueViewController setCurrentQueueController:self];
    _timer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(refreshQueue) userInfo:nil repeats:YES];   
}

- (void) viewWillDisappear:(BOOL)animated {
    [URQueueViewController setCurrentQueueController:nil];
    [_timer invalidate];    
}

- (void)viewDidUnload
{
    [self setTimer:nil];
    [self setToolbar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark NSTimer Methods

- (void) refreshQueue {
    [_networkManager refreshQueue];
}

#pragma mark RKRequestDelegate methods

- (void) networkManager:(URQueueNetworkManager *)manager didReceiveQueueUpdate:(URQueue *)queue {
    self.queue = queue;
    
    [URStudent setCurrentUser:queue.currentUser];
    
    NSIndexPath *path = [_tableView indexPathForSelectedRow];
    

    [_tableView reloadData];
    [_tableView.pullToRefreshView stopAnimating];
    [_tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self setupUserActionToolbar];
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

    
    cell.opaque = NO;    
    
    // Configure the cell...
    
    return cell;
}

- (UITableViewCell*) cellForIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *studentIdentifier = @"studentCell";
    static NSString *taIdentifier = @"taCell";
    
    UITableViewCell *cell = nil;
    
    
    
    if (indexPath.section == TA_SECTION) {
        URTa *ta = [_queue.tas objectAtIndex:indexPath.row];
        URTACell *_cell = [self.tableView dequeueReusableCellWithIdentifier:taIdentifier];

        _cell.textLabel.text = ta.username;

        if (ta.student) {
            _cell.detailTextLabel.text = [NSString stringWithFormat:@"Helping %@", ta.student.username];
        } else {
            _cell.detailTextLabel.text = @"";
        }

        cell = _cell;
    }
    else {
        URStudent *student = [_queue.studentsInQueue objectAtIndex:indexPath.row];
        URStudentCell *_cell = [self.tableView dequeueReusableCellWithIdentifier:studentIdentifier];

        NSString *userLabel = [NSString stringWithFormat:@"%@ @ %@", student.username, student.location];

        _cell.textLabel.text = userLabel;
        
        if (student.ta) {
            _cell.detailTextLabel.text = [NSString stringWithFormat:@"Being helped by %@", student.ta.username];
        } else {
            _cell.detailTextLabel.text = @"";
        }


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

- (void) setupUserActionToolbar {
    _toolbar.items = nil;
    
    URUser *user = [URUser currentUser];
    
    if (user.isStudent) {
        _toolbar.items = [self studentBarItems:(URStudent *)user];
    } else {
        _toolbar.items = [self taBarItems:(URTa *)user];
    }
}

- (NSArray *) studentBarItems:(URStudent *)student {
    NSMutableArray *items = [NSMutableArray array];
    
    if (!_queue.active) {
        return items;
    }

    if (student.inQueue) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Exit Queue" style:UIBarButtonItemStyleBordered target:self action:@selector(exitQueue)];
        [items addObject:item];
    }
    else {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Enter Queue" style:UIBarButtonItemStyleBordered target:self action:@selector(enterQueue)];
        [items addObject:item];
    }
    
    return items;
}


- (NSArray *) taBarItems:(URTa *)ta {
    NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
    
    NSMutableArray *items = [NSMutableArray array];
    
    if (indexPath.section == STUDENT_SECTION && _queue.studentsInQueue.count > 0) {
        
        // There's a chance that if they have the last person in the list selected that
        // when they were removed the user, it's selecting off the end of the list. In
        // which case we want to back it off.
        NSUInteger row = indexPath.row;
        while (row >= _queue.studentsInQueue.count) {
            row--;
        }
        
        URStudent *student = [_queue.studentsInQueue objectAtIndex:row];
        
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:row inSection:indexPath.section];
        
        [_tableView selectRowAtIndexPath:newPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        
        if (student.taId) {
            if ([ta.userId isEqualToString:student.taId]) {
                UIBarButtonItem *item =[[UIBarButtonItem alloc] initWithTitle:@"Put Back" style:UIBarButtonItemStyleBordered target:self action:@selector(putBackStudent)];
                
                [items addObject:item];
            }
        } else {
            UIBarButtonItem *item =[[UIBarButtonItem alloc] initWithTitle:@"Accept" style:UIBarButtonItemStyleBordered target:self action:@selector(acceptStudent)];
            
            [items addObject:item];
        }
        
        UIBarButtonItem *item =[[UIBarButtonItem alloc] initWithTitle:@"Remove" style:UIBarButtonItemStyleBordered target:self action:@selector(removeStudent)];
        
        [items addObject:item];
    }
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [items addObject:item];
    
    NSString *active = (_queue.active ? @"Deactivate" : @"Activate");

    
    item =[[UIBarButtonItem alloc] initWithTitle:active style:UIBarButtonItemStyleBordered target:self action:@selector(toggleActive)];
    
    [items addObject:item];
    
    // You can't freeze/unfreeze the queue unless it is active
    if (_queue.active) {
        NSString *frozen = (_queue.frozen ? @"Unfreeze" : @"Freeze");
        
        item =[[UIBarButtonItem alloc] initWithTitle:frozen style:UIBarButtonItemStyleBordered target:self action:@selector(toggleFrozen)];
        
        [items addObject:item];
    }
    
    return items;
}

- (void) toggleFrozen {
    [_networkManager toggleFrozen];
}

- (void) toggleActive {
    [_networkManager toggleActive];
}

- (void) acceptStudent {
    NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
    URStudent *student = [_queue.studentsInQueue objectAtIndex:indexPath.row];
    
    [_networkManager acceptStudent:student];
}

- (void) putBackStudent {
    NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
    URStudent *student = [_queue.studentsInQueue objectAtIndex:indexPath.row];
    
    [_networkManager putBackStudent:student];
}

- (void) removeStudent {
    NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
    URStudent *student = [_queue.studentsInQueue objectAtIndex:indexPath.row];
    
    [_networkManager removeStudent:student];
}

- (void) enterQueue {
    [_networkManager enterQueue];
}

- (void) exitQueue {
    [_networkManager exitQueue];
}


- (void) logoutTapped {
    [_networkManager logout];
}

static URQueueViewController* _currentQueueController = nil;

+ (URQueueViewController*) currentQueueController {
    return _currentQueueController;
}

+ (void) setCurrentQueueController:(URQueueViewController *)queueController {
    _currentQueueController = queueController;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setupUserActionToolbar];
}

@end
