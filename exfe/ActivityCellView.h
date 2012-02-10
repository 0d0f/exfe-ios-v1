//
//  ActivityCell.h
//  EXFE
//
//  Created by ju huo on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityCellView : UITableViewCell{
    IBOutlet UIImageView *cellAvatar;
    IBOutlet UILabel *cellCrossTitle;
    IBOutlet UILabel *cellActionMsg;
    IBOutlet UILabel *cellByTitle;
    IBOutlet UILabel *cellTime;
}
- (void)setLabelCrossTitle:(NSString *)_text;
- (void)setLabelTime:(NSString *)_text;
- (void)setActionMsg:(NSString *)_text;
- (void)setByTitle:(NSString *)_title;
- (void)setAvartar:(UIImage*)_img;
- (void)setCellHeightWithMsgHeight:(int)height;

@end
