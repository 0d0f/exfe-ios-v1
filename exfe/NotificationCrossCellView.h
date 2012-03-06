//
//  NotificationCrossViewCell.h
//  EXFE
//
//  Created by ju huo on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "NIAttributedLabel.h"

@interface NotificationCrossCellView : UITableViewCell{
    IBOutlet UIImageView *cellAvatar;
    IBOutlet UILabel *cellCrossTitle;
    IBOutlet UILabel *cellCrossDetail;
    IBOutlet NIAttributedLabel *cellwithMsg;
    IBOutlet NIAttributedLabel *cellInvitationMsg;
//    IBOutlet UILabel *cellexfee;
    IBOutlet UILabel *cellTime;
}
- (void)setLabelCrossTitle:(NSString *)_text;
- (void)setCrossDetail:(NSString *)_text;
- (void)setWithMsg:(NSString *)_text;
- (void)setInvitationMsg:(NSString *)_text;
//- (void)setExfee:(NSString *)_text;
- (void)setLabelTime:(NSString *)_text;
- (void)setAvartar:(UIImage*)_img;

@property (nonatomic,retain) NIAttributedLabel *cellInvitationMsg;
@property (nonatomic,retain) NIAttributedLabel *cellwithMsg;

//- (void)setActionMsg:(NSString *)_text;
//- (void)setByTitle:(NSString *)_title;
//- (void)setAvartar:(UIImage*)_img;
//- (void)setCellHeightWithMsgHeight:(int)height;

@end
