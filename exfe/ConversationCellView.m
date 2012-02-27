//
//  ConversationCellView.m
//  exfe
//
//  Created by ju huo on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ConversationCellView.h"

@implementation ConversationCellView

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
    cellAvatar.layer.cornerRadius = 5.0;
    cellAvatar.layer.masksToBounds = YES;

}
- (void)setCellHeightWithCommentHeight:(int)height
{
    CGRect rect=self.frame;
    rect.size.height=44-18-1+height;
    [self setFrame:rect];
    
    CGRect commentrect=cellText.frame;
    commentrect.size.height=height;
    commentrect.origin.y=1;
    [cellText setFrame:commentrect];
    
    CGRect timerect=cellTime.frame;
    timerect.origin.y=rect.size.height-18;

    [cellTime setFrame:timerect];
    
}
@end
