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
            app.username=[textUsername text];
                
            self.navigationController.title=app.username;
            
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
//    activityIndicatorview = [[UIActivityIndicatorView alloc] 
//                             initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    
//    activityIndicatorview.frame = CGRectMake(self.view.bounds.size.width / 2.0f - activityIndicatorview.frame.size.width /2.0f, self.view.bounds.size.height / 2.0f - activityIndicatorview.frame.size.height /2.0f, activityIndicatorview.frame.size.width, activityIndicatorview.frame.size.height);
//    [activityIndicatorview setBackgroundColor:[UIColor blackColor]];
//    [activityIndicatorview setAlpha:0.8]; 
//
//    [self.view addSubview:activityIndicatorview];  
//    [activityIndicatorview startAnimating];   
    
    //then add to the view

//    self.view.frame.size.height/2-80/2
//    self.view.frame.size.width/2 -80/2   

    
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
