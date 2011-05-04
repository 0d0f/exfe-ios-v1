//
//  EventViewController.h
//  exfe
//
//  Created by huoju on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EventViewController : UIViewController {
    IBOutlet UIWebView *webview;
    NSDictionary* event;
    int eventid;
    BOOL interceptLinks;

}
@property (retain,nonatomic) NSDictionary* event;
@property int eventid;
@property BOOL interceptLinks;

- (NSString*)GenerateHtmlWithEvent:(NSDictionary*)event;
@end
