//
//  exfeAppDelegate.m
//  exfe
//
//  Created by huoju on 3/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "exfeAppDelegate.h"
#import "NewsViewController.h"
#import "RootViewController.h"
#import "APIHandler.h"

@implementation exfeAppDelegate


@synthesize window=_window;
@synthesize navigationController=_navigationController;
@synthesize registered;
@synthesize username;
@synthesize api_key;
@synthesize tabBarController;
@synthesize meViewReload;
@synthesize userid;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    meViewReload=NO;
    
    // Override point for customization after application launch.
    // Add the navigation controller's view to the window and display.
    self.window.rootViewController = self.navigationController;
    
	UITabBarItem *customItem1 = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:nil] tag:0];
	UITabBarItem *customItem2 = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:nil] tag:1];
	UITabBarItem *customItem3 = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:nil] tag:2];
	
    
	NewsViewController *newsview=[[NewsViewController alloc] initWithNibName:@"NewsViewController" bundle:[NSBundle mainBundle]];
	newsview.title=@"News";
	newsview.tabBarItem.image= [UIImage imageNamed: @"news.png"];
    
	MeViewController *meview=[[MeViewController alloc] initWithNibName:@"MeViewController" bundle:[NSBundle mainBundle]];
	meview.title=@"Me";
	meview.tabBarItem.image= [UIImage imageNamed: @"me.png"];

	tabBarController = [[UITabBarController alloc] init];
    
    self.navigationController.title=@"Home";
    self.navigationController.tabBarItem.image= [UIImage imageNamed: @"sheet.png"];
    
//    id a=self.window.rootViewController;
    
    
	tabBarController.viewControllers = [NSArray arrayWithObjects:self.navigationController , newsview,meview, nil];

	[tabBarController setTabBarItem:customItem1];
	[tabBarController setTabBarItem:customItem2];
	[tabBarController setTabBarItem:customItem3];

    //	tabBarController.tabBarItem = customItem1;
    //	tabBarController.tabBarItem = customItem2;
	[customItem1 release];
	[customItem2 release];
	[customItem3 release];	

    
	[self.window addSubview:tabBarController.view]; 
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *uname=[[NSUserDefaults standardUserDefaults] stringForKey:@"username"]; 
    NSString *apikey=[[NSUserDefaults standardUserDefaults] stringForKey:@"api_key"]; 
    NSString *uidstr=[[NSUserDefaults standardUserDefaults] stringForKey:@"userid"]; 
    
    //check user login
    if(uname!=nil && [apikey length]>2 && [uidstr intValue]>0)
    {
        self.username=uname;
        self.api_key=apikey;
        self.userid=[uidstr intValue];
    }
    else
    {
        LoginViewController *loginview = [[LoginViewController alloc]
                                          initWithNibName:@"LoginViewController" bundle:nil];
        loginview.delegate=self;
        [tabBarController presentModalViewController:loginview animated:NO];
    }
    
    NSString *devicetokenreg=[[NSUserDefaults standardUserDefaults] stringForKey:@"devicetokenreg"]; 

    if(uname!=nil&& (devicetokenreg==nil || [devicetokenreg isEqualToString:@"YES"]==NO))
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    }
    [self.window makeKeyAndVisible];
    return YES;
}

- (IBAction) RefreshRootview:(id) sender
{
    NSArray *viewControllers = self.navigationController.viewControllers;
    
    RootViewController *rootViewController = [viewControllers objectAtIndex:0];

    [NSThread detachNewThreadSelector:@selector(LoadUserEvents) toTarget:rootViewController withObject:nil];
}
// Delegation methods
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString * tokenAsString = [[[deviceToken description] 
                                 stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] 
                                stringByReplacingOccurrencesOfString:@" " withString:@""];
    
//    NSString *token=[[NSString alloc]initWithData:deviceToken encoding:
//                     NSASCIIStringEncoding];
    NSLog(@"deviceToken: %@", tokenAsString);
    APIHandler *api=[[APIHandler alloc]init];
    BOOL reg=[api regDeviceToken:tokenAsString];
    if(reg==YES)
        [[NSUserDefaults standardUserDefaults] setObject:@"YES"  forKey:@"devicetokenreg"];
    [api release];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    NSLog(@"收到推送消息 ：%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]);
    if ([[userInfo objectForKey:@"aps"] objectForKey:@"alert"]!=NULL) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"推送通知"
                                                        message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]
                                                       delegate:self
                                              cancelButtonTitle:@"关闭"
                                              otherButtonTitles:@"更新状态",nil];
        [alert show];
        [alert release];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

-(void)loginViewControllerDidFinish:(LoginViewController *)loginViewController {
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];

    [tabBarController dismissModalViewControllerAnimated:YES];
    
}

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [super dealloc];
}

@end
