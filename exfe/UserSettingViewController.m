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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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

@end
