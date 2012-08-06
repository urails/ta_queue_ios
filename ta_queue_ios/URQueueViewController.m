//
//  URQueueViewController.m
//  ta_queue_ios
//
//  Created by Parker Wightman on 5/4/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import "URQueueViewController.h"
#import "SVPullToRefresh.h"
#import "URDefaults.h"
#import "URQuestionViewController.h"

// Table View Sections
#define STATUS_SECTION 0
#define TA_MESSAGE_SECTION 1
#define TA_SECTION 2
#define STUDENT_SECTION 3

// Alert View Tags
#define ALERT_VEIW_ASK_QUESTION_TAG 0
#define ALERT_VIEW_UPDATE_STATUS_TAG 1

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
    
    __block URQueueNetworkManager *tempManager = _networkManager;
    
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
    NSLog(@"View Appeared");
    [self startTimer];
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

- (void) startTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:[URDefaults currentQueryInterval] target:self selector:@selector(refreshQueue) userInfo:nil repeats:YES];   
    NSLog(@"Querying at %i", [URDefaults currentQueryInterval]);
}

#pragma mark NSTimer Methods

- (void) refreshQueue {
    [_networkManager refreshQueue];
}

#pragma mark URQueueSettingsViewController

- (void) settingsViewControllerDidFinish:(URQueueSettingsViewController *)controller {
    [_timer invalidate];
    [self dismissModalViewControllerAnimated:YES];
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

- (void) networkManager:(URQueueNetworkManager *)manager didReceiveErrorCode:(NSInteger)code response:(id)response {
    // A 401 is the unauthorized status code, which must me they are no longer logged in and
    // the server timed them out.
    if (code == 401) {
        [_delegate queueViewController:self didLogoutUser:_currentUser];
        [URAlertView showMessage:@"You are no longer logged in, possibly due to inactivity. Please login again."];
    } 
    // Any other error could be anything, so display it to the user.
    else {
        [URAlertView showMessage:[URError errorMessageWithResponse:response]];
    }
}

- (void) networkManager:(URQueueNetworkManager *)manager didReceiveConnectionError:(NSError *)error {
    [URAlertView showMessage:error.localizedDescription];
}

#pragma mark UIViewController methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"queueSettings"]) {
        URQueueSettingsViewController *controller = (URQueueSettingsViewController *)segue.destinationViewController;
        controller.delegate = self;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // See the top of this file for the #define directives for each section
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == TA_SECTION) {
        return _queue.tas.count;
    } else if (section == STUDENT_SECTION) {
        return _queue.studentsInQueue.count;
    } else if (section == TA_MESSAGE_SECTION) {
        if ([self shouldShowTaMessage]) {
            return 1;
        }
    } else if (section == STATUS_SECTION) {
        if ([self shouldShowQueueStatus]) {
            return 1;
        }
    }
    
    return 0;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self cellForIndexPath:indexPath];

    cell.opaque = NO;
    
    return cell;
}

