//
//  URQueueViewController.m
//  ta_queue_ios
//
//  Created by Parker Wightman on 5/4/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import "URQueueViewController.h"
#import "URDefaults.h"
#import "URQuestionViewController.h"
#import "SSPullToRefresh.h"
@import WebKit;

// Table View Sections
#define STATUS_SECTION 0
#define TA_MESSAGE_SECTION 1
#define TA_SECTION 2
#define STUDENT_SECTION 3

@interface URQueueViewController () <SSPullToRefreshViewDelegate, WKScriptMessageHandler>

@property (strong, nonatomic) SSPullToRefreshView *pullToRefreshView;
@property (strong, nonatomic) WKWebView *webView;

@end

@implementation URQueueViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutTapped)];
    
    self.navigationItem.leftBarButtonItem = item;
    
    [URUser setCurrentUser:_currentUser];
    
    _networkManager = [[URQueueNetworkManager alloc] initWithQueue:_queue andUser:_currentUser];
    
    [_networkManager refreshQueue];
    
    if (_queue.studentsInQueue.count > 0) {
        [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:STUDENT_SECTION] animated:YES scrollPosition:UITableViewScrollPositionNone];
    }

    [_networkManager setDelegate:self];

    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"queueUpdate"];
    NSString *URLString = [[URDefaults currentBaseURL] stringByAppendingPathComponent:@"queue/ios"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    NSString *token = [[[NSString stringWithFormat:@"%@:%@", self.currentUser.userId, self.currentUser.token] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    NSString *header = [NSString stringWithFormat:@"Basic %@", token];
    [request addValue:header forHTTPHeaderField:@"Authorization"];
    self.webView.frame = CGRectMake(-1, -1, 1, 1);
    [self.view addSubview:self.webView];
    [self.webView loadRequest:request];
}

- (void) viewWillAppear:(BOOL)animated {
    [URQueueViewController setCurrentQueueController:self];
    NSLog(@"View Appeared");
}

- (void) viewWillDisappear:(BOOL)animated {
    [URQueueViewController setCurrentQueueController:nil];
}

- (void)viewDidLayoutSubviews {
    if(self.pullToRefreshView == nil) {
        self.pullToRefreshView = [[SSPullToRefreshView alloc] initWithScrollView:self.tableView delegate:self];
    }
}

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view {
    [self.pullToRefreshView startLoading];
    [self refreshQueue];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self updateQueueStateWithQueue:[URQueue withAttributes:message.body]];
}

#pragma mark NSTimer Methods

- (void) refreshQueue {
    [_networkManager refreshQueue];
}

#pragma mark URQueueNetworkManager methods

- (void) networkManager:(URQueueNetworkManager *)manager didReceiveQueueUpdate:(URQueue *)queue {
    [self updateQueueStateWithQueue:queue];
}

- (void)updateQueueStateWithQueue:(URQueue *)queue {
    self.queue = queue;

    self.navigationItem.title = queue.classNumber;
    
    [URStudent setCurrentUser:queue.currentUser];
    
    NSIndexPath *path = [_tableView indexPathForSelectedRow];

    [self.pullToRefreshView finishLoading];

    [_tableView reloadData];
    [_tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self setupUserActionToolbar];
}

- (void) networkManager:(URQueueNetworkManager *)manager didLogoutUser:(URUser *)user {
    self.didFinish();
}

- (void) networkManager:(URQueueNetworkManager *)manager didReceiveErrorCode:(NSInteger)code response:(id)response {
    // A 401 is the unauthorized status code, which must me they are no longer logged in and
    // the server timed them out.
    if (code == 401) {
        self.didFinish();
        [URAlertView showMessage:@"You are no longer logged in, possibly due to inactivity. Please login again." withStyle:UIAlertViewStyleDefault ok:nil cancel:nil];
    } 
    // Any other error could be anything, so display it to the user.
    else {
        [URAlertView showMessage:[URError errorMessageWithResponse:response] withStyle:UIAlertViewStyleDefault ok:nil cancel:nil];
    }
}

- (void) networkManager:(URQueueNetworkManager *)manager didReceiveConnectionError:(NSError *)error {
    [URAlertView showMessage:error.localizedDescription withStyle:UIAlertViewStyleDefault ok:nil cancel:nil];
}

#pragma mark UIViewController methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
		_cell.contentView.backgroundColor = ta.color;
		_cell.textLabel.backgroundColor = [UIColor clearColor];
		_cell.detailTextLabel.backgroundColor = [UIColor clearColor];
		
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
			_cell.contentView.backgroundColor = student.ta.color;
			_cell.textLabel.backgroundColor = [UIColor clearColor];
			_cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        } else {
			_cell.contentView.backgroundColor = [UIColor clearColor];
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
            cell.contentView.backgroundColor = [UIColor colorWithRed:0.0863 green:0.4941 blue:0.9843 alpha:1.0];
        }
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
    }
    
    // Show the disclosure if the student is asking a question in question-based mode
    if (_currentUser.isTa && _queue.isQuestionBased && indexPath.section == STUDENT_SECTION) {
        NSString *question = [[[_queue studentsInQueue] objectAtIndex:indexPath.row] question];
        if (question && question.length > 0) {
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    // Workaround for iOS 8 bug that causes detail text labels not to show up properly.
    // http://stackoverflow.com/questions/25987135/ios-8-uitableviewcell-detail-text-not-correctly-updating
    [cell layoutSubviews];
    
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
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Exit Queue" style:UIBarButtonItemStylePlain target:self action:@selector(exitQueue)];
        [items addObject:item];
    }
    else {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Enter Queue" style:UIBarButtonItemStylePlain target:self action:@selector(enterQueue)];
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
                UIBarButtonItem *item =[[UIBarButtonItem alloc] initWithTitle:@"Put Back" style:UIBarButtonItemStylePlain target:self action:@selector(putBackStudent)];
                
                [items addObject:item];
            }
        } else {
            UIBarButtonItem *item =[[UIBarButtonItem alloc] initWithTitle:@"Accept" style:UIBarButtonItemStylePlain target:self action:@selector(acceptStudent)];
            
            [items addObject:item];
        }
        
        UIBarButtonItem *item =[[UIBarButtonItem alloc] initWithTitle:@"Remove" style:UIBarButtonItemStylePlain target:self action:@selector(removeStudent)];
        
        [items addObject:item];
    }
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [items addObject:item];
    
    NSString *active = (_queue.active ? @"Deactivate" : @"Activate");

    
    item =[[UIBarButtonItem alloc] initWithTitle:active style:UIBarButtonItemStylePlain target:self action:@selector(toggleActive)];
    
    [items addObject:item];
    
    // You can't freeze/unfreeze the queue unless it is active
    if (_queue.active) {
        NSString *frozen = (_queue.frozen ? @"Unfreeze" : @"Freeze");
        
        item =[[UIBarButtonItem alloc] initWithTitle:frozen style:UIBarButtonItemStylePlain target:self action:@selector(toggleFrozen)];
        
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
        
        [URAlertView showMessage:@"What is your question? (You must enter one to enter the queue.)"
                       withStyle:UIAlertViewStylePlainTextInput
                              ok:^(UIAlertView *alertView, NSString *text) {
                                  if (text.length == 0) {
                                      [URAlertView showMessage:@"You must enter a question to enter the queue." withStyle:UIAlertViewStyleDefault ok:nil cancel:nil];
                                  } else {
                                      [_networkManager enterQueueWithQuestion:text];
                                  }
                              } cancel:nil];
    } else {
        [_networkManager enterQueue];
    }
}

- (void) exitQueue {
    [_networkManager exitQueue];
}


- (void) logoutTapped {
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"queueUpdate"];
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
            [URAlertView showMessage:@"Enter New Status" withStyle:UIAlertViewStylePlainTextInput ok:^(UIAlertView *alertView, NSString *text){
                [_networkManager updateQueueStatus:[[alertView textFieldAtIndex:0] text]];
            } cancel:nil];
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


@end
