//
//  exfeAppDelegate.h
//  exfe
//
//  Created by huoju on 3/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "MeViewController.h"


@interface exfeAppDelegate : NSObject <UIApplicationDelegate,LoginViewControllerDelegate> {

    IBOutlet UIBarButtonItem *buttonRefresh;

    UITabBarController *tabBarController;
	BOOL meViewReload;

    BOOL registered;
    NSString *username;
    NSString *api_key;
    int userid;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property BOOL meViewReload;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *api_key;
@property int userid;
@property BOOL registered;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

-(void)loginViewControllerDidFinish:(LoginViewController *)loginViewController;
- (IBAction) RefreshRootview:(id) sender;
- (void)copyResource;
@end
