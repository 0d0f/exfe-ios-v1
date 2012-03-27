//
//  CrossCellView.h
//  exfe
//
//  Created by 霍 炬 on 9/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface CrossCellView : UITableViewCell  {
    IBOutlet UILabel *cellText;
    IBOutlet UILabel *cellTime;
    IBOutlet UILabel *cellPlace;
    IBOutlet UIImageView *cellAvatar;
}
- (void)setLabelText:(NSString *)_text;
- (void)setLabelTime:(NSString *)_text;
- (void)setLabelPlace:(NSString *)_text;
- (void)setAvartar:(UIImage*)_img;
- (void)setNewTitleColor:(BOOL)_new;
- (void)setCellModel:(int)type;
@end
