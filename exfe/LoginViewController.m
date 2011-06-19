//
//  LoginViewController.m
//  exfe
//
//  Created by huoju on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "APIHandler.h"
#import "exfeAppDelegate.h"

@implementation LoginViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void) reloadUI
{
    
}
- (IBAction) LoginButtonPress:(id) sender;
{
    
    APIHandler *api=[[APIHandler alloc]init];
    NSString *responseString=[api checkUserLoginByUsername:[textUsername text] withPassword:[textPassword text]];
    [api release];
    NSDictionary *userdict = [responseString JSONValue];
    [responseString release];
    NSLog(@"login:%@ : %@",[userdict objectForKey:@"email"] ,[textUsername text]);
    if([userdict objectForKey:@"error"] ==nil)
    {
        NSLog(@"%@",[userdict objectForKey:@"authentication_token"]);
        [[NSUserDefaults standardUserDefaults] setObject:[textUsername text]  forKey:@"username"];
        [[NSUserDefaults standardUserDefaults] setObject:[userdict objectForKey:@"authentication_token"] forKey:@"api_key"];
        [[NSUserDefaults standardUserDefaults] setObject:[userdict objectForKey:@"id"]  forKey:@"userid"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        exfeAppDelegate* app=[[UIApplication sharedApplication] delegate];
        
        app.api_key=[userdict objectForKey:@"authentication_token"];
        app.userid=[[userdict objectForKey:@"id"] intValue];
        app.username=[textUsername text];
        app.meViewReload=YES;
        [self.delegate loginViewControllerDidFinish:self];
//        [app.meview test];
//        NSArray *viewControllers=app.tabBarController.viewControllers;

    }
    else
        [hint setText:[userdict objectForKey:@"error"]];
        
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
