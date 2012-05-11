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
@synthesize webView;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if(firstLoading==YES)
    {
//        NSLog(@"web start load");
        MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.webView animated:YES];
        
//        MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.labelText = @"Loading";
        
    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if(firstLoading==YES)
    {
        firstLoading=NO;
        [MBProgressHUD hideHUDForView:self.webView animated:YES];
//        NSLog(@"web stop load");    
    }
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if(firstLoading==YES)
    {
        firstLoading=NO;
        [MBProgressHUD hideHUDForView:self.webView animated:YES];
//        NSLog(@"web stop load");    
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
	self.title = @"Sign In";

//	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
//                                     initWithTitle:@"Cancel"
//                                     style:UIBarButtonItemStylePlain
//                                     target:self
//                                     action:@selector(cancel)];	
//	self.navigationItem.leftBarButtonItem = cancelButton;
//	[cancelButton release];

    UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    UIImage *closesettingbtnimg = [UIImage imageNamed:@"close_settingbtn.png"];
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setTitle:@"Close" forState:UIControlStateNormal];
    doneButton.titleLabel.font         = [UIFont boldSystemFontOfSize:12.0f];
    [doneButton setTitleColor:[UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1] forState:UIControlStateNormal];
    
    doneButton.titleEdgeInsets         = UIEdgeInsetsMake(0, 2, 0, 2);
    doneButton.contentStretch          = CGRectMake(0.5, 0.5, 0, 0);
    doneButton.contentMode             = UIViewContentModeScaleToFill;
    
    [doneButton setBackgroundImage:closesettingbtnimg forState:UIControlStateNormal];
    doneButton.frame = CGRectMake(0, 0, closesettingbtnimg.size.width, closesettingbtnimg.size.height);
    [doneButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    
    [toolbar setItems:[NSArray arrayWithObjects:flexibleSpaceLeft, [[[UIBarButtonItem alloc] initWithCustomView:doneButton] autorelease], nil]];
    
    [flexibleSpaceLeft release];
    
    
    
    NSString *callback=@"oauth://handleTwitterLogin";
    NSString *urlstr=[NSString stringWithFormat:@"https://exfe.com/oAuth/twitterRedirect?device=iOS&device_callback=%@",callback];
//    NSString *urlstr=[NSString stringWithFormat:@"https://exfe.com/oAuth/twitterRedirect?device=iOS&device_callback=%@",callback];
    firstLoading=YES;
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
//    NSLog(@"webview should load request: %@", request);
    NSString *URLString = [[request URL] absoluteString];
    if ([URLString rangeOfString:@"token="].location != NSNotFound && [URLString rangeOfString:@"oauth://handleTwitterLogin"].location != NSNotFound) {
        URLParser *parser = [[URLParser alloc] initWithURLString:URLString];
        NSString *err = [parser valueForVariable:@"err"];
        if(!err)
        {
        NSString *userid = [parser valueForVariable:@"userid"];
        NSString *name = [parser valueForVariable:@"name"];
        name=[Util decodeFromPercentEscapeString:name];
//        CFStringTransform((CFMutableStringRef)name, NULL, kCFStringTransformToXMLHex, false);            
            
        NSString *token = [parser valueForVariable:@"token"];
        NSString *external_id = [parser valueForVariable:@"external_id"];
            [self.delegate OAuthloginViewControllerDidSuccess:self userid:userid username:name external_id:external_id token:token];
        [parser release];
        }
        return NO;
    }
    return YES;
}
- (void)viewDidUnload
{
    [webView stopLoading];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
