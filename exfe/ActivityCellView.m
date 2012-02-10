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
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *time_datetime = [dateFormat dateFromString:_text]; 
    [dateFormat setDateFormat:@"HH:mm MM-dd"];
    cellTime.text=[dateFormat stringFromDate:time_datetime]; 
    [dateFormat release];
}
- (void)setAvartar:(UIImage*)_img {
    cellAvatar.image=_img;
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

@end
