//
//  NotificationConversationCellView.h
//  EXFE
//
//  Created by ju huo on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface NotificationConversationCellView : UITableViewCell{
    IBOutlet UIImageView *cellAvatar;
    IBOutlet UILabel *cellCrossTitle;
    IBOutlet UILabel *cellCrossDetail;
    IBOutlet UILabel *cellTime;
}

- (void)setLabelCrossTitle:(NSString *)_text;
- (void)setMsg:(NSString *)_text;
- (void)setLabelTime:(NSString *)_text;
- (void)setAvartar:(UIImage*)_img;
- (void)setHeight:(int)height;

@end
