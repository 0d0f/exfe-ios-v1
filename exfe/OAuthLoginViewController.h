//
//  OAuthLoginViewControllerViewController.h
//  EXFE
//
//  Created by ju huo on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol OAuthLoginViewControllerDelegate;
@interface OAuthLoginViewController : UIViewController
{
    id<OAuthLoginViewControllerDelegate> delegate;
    IBOutlet UIWebView *webView;
}
@property (nonatomic, assign) id <OAuthLoginViewControllerDelegate> delegate;

@end


@protocol OAuthLoginViewControllerDelegate
-(void)OAuthloginViewControllerDidCancel:(OAuthLoginViewController *)oauthloginViewController;
-(void)OAuthloginViewControllerDidSuccess:(OAuthLoginViewController *)oauthloginViewController userid:(NSString*)userid username:(NSString*)username token:(NSString*)token;


@end