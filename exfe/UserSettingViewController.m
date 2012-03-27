//
//  UserSettingViewController.m
//  exfe
//
//  Created by ju huo on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UserSettingViewController.h"
#import "exfeAppDelegate.h"
#import "RootViewController.h"
#import "DBUtil.h"
#import "APIHandler.h"
#import "JSON/SBJson.h"
#import "ImgCache.h"
#import "Identity.h"
#import "UIBarButtonItem+StyledButton.h"

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

- (void)dealloc
{
    [identitiesData release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (IBAction) Logout:(id) sender
{
    NSString *token=[[[NSUserDefaults standardUserDefaults] stringForKey:@"devicetoken"] copy];
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"api_key"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"userid"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"devicetoken"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"devicetokenreg"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"lastupdatetime"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"my_users"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"my_identities"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    DBUtil *dbu=[DBUtil sharedManager];
    [dbu emptyDBData];
    
    exfeAppDelegate* app=(exfeAppDelegate*)[[UIApplication sharedApplication] delegate];  
    
    NSArray *viewControllers = app.navigationController.viewControllers;
    RootViewController *rootViewController = [viewControllers objectAtIndex:0];
    [rootViewController emptyView];
    
    APIHandler *api=[[APIHandler alloc]init];
    NSString *responseString=[api disconnectDeviceToken:token];
//    NSLog(@"responseString:%@",responseString);
    [token release];
//    NSDictionary *profileDict = [responseString JSONValue];
    [api release];
    [responseString release];

    
    [app logoutViewControllerDidFinish:self];

}
- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    NSString *closesettingbtnimgpath = [[NSBundle mainBundle] pathForResource:@"close_settingbtn" ofType:@"png"];
    
    UIImage *closesettingbtnimg = [UIImage imageWithContentsOfFile:closesettingbtnimgpath];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setTitle:@"Close" forState:UIControlStateNormal];
    doneButton.titleLabel.font         = [UIFont boldSystemFontOfSize:12.0f];
    [doneButton setTitleColor:[UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1] forState:UIControlStateNormal];

    doneButton.titleEdgeInsets         = UIEdgeInsetsMake(0, 2, 0, 2);
    doneButton.contentStretch          = CGRectMake(0.5, 0.5, 0, 0);
    doneButton.contentMode             = UIViewContentModeScaleToFill;

    [doneButton setBackgroundImage:closesettingbtnimg forState:UIControlStateNormal];
    doneButton.frame = CGRectMake(0, 0, closesettingbtnimg.size.width, closesettingbtnimg.size.height);
    [doneButton addTarget:self action:@selector(Done:) forControlEvents:UIControlEventTouchUpInside];
    
    [toolbar setItems:[NSArray arrayWithObjects:flexibleSpaceLeft, [[[UIBarButtonItem alloc] initWithCustomView:doneButton] autorelease], nil]];
    
    [flexibleSpaceLeft release];

    id my_identities=[[NSUserDefaults standardUserDefaults] objectForKey:@"my_identities"];
    id my_users=[[NSUserDefaults standardUserDefaults] objectForKey:@"my_users"];
    if(my_identities && my_users)
    {
        NSMutableArray* sections=[NSKeyedUnarchiver unarchiveObjectWithData:my_identities];
//        NSMutableArray* identities=[sections objectAtIndex:0];
//        Identity* identity=[identities objectAtIndex:0];
        NSDictionary* user=[NSKeyedUnarchiver unarchiveObjectWithData:my_users];
        identitiesData= [sections retain];
        [self LoadData:user];
    }
    else {
        
        identitiesData=[[NSMutableArray alloc] initWithCapacity:2];
//        id identities = [response objectForKey:@"identities"];
        NSMutableArray* identities_section=[[NSMutableArray alloc] initWithCapacity:10];
        NSMutableArray* devices_section=[[NSMutableArray alloc] initWithCapacity:5];
//        for(int i=0;i<[identities count];i++)
//        {
//            Identity* useridentity=[Identity initWithDict:[identities objectAtIndex:i]];
//            if(useridentity.status==3)
//            {
//                if ([useridentity.provider isEqualToString:@"iOSAPN"])
//                    [devices_section addObject:useridentity];    
//                else
//                    [identities_section addObject:useridentity];
//            }
//        }
//        if([identities_section count]>0)
            [identitiesData addObject:identities_section];
//        if([devices_section count]>0)
            [identitiesData addObject:devices_section];
//        id user = [response objectForKey:@"user"];
        [devices_section release];
        [identities_section release];
        [tabview reloadData];
    }
    dispatch_queue_t fetchdataQueue = dispatch_queue_create("fetchdata thread", NULL);
    
    dispatch_async(fetchdataQueue, ^{
        APIHandler *api=[[APIHandler alloc]init];
        NSString *responseString=[api getProfile];
        NSDictionary *profileDict = [responseString JSONValue];
        [api release];
        [responseString release];
        id code=[[profileDict objectForKey:@"meta"] objectForKey:@"code"];
        if([code isKindOfClass:[NSNumber class]] && [code intValue]==200)
        {
            id response=[profileDict objectForKey:@"response"];
            if([response isKindOfClass:[NSDictionary class]])
            {
                if(identitiesData != nil)
                    [identitiesData release];
                identitiesData=[[NSMutableArray alloc] initWithCapacity:2];
                id identities = [response objectForKey:@"identities"];
                NSMutableArray* identities_section=[[NSMutableArray alloc] initWithCapacity:10];
                NSMutableArray* devices_section=[[NSMutableArray alloc] initWithCapacity:5];
                for(int i=0;i<[identities count];i++)
                {
                    Identity* useridentity=[Identity initWithDict:[identities objectAtIndex:i]];
                    if(useridentity.status==3)
                    {
                    if ([useridentity.provider isEqualToString:@"iOSAPN"])
                        [devices_section addObject:useridentity];    
                    else
                        [identities_section addObject:useridentity];
                    }
                }
                if([identities_section count]>0)
                    [identitiesData addObject:identities_section];
                if([devices_section count]>0)
                    [identitiesData addObject:devices_section];
                id user = [response objectForKey:@"user"];
                [devices_section release];
                [identities_section release];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSData *encodedidentitydata =[NSKeyedArchiver archivedDataWithRootObject:identitiesData];
                [[NSUserDefaults standardUserDefaults] setObject:encodedidentitydata  forKey:@"my_identities"];
                NSData *userentitydata =[NSKeyedArchiver archivedDataWithRootObject:user];
                [[NSUserDefaults standardUserDefaults] setObject:userentitydata  forKey:@"my_users"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self LoadData:user];
            });
            }
        }
    });
    dispatch_release(fetchdataQueue);        
}
- (void) LoadData:(id)user
{
    [tabview reloadData];
    if([user isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* userdict=(NSDictionary*)user;
        NSString* atatar_file_name= [userdict objectForKey:@"avatar_file_name"];
        if(atatar_file_name == nil || [atatar_file_name isEqualToString:@""])
            atatar_file_name = @"default.png";
        if(atatar_file_name)
        {
            dispatch_queue_t imgQueue = dispatch_queue_create("fetchurl thread", NULL);
            dispatch_async(imgQueue, ^{ 
                NSString* imgName = atatar_file_name;//[atatar_file_name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; 
                NSString *imgurl = [ImgCache getImgUrl:imgName];
                
                UIImage *image = [[ImgCache sharedManager] getImgFrom:imgurl];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(image!=nil && ![image isEqual:[NSNull null]]) 
                        [useravatar setImage:image];
                });
            });
            dispatch_release(imgQueue);        
        }
        NSString* name= [userdict objectForKey:@"name"];
        [username setText:name];
    }    
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
    [identitiesData release];
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
    return [[identitiesData objectAtIndex:section] count];
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
        if([userIdentity.avatar_file_name isEqualToString:@""])
        {
            UIImage *img = [UIImage imageNamed:@"default_avatar.png"];
            [cell setAvartar:img];
        }
        else
        {
            NSString* imgName = userIdentity.avatar_file_name;//[userIdentity.avatar_file_name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; 
            NSString *imgurl = [ImgCache getImgUrl:imgName];
            UIImage *img = [[ImgCache sharedManager] getImgFrom:imgurl];
            [cell setAvartar:img];
        }
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
        [cell setLabelStatus:1];
        [cell setAvartar:img];
        [cell setLabelName:userIdentity.external_username];
        
        if([userIdentity.external_identity isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"devicetoken"]])
        {
            [cell IsThisDevice:@""];
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(section == [identitiesData count]-1)
        return 40.0;
    return 1.0;
}
-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return 30.0;
    return 15.0;
}
-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//        return [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
    
    if(footerView == nil) {
        //allocate the view if it doesn't exist yet
        footerView  = [[UIView alloc] init];
        
        //create the button
        NSString *signoutbtnimgpath = [[NSBundle mainBundle] pathForResource:@"signoutbtn" ofType:@"png"];
        UIImage *signbtnimg = [UIImage imageWithContentsOfFile:signoutbtnimgpath];

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"Sign Out" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:18]]; 
        [button setTitleColor:[UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1] forState:UIControlStateNormal];
        [button setBackgroundImage:signbtnimg forState:UIControlStateNormal];
        [button setFrame:CGRectMake(200, 10, 100, 40)];  
        
        [button addTarget:self action:@selector(Logout:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:button];
    }
    
    //return the view for the footer
    return footerView;
}
@end