- (UITableViewCell*) cellForIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *studentIdentifier = @"studentCell";
    static NSString *taIdentifier = @"taCell";
    static NSString *statusIdentifier = @"queueStatus";
    static NSString *taStatusIdentifier = @"taStatus";
    
    UITableViewCell *cell = nil;
    
    
    
    if (indexPath.section == TA_SECTION) {
        URTa *ta = [_queue.tas objectAtIndex:indexPath.row];
        UITableViewCell *_cell = [self.tableView dequeueReusableCellWithIdentifier:taIdentifier];

        _cell.textLabel.text = ta.username;

        if (ta.student) {
            _cell.detailTextLabel.text = [NSString stringWithFormat:@"Helping %@", ta.student.username];
        } else {
            _cell.detailTextLabel.text = @"";
        }

        cell = _cell;
        
    } else if (indexPath.section == STUDENT_SECTION) {
        URStudent *student = [_queue.studentsInQueue objectAtIndex:indexPath.row];
        UITableViewCell *_cell = [self.tableView dequeueReusableCellWithIdentifier:studentIdentifier];

        NSString *userLabel = [NSString stringWithFormat:@"%@ @ %@", student.username, student.location];

        _cell.textLabel.text = userLabel;
        
        if (student.ta) {
            _cell.detailTextLabel.text = [NSString stringWithFormat:@"Being helped by %@", student.ta.username];
        } else {
            _cell.detailTextLabel.text = @"";
        }
        
        cell = _cell;
        
    } else if (indexPath.section == TA_MESSAGE_SECTION) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:statusIdentifier];

        if (_currentUser.isTa) {
            if ([_queue.status isEqualToString:@""]) {
                cell.textLabel.text = @"Tap here to update the Queue status";
            }
            else {
                cell.textLabel.text = _queue.status;
            }
        } else {
            cell.textLabel.text = _queue.status;
        }
    } else if (indexPath.section == STATUS_SECTION) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:taStatusIdentifier];
        if (!_queue.active) {
            cell.textLabel.text = @"The Queue is not active.";
            cell.contentView.backgroundColor = [UIColor redColor];
        } else if (_queue.frozen) {
            cell.textLabel.text = @"The Queue is frozen, no more students may enter.";
            cell.contentView.backgroundColor = [UIColor blueColor];
        }
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
    }
    
    // Show the disclosure if the student is asking a question in question-based mode
    if (_queue.isQuestionBased && indexPath.section == STUDENT_SECTION) {
        NSString *question = [[[_queue studentsInQueue] objectAtIndex:indexPath.row] question];
        if (question && question.length > 0) {
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
    
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == TA_SECTION)
        return @"TAs";
    else if (section == STUDENT_SECTION)
        return @"Students";
    else if (section == TA_MESSAGE_SECTION){
        if (![self shouldShowTaMessage]) {
            return nil;
        }
        return @"TA Message";
    } else if (section == STATUS_SECTION) {
        if (![self shouldShowQueueStatus]) {
            return nil;
        }
        return @"Queue Status";
    }
    
    return nil;
}

- (BOOL) shouldShowQueueStatus {
    return (!_queue.active) || _queue.frozen;
}

- (BOOL) shouldShowTaMessage {
    return _queue.active && (_currentUser.isTa || (_queue.status && ![_queue.status isEqualToString:@""]));
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
        // when they removed the user, it's selecting off the end of the list. In which 
        // case we want to back it off.
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
    if (_currentUser.isStudent && _queue.isQuestionBased) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Question"
                                                            message:@"What is your Question?"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Enter Queue", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        alertView.tag = ALERT_VEIW_ASK_QUESTION_TAG;
        [alertView show];
    } else {
        [_networkManager enterQueue];
    }
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
    if (indexPath.section == TA_MESSAGE_SECTION) {
        if (_currentUser.isTa) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Update Status" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            alertView.tag = ALERT_VIEW_UPDATE_STATUS_TAG;
            [alertView show];
        }
    } else {
        [self setupUserActionToolbar];
    }

}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    URQuestionViewController *controller = (URQuestionViewController *)[[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"questionVC"];
    
    controller.question = [[[_queue studentsInQueue] objectAtIndex:indexPath.row] question];
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark UIAlertView delegate

- (void) alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSLog(@"%d", alertView.tag);
        if (alertView.tag == ALERT_VIEW_UPDATE_STATUS_TAG) {
            
            [_networkManager updateQueueStatus:[[alertView textFieldAtIndex:0] text]];
            
        } else if (alertView.tag == ALERT_VEIW_ASK_QUESTION_TAG ) {
            NSString *question = [alertView textFieldAtIndex:0].text;
            if (question.length == 0) {
                [URAlertView showMessage:@"You must enter a question to enter the queue."];
            } else {
                [_networkManager enterQueueWithQuestion:question];
            }
            
        }

    }
}

@end
