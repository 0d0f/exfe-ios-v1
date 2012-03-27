//
//  NotificationCrossViewCell.m
//  EXFE
//
//  Created by ju huo on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NotificationCrossCellView.h"

@implementation NotificationCrossCellView
@synthesize cellInvitationMsg;
@synthesize cellwithMsg;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)setLabelCrossTitle:(NSString *)_text {
    cellCrossTitle.text=_text;
}

- (void)setCrossDetail:(NSString *)_text {
    cellCrossDetail.text=_text;
}

- (void)setWithMsg:(NSString *)_text {
    cellwithMsg.text=_text;
}
- (void)setInvitationMsg:(NSString *)_text{
    cellInvitationMsg.text=_text;
}

//- (void)setExfee:(NSString *)_text {
//    cellexfee.text=_text;
//}
- (void)setAvartar:(UIImage*)_img{
    cellAvatar.image=_img;
    cellAvatar.layer.cornerRadius = 5.0;
    cellAvatar.layer.masksToBounds = YES;
}
- (void)setLabelTime:(NSString *)_text {
    cellTime.text=_text;
}


@end
