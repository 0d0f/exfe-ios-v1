//
//  ActiveViewController.h
//  EXFE
//
//  Created by ju huo on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityCellView.h"
#import "NotificationCrossCellView.h"

#import "Activity.h"
#import "PullRefreshTableViewController.h"

@interface ActivityViewController : UIViewController {
//    IBOutlet UIToolbar* toolbar;
    IBOutlet UINavigationBar *navigationbar;
    IBOutlet UITableViewCell *tblCell;
    IBOutlet UITableView* tabview;
    NSMutableArray *activityList;
    
}

@property (retain,nonatomic) NSMutableArray* activityList;

- (IBAction) Done:(id) sender;
- (NSString*)getMsgWithActivity:(Activity*)activity;
- (NSString*)getWithMsg:(Activity*)activity;
- (void)pushback;
- (NSString *) formattedDateRelativeToNow:(NSString*)datestr;//(NSDate *)date;

@end
