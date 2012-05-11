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
#import "NSObject+SBJson.h"
#import <QuartzCore/QuartzCore.h>
#import "OAuthLoginViewController.h"

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
- (IBAction) TwitterLoginButtonPress:(id) sender
{
    OAuthLoginViewController *oauth = [[OAuthLoginViewController alloc] initWithNibName:@"OAuthLoginViewController" bundle:nil];
    oauth.delegate=self;
//    exfeAppDelegate* app=(exfeAppDelegate*)[[UIApplication sharedApplication] delegate];  

//    [app.navigationController presentModalViewController:oauth animated:YES];

    [self presentModalViewController:oauth animated:YES];

    
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:oauth];
//    [self presentModalViewController:nav animated:YES];        
    
//    [nav release];


//    NSLog(@"TwitterLoginButtonPress");
}
- (void)OAuthloginViewControllerDidCancel:(UIViewController *)oauthlogin {
    [self dismissModalViewControllerAnimated:YES];        
    [oauthlogin release]; 
    oauthlogin = nil; 
}
-(void)OAuthloginViewControllerDidSuccess:(OAuthLoginViewController *)oauthloginViewController userid:(NSString*)userid username:(NSString*)username external_id:(NSString*)external_id token:(NSString*)token
{
    [self loginSuccessWithUserId:userid username:username external_id:external_id token:token];
}


- (IBAction) LoginButtonPress:(id) sender
{
    textPassword.layer.borderColor=[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1].CGColor; 
    textUsername.layer.borderColor=[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1].CGColor; 
    NSString *password=[textPassword text];
    NSString *username=[textUsername text];

    [activityIndicatorview setHidden:NO];
    [activityIndicatorview startAnimating];   
    [hint setText:@""];
    [loginbtn setEnabled:NO];
    [loginbtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    dispatch_queue_t loginQueue = dispatch_queue_create("dologin", NULL);
    dispatch_async(loginQueue, ^{
        APIHandler *api=[[APIHandler alloc]init];
        NSString *responseString=[api checkUserLoginByUsername:username withPassword:password];
        [api release];
        NSDictionary *logindict = [responseString JSONValue];
        [responseString release];
        id code=[[logindict objectForKey:@"meta"] objectForKey:@"code"];
        if([code isKindOfClass:[NSNumber class]] && [code intValue]==200)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *userdict=[logindict objectForKey:@"response"];
            [self loginSuccessWithUserId:[userdict objectForKey:@"userid"] username:[textUsername text] external_id:[textUsername text] token:[userdict objectForKey:@"auth_token"]];
            });
        }
        else
        {            
            dispatch_async(dispatch_get_main_queue(), ^{
            if([[[logindict objectForKey:@"meta"] objectForKey:@"code"] intValue]==404)
                [hint setText:@"Incorrect identity or password"];
                [activityIndicatorview stopAnimating]; 
                [activityIndicatorview setHidden:YES];
                [loginbtn setEnabled:YES];
                [loginbtn setTitleColor:[UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1] forState:UIControlStateNormal];
            });
        }
    });
    dispatch_release(loginQueue);        
}
- (void) loginSuccessWithUserId:(NSString*)userid username:(NSString*)username external_id:(NSString*)external_id token:(NSString*)token
{
    [[NSUserDefaults standardUserDefaults] setObject:username  forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"api_key"];
    [[NSUserDefaults standardUserDefaults] setObject:userid  forKey:@"userid"];
    [[NSUserDefaults standardUserDefaults] setObject:external_id  forKey:@"external_id"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    exfeAppDelegate *app=(exfeAppDelegate *)[[UIApplication sharedApplication] delegate];
    app.api_key=token;
    app.userid=[userid intValue];
    app.username=username;
    app.external_id=external_id;
    
    [self.navigationController navigationBar].topItem.title=app.username;
    app.meViewReload=YES;
    [self.delegate loginViewControllerDidFinish:self];
    [activityIndicatorview stopAnimating]; 
    [activityIndicatorview setHidden:YES];
    [loginbtn setEnabled:YES];
    [loginbtn setTitleColor:[UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1] forState:UIControlStateNormal];    
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
    [activityIndicatorview setHidden:YES];   
    
    UIImage *signbtnimg = [UIImage imageNamed:@"signoutbtn.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Sign In" forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:18]]; 
    [button setTitleColor:[UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1] forState:UIControlStateNormal];
    [button setBackgroundImage:signbtnimg forState:UIControlStateNormal];
    [button setFrame:CGRectMake(121, 171, 116, 36)];  
    
    [button addTarget:self action:@selector(LoginButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [activityIndicatorview setFrame:CGRectMake(91, 7, 20, 20)];  
    [button addSubview:activityIndicatorview];
    
    [textUsername becomeFirstResponder];
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
