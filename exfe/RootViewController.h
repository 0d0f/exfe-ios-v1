//
//  RootViewController.h
//  exfe
//
//  Created by huoju on 3/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController {
	IBOutlet UIWebView *webview;
    BOOL interceptLinks;
    NSMutableData *responseData;
    NSMutableDictionary *eventData;
    UIBarButtonItem *barButtonItem;

    BOOL reload;
    NSTimer *timer;
}

@property BOOL interceptLinks;
@property BOOL reload;

- (void)LoadUserEvents;
- (BOOL)LoadUserEventsFromDB;
- (void)RenderEvents:(NSArray*)events tosave:(BOOL)save;
- (void)UpdateDBWithEventDicts:(NSArray*)events;
- (void) setReload;
- (void)refresh;
@end
