//
//  EventViewController.h
//  exfe
//
//  Created by huoju on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "Comment.h"
#import "Invitation.h"
#import "UIInputToolbar.h"
#import "PullRefreshTableViewController.h"
#import "ConversionTableViewController.h"


#define kStatusBarHeight 20
#define kDefaultToolbarHeight 40
#define kKeyboardHeightPortrait 216
#define kKeyboardHeightLandscape 140

@interface EventViewController : UIViewController {
//    UIViewController
    //IBOutlet UIWebView *conversationview;
    IBOutlet UIWebView *webview;
    IBOutlet UITableView *conversationview;
    IBOutlet UIView *baseview;
    IBOutlet UITableView *tableView;
    ConversionTableViewController *conversionViewController;
    
    NSDictionary* event;
    Event* eventobj;
    int eventid;
    BOOL interceptLinks;
    UIBarButtonItem *barButtonItem;
    BOOL showeventinfo;

    BOOL keyboardIsVisible;
    
    UIInputToolbar *inputToolbar;
    
    NSMutableArray *comments;

}
@property (retain,nonatomic) NSDictionary* event;
@property (retain,nonatomic) Event* eventobj;
@property int eventid;
@property BOOL interceptLinks;
@property (nonatomic, retain) UIInputToolbar *inputToolbar;


- (NSString*)GenerateHtmlWithEvent;
- (void)refresh;
- (void)toconversation;
- (void)LoadEvent;
- (void)postComment:(NSString*)inputtext;
@end
