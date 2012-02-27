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
- (void)setLabelPlace:(NSString *)_text
{
    cellPlace.text=_text;
}
- (void)setAvartar:(UIImage*)_img
{
    cellAvatar.image=_img;
    cellAvatar.layer.cornerRadius = 5.0;
    cellAvatar.layer.masksToBounds = YES;
}
- (void)setCellModel:(int)type
{
    if(type==1) //height = 44
    {
        [cellAvatar setFrame:CGRectMake(cellAvatar.frame.origin.x, 2, cellAvatar.frame.size.width, cellAvatar.frame.size.height)];
        [cellText setFrame:CGRectMake(cellText.frame.origin.x,11,cellText.frame.size.width,cellText.frame.size.height)];
    }
    else if (type == 2) //height = 61
    {
        [cellAvatar setFrame:CGRectMake(cellAvatar.frame.origin.x, 11, cellAvatar.frame.size.width, cellAvatar.frame.size.height)];
        [cellText setFrame:CGRectMake(cellText.frame.origin.x,10,cellText.frame.size.width,cellText.frame.size.height)];
        
    }
        
    
}
- (void)setNewTitleColor:(BOOL)_new
{
    if(_new==YES)
        cellText.textColor=[UIColor colorWithRed:5/255.0f green:145/255.0f blue:172/255.0f alpha:1];
    else
        cellText.textColor=[UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1];
}
@end
