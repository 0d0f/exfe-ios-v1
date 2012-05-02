//
//  OAuthLoginViewControllerViewController.m
//  EXFE
//
//  Created by ju huo on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OAuthLoginViewController.h"
#import "URLParser.h"

@interface OAuthLoginViewController ()

@end

@implementation OAuthLoginViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
	self.title = @"Sign In";
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Cancel"
                                     style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(cancel)];	
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
    NSString *callback=@"oauth://handleTwitterLogin";
    NSString *urlstr=[NSString stringWithFormat:@"http://local.exfe.com/oAuth/twitterRedirect?device=iOS&device_callback=%@",callback];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlstr]]];	

    
//	self.navigationController.delegate = self;    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)

  //  [self requestTokenWithCallbackUrl:oAuthCallbackUrl];
}

- (void)cancel {
    [self.delegate OAuthloginViewControllerDidCancel:self];
}

- (BOOL)webView:(UIWebView *)webview shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"webview should load request: %@", request);
    NSString *URLString = [[request URL] absoluteString];
    if ([URLString rangeOfString:@"token="].location != NSNotFound && [URLString rangeOfString:@"oauth://handleTwitterLogin"].location != NSNotFound) {
        URLParser *parser = [[URLParser alloc] initWithURLString:URLString];
        NSString *err = [parser valueForVariable:@"err"];
        if(!err)
        {
        NSString *userid = [parser valueForVariable:@"userid"];
        NSString *name = [parser valueForVariable:@"name"];
        NSString *token = [parser valueForVariable:@"token"];
        [self.delegate OAuthloginViewControllerDidSuccess:self userid:userid username:name token:token];
        [parser release];
        }
        return NO;
    }
    return YES;
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
