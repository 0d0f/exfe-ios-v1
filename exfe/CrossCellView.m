//
//  CrossCellView.m
//  exfe
//
//  Created by 霍 炬 on 9/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CrossCellView.h"

@implementation CrossCellView

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

- (void)setLabelText:(NSString *)_text{
    cellText.text = _text;
}
- (void)setLabelTime:(NSString *)_text
{
    cellTime.text=_text;
}
- (void)setAvartar:(UIImage*)_img
{
    cellAvatar.image=_img;
}

@end
