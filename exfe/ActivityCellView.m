//
//  ActivityCell.m
//  EXFE
//
//  Created by ju huo on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ActivityCellView.h"

@implementation ActivityCellView

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
}
- (void)setLabelCrossTitle:(NSString *)_text {
    cellCrossTitle.text=_text;
}

- (void)setActionMsg:(NSString *)_text {
    cellActionMsg.text=_text;
}
- (void)setLabelTime:(NSString *)_text {
    cellTime.text=_text;
}
- (void)setAvartar:(UIImage*)_img {
    cellAvatar.image=_img;
}

- (void)setCellModel:(int)type {
    
}

@end
