//
//  MeViewController.m
//  exfe
//
//  Created by huoju on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MeViewController.h"
#import "exfeAppDelegate.h"
#import "APIHandler.h"
#import "NSObject+SBJson.h"

@implementation MeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
    NSLog(@"load me view");
    [self LoadData];

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (void)LoadData
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"username"]!=nil)
    {
        APIHandler *api=[[APIHandler alloc]init];
        NSString *responseString=[api getMeInfo];
        [api release];
        NSDictionary *userdict = [responseString JSONValue];
        [responseString release];
        
        if([userdict objectForKey:@"name"]!=nil && [[userdict objectForKey:@"name"] length]>1)
            [labelusername setText:[userdict objectForKey:@"name"]];
        else
            [labelusername setText:[userdict objectForKey:@"email"]];
        if([userdict objectForKey:@"bio"]!=nil)
            [labelbio setText:[userdict objectForKey:@"bio"]];
    }   
}

- (IBAction) LogoutButtonPress:(id) sender
{
    [[NSUserDefaults standardUserDefaults] setObject:nil  forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] setObject:nil  forKey:@"api_key"];
    [[NSUserDefaults standardUserDefaults] setObject:nil  forKey:@"devicetokenreg"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];

    LoginViewController *loginview = [[LoginViewController alloc]
                                      initWithNibName:@"LoginViewController" bundle:nil];
    exfeAppDelegate* app=[[UIApplication sharedApplication] delegate];
    
    loginview.delegate=app;

    [app.tabBarController presentModalViewController:loginview animated:NO];

    
}
- (void)viewWillAppear:(BOOL)animated
{
    exfeAppDelegate* app=[[UIApplication sharedApplication] delegate];
    if(app.meViewReload==NO)
        NSLog(@"will appear");
    else if(app.meViewReload==YES)
    {
            [self LoadData];
        NSLog(@"will appear reload");
    }
}
- (IBAction) test:(id) sender
{
    NSLog(@"me view test");
}
- (void)viewDidUnload
{
    NSLog(@"unload");
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
