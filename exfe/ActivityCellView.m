//
//  ActivityCell.m
//  EXFE
//
//  Created by ju huo on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ActivityCellView.h"

@implementation ActivityCellView

@synthesize cellActionMsg;

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
    [cellActionMsg setText:_text];
    [cellActionMsg setTextColor:[UIColor blueColor] range:NSMakeRange(0,5)];
}
- (void)setLabelTime:(NSString *)_text {
    cellTime.text=_text;
}
- (void)setAvartar:(UIImage*)_img {
    cellAvatar.image=_img;
    cellAvatar.layer.cornerRadius = 5.0;
    cellAvatar.layer.masksToBounds = YES;
    
}
- (void)setByTitle:(NSString *)_title {
    cellByTitle.text=_title;
}

- (void)setCellHeightWithMsgHeight:(int)height { 
    CGRect rect=self.frame;
    rect.size.height=66-21+height;
    [self setFrame:rect];
    
    CGRect msgrect=cellActionMsg.frame;
    float yoffset=height-msgrect.size.height;
    msgrect.size.height=height;
    msgrect.origin.y=cellCrossTitle.frame.size.height+cellCrossTitle.frame.origin.y+2;
    [cellActionMsg setFrame:msgrect];

    CGRect byrect=cellByTitle.frame;
    byrect.origin.y+=yoffset;
    [cellByTitle setFrame:byrect];
    
    CGRect timerect=cellTime.frame;
    timerect.origin.y+=yoffset;
    [cellTime setFrame:timerect];
}
- (void)setModel:(int)type height:(int)height {
    if(type==0) // 3 line mode
    {
        CGRect rect=self.frame;
        rect.size.height=58;
        [self setFrame:rect];
        CGRect timerect=cellTime.frame;
        timerect.origin.y=58-18;//msgrect.origin.y+msgrect.size.height-timerect.size.height;
        [cellTime setFrame:timerect];
        
        if(height==15)
        {
            CGRect msgrect=cellActionMsg.frame;
            msgrect.size.height=15;
            [cellActionMsg setFrame:msgrect];
        }
    }
    else if(type==1)
    {
        if(height==15)
        {
            CGRect msgrect=cellActionMsg.frame;
            msgrect.size.height=15;
            [cellActionMsg setFrame:msgrect];
        }
    }
}
- (void)hiddenBylineWithMsgHeight:(int)height {
//    [cellByTitle setHidden:YES];
    cellByTitle.text=@"";
    CGRect msgrect=cellActionMsg.frame;
    msgrect.size.height=height;
    [cellActionMsg setFrame:msgrect];
}
- (void)showBylineWithMsgHeight:(int)height{
    CGRect msgrect=cellActionMsg.frame;
    msgrect.size.height=height;
    [cellActionMsg setFrame:msgrect];
    
}
- (void)setAttributedActionMsg:(CFMutableAttributedStringRef *)_text{
    
}
- (void)setChangeHighlightMode{
    [cellActionMsg setTextColor:[Util getHighlightColor]];
}
@end
