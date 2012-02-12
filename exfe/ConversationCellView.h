//
//  ConversationCellView.h
//  exfe
//
//  Created by ju huo on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConversationCellView : UITableViewCell {
    IBOutlet UILabel *cellText;
    IBOutlet UILabel *cellTime;
    IBOutlet UIImageView *cellAvatar;
}

- (void)setLabelText:(NSString *)_text;
- (void)setLabelTime:(NSString *)_text;
- (void)setAvartar:(UIImage*)_img;
- (void)setCellHeightWithCommentHeight:(int)height;

@end
