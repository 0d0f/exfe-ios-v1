//
//  NotificationConversationCellView.m
//  EXFE
//
//  Created by ju huo on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NotificationConversationCellView.h"

@implementation NotificationConversationCellView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setLabelCrossTitle:(NSString *)_text {
    cellCrossTitle.text=_text;
}

- (void)setMsg:(NSString *)_text {
    cellCrossDetail.text=_text;
}

- (void)setLabelTime:(NSString *)_text {
    cellTime.text=_text;
}

- (void)setAvartar:(UIImage*)_img {
    cellAvatar.image=_img;
    cellAvatar.layer.cornerRadius = 5.0;
    cellAvatar.layer.masksToBounds = YES;
}
- (void)setHeight:(int)height {
    CGRect msgrect=cellCrossDetail.frame;
    msgrect.size.height=height;
    [cellCrossDetail setFrame:msgrect];

}
@end
