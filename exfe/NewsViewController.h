//
//  NewsViewController.h
//  exfe
//
//  Created by huoju on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NewsViewController : UIViewController {
    IBOutlet UIWebView *webview;
    UIBarButtonItem *barButtonItem;    
}
- (void)LoadUserNews;
@end
