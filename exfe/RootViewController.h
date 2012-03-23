//
//  RootViewController.h
//  exfe
//
//  Created by huoju on 3/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshTableViewController.h"
#import "CrossCellView.h"
#import "Cross.h"
#import "MBProgressHUD.h"

@interface RootViewController : PullRefreshTableViewController <MBProgressHUDDelegate> {
	IBOutlet UIWebView *webview;
    BOOL interceptLinks;
    NSMutableData *responseData;
    NSMutableDictionary *eventData;
    UIBarButtonItem *barButtonItem;
    IBOutlet UITableView *tableview;
    NSMutableArray* events;
    BOOL reload;
    BOOL notificationHint;
    BOOL uiInit;
    NSTimer *timer;
    IBOutlet CrossCellView *tblCell;
    UIButton *activeButton;
    
}

@property BOOL interceptLinks;
@property BOOL reload;

- (void)LoadUserEvents:(BOOL)isnew;
- (BOOL)LoadUserEventsFromDB;
- (void)LoadUpdate;
- (void)UpdateDBWithEventDicts:(NSArray*)events isnew:(BOOL)isnew;
- (void)refresh;
- (void)refreshWithprogress:(BOOL)show;
- (void)ShowSettingView;
- (void)ShowActiveView;
- (void)emptyView;
- (void)pushback;
- (void)initUI;
- (Cross*)getEventByCrossId:(int)cross_id;
- (void)setNotificationButton:(BOOL)status;
- (void)defaultChanged:(NSNotification *)notif;
- (void)newcrossChanged:(NSNotification *)notif;
- (void)cleanAllCrossStatus;
@end
