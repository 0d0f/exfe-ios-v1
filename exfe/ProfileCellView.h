//
//  ProfileCellView.h
//  EXFE
//
//  Created by ju huo on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileCellView : UITableViewCell{
    IBOutlet UILabel *cellName;
    IBOutlet UILabel *cellIdentity;
    IBOutlet UIImageView *cellAvatar;
    IBOutlet UIImageView *cellStatus;    
}
- (void)setLabelName:(NSString *)_text;
- (void)setLabelIdentity:(NSString *)_text;
- (void)setCellStatus:(UIImage *)_img;
- (void)setAvartar:(UIImage*)_img;

@end
