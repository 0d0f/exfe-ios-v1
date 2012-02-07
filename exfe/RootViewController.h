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

@interface RootViewController : PullRefreshTableViewController{
//UIViewController {
	IBOutlet UIWebView *webview;
    BOOL interceptLinks;
    NSMutableData *responseData;
    NSMutableDictionary *eventData;
    UIBarButtonItem *barButtonItem;
    IBOutlet UITableView *tableview;
    NSMutableArray* events;
    BOOL reload;
    NSTimer *timer;
    IBOutlet CrossCellView *tblCell;
    
}

@property BOOL interceptLinks;
@property BOOL reload;

- (void)LoadUserEvents:(BOOL)isnew;
- (BOOL)LoadUserEventsFromDB;
- (void)LoadUpdate;
- (void)UpdateDBWithEventDicts:(NSArray*)events isnew:(BOOL)isnew;
- (void)refresh;
- (void)ShowSettingView;
- (void)ShowActiveView;
- (void)emptyView;
- (void)pushback;
- (void)initUI;
- (Cross*)getEventByCrossId:(int)cross_id;
@end
