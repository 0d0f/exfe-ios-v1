//
//  UserSettingViewController.h
//  exfe
//
//  Created by ju huo on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileCellView.h"

@interface UserSettingViewController : UIViewController{

    IBOutlet UIToolbar* toolbar;
    IBOutlet UIImageView* useravatar;
    IBOutlet UILabel* username;
    IBOutlet UITableView* tabview;
    NSMutableArray *identitiesData;
    IBOutlet ProfileCellView *tblCell;
}

- (IBAction) Logout:(id) sender;
- (IBAction) Done:(id) sender;

@end
