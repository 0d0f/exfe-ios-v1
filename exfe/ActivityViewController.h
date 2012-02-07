//
//  ActiveViewController.h
//  EXFE
//
//  Created by ju huo on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityCellView.h"
#import "PullRefreshTableViewController.h"

@interface ActivityViewController : UIViewController {
//    IBOutlet UIToolbar* toolbar;
    IBOutlet UINavigationBar *navigationbar;
    IBOutlet ActivityCellView *tblCell;
    IBOutlet UITableView* tabview;
    NSMutableArray *activityList;
    
}

@property (retain,nonatomic) NSMutableArray* activityList;

- (IBAction) Done:(id) sender;
@end
