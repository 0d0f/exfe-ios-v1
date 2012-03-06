//
//  ActivityCell.h
//  EXFE
//
//  Created by ju huo on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>
#import "NIAttributedLabel.h"
#import "Util.h"


@interface ActivityCellView : UITableViewCell{
    IBOutlet UIImageView *cellAvatar;
    IBOutlet UILabel *cellCrossTitle;
    IBOutlet NIAttributedLabel *cellActionMsg;
    IBOutlet UILabel *cellByTitle;
    IBOutlet UILabel *cellTime;
}
- (void)setLabelCrossTitle:(NSString *)_text;
- (void)setLabelTime:(NSString *)_text;
- (void)setActionMsg:(NSString *)_text;
- (void)setAttributedActionMsg:(CFMutableAttributedStringRef *)_text;
- (void)setByTitle:(NSString *)_title;
- (void)setAvartar:(UIImage*)_img;
- (void)setModel:(int)type height:(int)height;
- (void)hiddenBylineWithMsgHeight:(int)height;
- (void)showBylineWithMsgHeight:(int)height;
- (void)setChangeHighlightMode;

@property (nonatomic,retain) NIAttributedLabel *cellActionMsg;

@end
