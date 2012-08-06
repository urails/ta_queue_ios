//
//  URQuestionViewController.h
//  ta_queue_ios
//
//  Created by Parker Wightman on 8/4/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface URQuestionViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) NSString *question;

@end