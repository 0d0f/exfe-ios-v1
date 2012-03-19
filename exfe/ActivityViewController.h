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
#import "NotificationConversationCellView.h"
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
- (NSString*)setMsgWithActivity:(Activity*)activity Label:(NIAttributedLabel*)label;
- (NSString*)setWithMsg:(Activity*)activity Label:(NIAttributedLabel*)label;
- (NSString*)string:(NSString *)sourceString reducedToWidth:(CGFloat)width withFont:(UIFont *)font;
- (void)pushback;
//- (NSString *) formattedDateRelativeToNow:(NSString*)datestr;//(NSDate *)date;

@end
