//
//  URStudentCell.m
//  ta_queue_ios
//
//  Created by Parker Wightman on 5/7/12.
//  Copyright (c) 2012 Mysterious Trousers. All rights reserved.
//

#import "URStudentCell.h"

@implementation URStudentCell

@synthesize acceptButton, removeButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
