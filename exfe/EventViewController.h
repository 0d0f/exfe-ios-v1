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

#define kStatusBarHeight 20
#define kDefaultToolbarHeight 40
#define kKeyboardHeightPortrait 216
#define kKeyboardHeightLandscape 140

@interface EventViewController : UIViewController {
    IBOutlet UIWebView *conversationview;
    IBOutlet UIWebView *webview;
    NSDictionary* event;
    Event* eventobj;
    int eventid;
    BOOL interceptLinks;
    UIBarButtonItem *barButtonItem;
    BOOL showeventinfo;

    BOOL keyboardIsVisible;
    
    UIInputToolbar *inputToolbar;

}
@property (retain,nonatomic) NSDictionary* event;
@property (retain,nonatomic) Event* eventobj;
@property int eventid;
@property BOOL interceptLinks;
@property (nonatomic, retain) UIInputToolbar *inputToolbar;


- (NSString*)GenerateHtmlWithEvent;
- (NSString*)GenerateHtmlWithComment;
- (void)updateEventView;
- (void)updateConversationView;
- (void)refresh;
- (void)toconversation;
- (void)LoadEvent;
@end
