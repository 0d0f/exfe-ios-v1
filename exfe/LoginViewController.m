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
    NSString *password=[textPassword text];
    NSString *username=[textUsername text];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];  
    [view setTag:103]; 
    [view setBackgroundColor:[UIColor blackColor]];
    [view setAlpha:0.8]; 
    [self.view addSubview:view];  
    activityIndicatorview = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    [activityIndicatorview setCenter:view.center]; 
    [activityIndicatorview setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];   
    [view addSubview:activityIndicatorview];  
    [view release]; 
    [activityIndicatorview startAnimating];   
    
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
            app.meViewReload=YES;
            [self.delegate loginViewControllerDidFinish:self];
            });
        }
        else
        {            
            dispatch_async(dispatch_get_main_queue(), ^{
            [hint setText:[[logindict objectForKey:@"meta"] objectForKey:@"error"]];
            });
        }
        [activityIndicatorview stopAnimating];  
        UIView *view = (UIView *)[self.view viewWithTag:103];   
        [view removeFromSuperview]; 
    
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
