//
//  MemberCustomCell.m
//  rainsync
//
//  Created by 승원 김 on 12. 11. 14..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import "MemberCustomCell.h"

@implementation MemberCustomCell

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

- (void)dealloc {
    [_memberImage release];
    [_memberName release];
    [_coverImage release];
    [_memberNumber release];
    [_serverStatusImage release];
    [_serverStatus release];
    [_memberSpeed release];
    [super dealloc];
}
@end
