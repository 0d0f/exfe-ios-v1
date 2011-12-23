//
//  UserSettingViewController.m
//  exfe
//
//  Created by ju huo on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UserSettingViewController.h"
#import "exfeAppDelegate.h"
#import "RootViewController.h"
#import "DBUtil.h"
#import "APIHandler.h"
#import "JSON/SBJson.h"
#import "ImgCache.h"
#import "Identity.h"

@implementation UserSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (IBAction) Logout:(id) sender
{
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"api_key"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"userid"];
    DBUtil *dbu=[DBUtil sharedManager];
    [dbu emptyDBData];
    
    exfeAppDelegate* app=(exfeAppDelegate*)[[UIApplication sharedApplication] delegate];  
    
    NSArray *viewControllers = app.navigationController.viewControllers;
    RootViewController *rootViewController = [viewControllers objectAtIndex:0];
    [rootViewController emptyView];
    
    [app logoutViewControllerDidFinish:self];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    APIHandler *api=[[APIHandler alloc]init];
    NSString *responseString=[api getProfile];
    NSDictionary *profileDict = [responseString JSONValue];
    id code=[[profileDict objectForKey:@"meta"] objectForKey:@"code"];
    if([code isKindOfClass:[NSNumber class]] && [code intValue]==200)
    {
//identities
        id response=[profileDict objectForKey:@"response"];
        if([response isKindOfClass:[NSDictionary class]])
        {
            if(identitiesData == nil)
                identitiesData=[[NSMutableArray alloc] initWithCapacity:2];
            id identities = [response objectForKey:@"identities"];
            //identitiesData=identities;
            NSMutableArray* identities_section=[[NSMutableArray alloc] initWithCapacity:10];
            NSMutableArray* devices_section=[[NSMutableArray alloc] initWithCapacity:5];
            for(int i=0;i<[identities count];i++)
            {
                Identity* useridentity=[Identity initWithDict:[identities objectAtIndex:i]];
                if ([useridentity.provider isEqualToString:@"iOSAPN"])
                    [devices_section addObject:useridentity];    
                else
                    [identities_section addObject:useridentity];
            }
            if([identities_section count]>0)
                [identitiesData addObject:identities_section];
            if([devices_section count]>0)
                [identitiesData addObject:devices_section];
            
            id user = [response objectForKey:@"user"];
            if([user isKindOfClass:[NSDictionary class]])
            {
                NSDictionary* userdict=(NSDictionary*)user;
                NSString* atatar_file_name= [userdict objectForKey:@"avatar_file_name"];
                if(atatar_file_name)
                {
                dispatch_queue_t imgQueue = dispatch_queue_create("fetchurl thread", NULL);
            
                dispatch_async(imgQueue, ^{ 
                    NSString* imgName = [atatar_file_name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; 
                    NSString *imgurl = [ImgCache getImgUrl:imgName];
                
                    UIImage *image = [[ImgCache sharedManager] getImgFrom:imgurl];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(image!=nil && ![image isEqual:[NSNull null]]) 
                            [useravatar setImage:image];
                            //[cell setAvartar:image];
                    
                    });
                });
            
                dispatch_release(imgQueue);        
                }
                NSString* name= [userdict objectForKey:@"name"];
                [username setText:name];
            }

        }

        NSLog(@"profile:%@",responseString);
    }
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
//    self.topItem.titleView = label;
//    self.

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *uname=[[NSUserDefaults standardUserDefaults] stringForKey:@"username"]; 
    NSString *apikey=[[NSUserDefaults standardUserDefaults] stringForKey:@"api_key"];
    NSString *uidstr=[[NSUserDefaults standardUserDefaults] stringForKey:@"userid"]; 
    [[NSUserDefaults standardUserDefaults] synchronize];
    if(uname!=nil && [apikey length]>2 && [uidstr intValue]>0)
    {

    }
    else
    {
        exfeAppDelegate* app=(exfeAppDelegate*)[[UIApplication sharedApplication] delegate];  
        
        LoginViewController *loginview = [[LoginViewController alloc]
                                          initWithNibName:@"LoginViewController" bundle:nil];
        loginview.delegate=app;
        [app.navigationController presentModalViewController:loginview animated:YES];
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction) Done:(id) sender
{
    [self dismissModalViewControllerAnimated:YES];    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [identitiesData count];
}
//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSLog(@"count %i",[identitiesData count]);
    return [[identitiesData objectAtIndex:section] count];
//    return [identitiesData count];
}
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"tblProfileCellView";
    ProfileCellView *cell=(ProfileCellView*)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if(cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"ProfileCellView" owner:self options:nil];
        cell = tblCell;
    }
    Identity *userIdentity=[[identitiesData objectAtIndex:[indexPath section]]  objectAtIndex:indexPath.row];
    if([indexPath section]==0)
    {
        if(![userIdentity.name isEqualToString:@""])
            [cell setLabelName:userIdentity.name];
        else
            [cell setLabelName:userIdentity.external_username];
    
        [cell setLabelIdentity:userIdentity.external_identity];
        return cell;
    }
    else
    {
        
        UIImage *img = [UIImage imageNamed:@"device_iPhone.png"];
        [cell setAvartar:img];
        [cell setLabelName:@"iPhone"];
        return cell;
    }
//    User *user=[User initWithDict:[comment.userjson JSONValue]];
//    
//    [cell setLabelText:comment.comment];
//    [cell setLabelTime:comment.created_at];
//    dispatch_queue_t imgQueue = dispatch_queue_create("fetchurl thread", NULL);
//    dispatch_async(imgQueue, ^{
//        NSString* imgName = [user.avatar_file_name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; 
//        NSString *imgurl = [ImgCache getImgUrl:imgName];
//        UIImage *image = [[ImgCache sharedManager] getImgFrom:imgurl];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if(image!=nil && ![image isEqual:[NSNull null]]) 
//                [cell setAvartar:image];
//        });
//    });
//    
//    dispatch_release(imgQueue);        
//    return cell;
//    
}

@end
