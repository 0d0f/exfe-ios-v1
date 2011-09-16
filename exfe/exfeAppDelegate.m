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
    
    self.window.rootViewController = self.navigationController;
   
    self.navigationController.title=@"Home";

    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *uname=[[NSUserDefaults standardUserDefaults] stringForKey:@"username"]; 
    NSString *apikey=[[NSUserDefaults standardUserDefaults] stringForKey:@"api_key"]; 
    NSLog(@"api_key:%@",apikey);
    NSString *uidstr=[[NSUserDefaults standardUserDefaults] stringForKey:@"userid"]; 
    
    [DBUtil sharedManager];
    //check user login
    if(uname!=nil && [apikey length]>2 && [uidstr intValue]>0)
    {
        self.username=uname;
        self.api_key=apikey;
        self.userid=[uidstr intValue];
        NSString *devicetokenreg=[[NSUserDefaults standardUserDefaults] stringForKey:@"devicetokenreg"]; 
        
        if(uname!=nil&& (devicetokenreg==nil || [devicetokenreg isEqualToString:@"YES"]==NO))
        {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge ];
        }
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        NSArray *viewControllers = self.navigationController.viewControllers;
        RootViewController *rootViewController = [viewControllers objectAtIndex:0];
        [NSThread detachNewThreadSelector:@selector(refresh) toTarget:rootViewController withObject:nil];
    }
    else
    {
        LoginViewController *loginview = [[LoginViewController alloc]
                                          initWithNibName:@"LoginViewController" bundle:nil];
        loginview.delegate=self;
        [self.navigationController presentModalViewController:loginview animated:YES];

    }
    CGRect statusRect;
    statusRect.size.width = [self.navigationController.view frame].size.width;
    statusRect.size.height = 28; // Not this height is hard coded
    statusRect.origin.x = 0;
    statusRect.origin.y = [self.navigationController.view frame].size.height-28; 
    
    // Note that 120 is hard coded: would be better to find the height to subtract from the existing views
    
    // Create the status bar/toolbar	
//    statusView = [[UIToolbar alloc] initWithFrame:statusRect];
//    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:statusRect];
//


//    [self.navigationController.view  addSubview:toolbar];

//TODO FIX:    [self.window makeKeyAndVisible];
    return YES;
}

- (IBAction) RefreshRootview:(id) sender
{
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
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
    
    NSLog(@"收到推送消息 ：%@",userInfo);
    if([[userInfo objectForKey:@"c"] objectForKey:@"eid"] !=NULL && [[userInfo objectForKey:@"c"] objectForKey:@"t"]!=NULL)
    {
        NSLog(@"get event id:%@ , type:%@",[[userInfo objectForKey:@"c"] objectForKey:@"eid"],[[userInfo objectForKey:@"c"] objectForKey:@"t"]);

        if( [[[userInfo objectForKey:@"c"] objectForKey:@"t"] isEqualToString:@"i"])
        {
//            NSArray *viewControllers = self.navigationController.viewControllers;
//            RootViewController *rootViewController = [viewControllers objectAtIndex:0];
            EventViewController *detailViewController=[[EventViewController alloc]initWithNibName:@"EventViewController" bundle:nil];

            detailViewController.eventid=[[[userInfo objectForKey:@"c"] objectForKey:@"eid"] intValue];

            [self.navigationController pushViewController:detailViewController animated:YES];
            [detailViewController release]; 	
        }
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
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge ];

    DBUtil *dbu=[DBUtil sharedManager];
    [dbu emptyDBCache];
    NSArray *viewControllers = self.navigationController.viewControllers;
    RootViewController *rootViewController = [viewControllers objectAtIndex:0];

//    [NSThread detachNewThreadSelector:@selector(LoadUserEvents) toTarget:rootViewController withObject:nil];

    [self.navigationController dismissModalViewControllerAnimated:YES];
    [rootViewController performSelector:@selector(LoadUserEvents) withObject:nil];

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

        

        //    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"*.png"];

    }
//    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
//    if (commonDictionaryPath = [thisBundle pathForResource:@"CommonDictionary" ofType:@"plist"])  {
        // when completed, it is the developer's responsibility to release theDictionary
//    }    
    
//    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"*.png"];
//    
//    NSString *olddbpath=[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"*.png"];
//    
//    if (![[NSFileManager defaultManager] isReadableFileAtPath:writableDBPath]) {
//		
//        if ([[NSFileManager defaultManager] copyItemAtPath:olddbpath toPath:writableDBPath error:NULL] != YES)
//			
//			NSAssert2(0, @"Fail to copy database from %@ to %@", olddbpath, writableDBPath);
//    }

}
- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [super dealloc];
}

@end
