//
//  exfeAppDelegate.m
//  exfe
//
//  Created by huoju on 3/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "exfeAppDelegate.h"
#import "RootViewController.h"
#import "APIHandler.h"
#import "DBUtil.h"
#import "EventViewController.h"

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
    [self copyResource];
    meViewReload=NO;
    [self.window addSubview:self.navigationController.view];
    [self.window makeKeyAndVisible];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *uname=[[NSUserDefaults standardUserDefaults] stringForKey:@"username"]; 
    NSString *apikey=[[NSUserDefaults standardUserDefaults] stringForKey:@"api_key"]; 
    NSString *uidstr=[[NSUserDefaults standardUserDefaults] stringForKey:@"userid"]; 
    
    [DBUtil sharedManager];
    [DBUtil upgradeDB];
    //check user login
    if(uname!=nil && [apikey length]>2 && [uidstr intValue]>0) {
        self.username=uname;
        self.api_key=apikey;
        self.userid=[uidstr intValue];
        NSString *devicetokenreg=[[NSUserDefaults standardUserDefaults] stringForKey:@"devicetokenreg"]; 
        NSString *devicetoken=[[NSUserDefaults standardUserDefaults] stringForKey:@"devicetoken"]; 

//        NSLog(@"%@",devicetoken);
        
        if(uname!=nil&& (devicetokenreg==nil || [devicetokenreg isEqualToString:@"YES"]==NO)){
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge ];
        }
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
    else {
        LoginViewController *loginview = [[LoginViewController alloc]
                                          initWithNibName:@"LoginViewController" bundle:nil];
        loginview.delegate=self;
        [self.navigationController presentModalViewController:loginview animated:YES];

    }
    
    NSDictionary *remoteNotif = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    if(remoteNotif)
    {
        [self ReceivePushData:remoteNotif RunOnForeground:FALSE];
    }

    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString * tokenAsString = [[[deviceToken description] 
                                 stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] 
                                stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    APIHandler *api=[[APIHandler alloc]init];
    BOOL reg=[api regDeviceToken:tokenAsString];
    if(reg==YES)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"YES"  forKey:@"devicetokenreg"];
        [[NSUserDefaults standardUserDefaults] setObject:tokenAsString  forKey:@"devicetoken"];
    }
    [api release];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
}

- (void)ReceivePushData:(NSDictionary*)userInfo RunOnForeground:(BOOL)isForeground
{
    NSArray *viewControllers = self.navigationController.viewControllers;
    RootViewController *rootViewController = [viewControllers objectAtIndex:0];

    if([[userInfo objectForKey:@"args"] objectForKey:@"cid"] !=NULL && ![[[userInfo objectForKey:@"args"] objectForKey:@"cid"] isEqualToString:@""])
    {
        if([[[userInfo objectForKey:@"args"] objectForKey:@"cid"] intValue]>0 )
        {
            int cross_id=[[[userInfo objectForKey:@"args"] objectForKey:@"cid"] intValue];
            NSString *type=[[userInfo objectForKey:@"args"] objectForKey:@"t"];
            dispatch_queue_t fetchDataQueue = dispatch_queue_create("fetch new data thread", NULL);
            
            dispatch_async(fetchDataQueue, ^{
                [rootViewController refresh];
                dispatch_async(dispatch_get_main_queue(), ^{
//                    NSLog(@"load new data complete, push view...");
                    if (isForeground != TRUE)
                    {
                        Cross *cross=[rootViewController getEventByCrossId:cross_id];
                        
                        if(cross!=nil)
                        {
                            EventViewController *detailViewController=[[EventViewController alloc]initWithNibName:@"EventViewController" bundle:nil];
                            detailViewController.eventid=cross_id;
                            detailViewController.eventobj=cross;
                            [self.navigationController pushViewController:detailViewController animated:YES];
                            if([type isEqualToString:@"c"])
                                [detailViewController loadConversationData];
                            [detailViewController release]; 	
                        }
                    }
                });
            });
            
            dispatch_release(fetchDataQueue);              
            //fetch, then push controller in mainqueue
            
        }
    }    
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    BOOL isForeground=TRUE;
    if(application.applicationState != UIApplicationStateActive)
        isForeground=FALSE;
    [self ReceivePushData:userInfo RunOnForeground:isForeground];
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
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    NSArray *viewControllers = self.navigationController.viewControllers;
    RootViewController *rootViewController = [viewControllers objectAtIndex:0];

    [rootViewController performSelectorInBackground:@selector(refresh) withObject:NO];
    
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

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
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge ];

    DBUtil *dbu=[DBUtil sharedManager];
    [dbu emptyDBCache];
    NSArray *viewControllers = self.navigationController.viewControllers;
    RootViewController *rootViewController = [viewControllers objectAtIndex:0];
    [rootViewController performSelector:@selector(initUI) withObject:NO];
    [self.navigationController dismissModalViewControllerAnimated:YES];
    
    [rootViewController refreshWithprogress:YES];
//    [rootViewController performSelector:@selector(LoadUserEvents:) withObject:NO];
//    UIApplication* mapp = [UIApplication sharedApplication];
//    mapp.networkActivityIndicatorVisible = YES;
//    dispatch_queue_t refreshQueue = dispatch_queue_create("refresh cross thread", NULL);
//    dispatch_async(refreshQueue, ^{
//        [rootViewController LoadUserEvents:NO];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [rootViewController.tableView reloadData];
//            mapp.networkActivityIndicatorVisible = NO;
//        });
//    });
}
-(void)logoutViewControllerDidFinish:(UserSettingViewController *)UserSettingViewController
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}
- (void)showLoginView
{
    LoginViewController *loginview = [[LoginViewController alloc]
                                      initWithNibName:@"LoginViewController" bundle:nil];
    loginview.delegate=self;
    [self.navigationController presentModalViewController :loginview animated:YES];    
    
}

- (void)copyResource
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *documentsDirectory = [paths objectAtIndex:0]; 
    
    
    NSArray* imagefiles =   [[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:nil];
    for (NSString *filenamefull in imagefiles) {
        NSString *filename = [[filenamefull componentsSeparatedByString:@"/"] lastObject];
        NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:filename];
        [[NSFileManager defaultManager] copyItemAtPath:filenamefull toPath:writableDBPath error:NULL];
    }
}


- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [super dealloc];
}

@end


