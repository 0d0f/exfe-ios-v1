//
//  CrossCellView.h
//  exfe
//
//  Created by 霍 炬 on 9/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CrossCellView : UITableViewCell  {
    IBOutlet UILabel *cellText;
    IBOutlet UILabel *cellTime;
    IBOutlet UIImageView *cellAvatar;
}
- (void)setLabelText:(NSString *)_text;
- (void)setLabelTime:(NSString *)_text;
- (void)setAvartar:(UIImage*)_img;
@end
