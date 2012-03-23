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
            [[NSUserDefaults standardUserDefaults] setObject:[textUsername text]  forKey:@"username"];
            [[NSUserDefaults standardUserDefaults] setObject:[userdict objectForKey:@"auth_token"] forKey:@"api_key"];
            [[NSUserDefaults standardUserDefaults] setObject:[userdict objectForKey:@"userid"]  forKey:@"userid"];
        
            [[NSUserDefaults standardUserDefaults] synchronize];
            exfeAppDelegate *app=(exfeAppDelegate *)[[UIApplication sharedApplication] delegate];
            app.api_key=[userdict objectForKey:@"auth_token"];
            app.userid=[[userdict objectForKey:@"userid"] intValue];
            app.username=[[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
                

//            self.navigationController.title=app.username;
            [self.navigationController navigationBar].topItem.title=app.username;
            app.meViewReload=YES;
            [self.delegate loginViewControllerDidFinish:self];
            [activityIndicatorview stopAnimating]; 
            [activityIndicatorview setHidden:YES];
            [loginbtn setEnabled:YES];
            [loginbtn setTitleColor:[UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1] forState:UIControlStateNormal];
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
    
    
    NSString *signoutbtnimgpath = [[NSBundle mainBundle] pathForResource:@"signoutbtn" ofType:@"png"];
    UIImage *signbtnimg = [UIImage imageWithContentsOfFile:signoutbtnimgpath];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Sign In" forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:18]]; 
    [button setTitleColor:[UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1] forState:UIControlStateNormal];
    [button setBackgroundImage:signbtnimg forState:UIControlStateNormal];
    [button setFrame:CGRectMake(110, 191, 100, 40)];  
    
    [button addTarget:self action:@selector(LoginButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
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
