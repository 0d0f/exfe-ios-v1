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

@interface RootViewController : PullRefreshTableViewController{
//UIViewController {
	IBOutlet UIWebView *webview;
    BOOL interceptLinks;
    NSMutableData *responseData;
    NSMutableDictionary *eventData;
    UIBarButtonItem *barButtonItem;
    IBOutlet UITableView *tableview;
    NSArray* events;
    BOOL reload;
    NSTimer *timer;
    
    IBOutlet CrossCellView *tblCell;
    
}

@property BOOL interceptLinks;
@property BOOL reload;

- (void)LoadUserEvents;
- (BOOL)LoadUserEventsFromDB;
- (void)UpdateDBWithEventDicts:(NSArray*)events;
- (void) refresh;
- (void)dorefresh;
@end
