//
//  ParseExampleCell.m
//  Chaine FM
//
//  Created by Mark McWhirter on 06/10/2013.
//  Copyright (c) 2013 Larne Community Media. All rights reserved.
//
#import "ParseExampleCell.h"

@implementation ParseExampleCell

@synthesize cellTitle;

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
