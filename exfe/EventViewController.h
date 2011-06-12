//
//  EventViewController.h
//  exfe
//
//  Created by huoju on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@interface EventViewController : UIViewController {
    IBOutlet UIWebView *conversationview;
    IBOutlet UIWebView *webview;
    NSDictionary* event;
    Event* eventobj;
    int eventid;
    BOOL interceptLinks;
    UIBarButtonItem *barButtonItem;
    BOOL showeventinfo;
}
@property (retain,nonatomic) NSDictionary* event;
@property (retain,nonatomic) Event* eventobj;
@property int eventid;
@property BOOL interceptLinks;

- (NSString*)GenerateHtmlWithEvent;
- (NSString*)GenerateHtmlWithComment:(NSDictionary*)event;
- (void)updateEventView;
- (void)refresh;
- (void)toconversation;
- (void)LoadEvent;
@end
