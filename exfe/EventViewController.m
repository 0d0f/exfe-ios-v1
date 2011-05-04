//
//  EventViewController.m
//  exfe
//
//  Created by huoju on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventViewController.h"
#import "APIHandler.h"
#import "DBUtil.h"
#import "JSON/JSON.h"

@implementation EventViewController
@synthesize event;
@synthesize eventid;
@synthesize interceptLinks;

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
    [super viewDidLoad];
    interceptLinks=NO;

    DBUtil *dbu=[DBUtil alloc];
    NSString* eventjson=[dbu getEventWithid:self.eventid];
    [dbu release];
    self.event=[eventjson JSONValue];
    
    NSString *html=[self GenerateHtmlWithEvent:self.event];
    NSURL *baseURL = [NSURL fileURLWithPath:@""];
    [webview loadHTMLString:html baseURL:baseURL];
}

- (NSString*)GenerateHtmlWithEvent:(NSDictionary*)aevent
{
    NSString *html=[NSString stringWithFormat:@"<h1>%@</h1>",[aevent objectForKey:@"title"]];
    html=[html stringByAppendingFormat:@"<p>时间：%@</p>",[aevent objectForKey:@"begin_at"]];
    html=[html stringByAppendingFormat:@"<p>地点：%@</p>",[aevent objectForKey:@"venue"]];
    html=[html stringByAppendingFormat:@"<p>%@</p>",[aevent objectForKey:@"description"]];
    NSArray* invitations=[aevent objectForKey:@"invitations"];
    
    html=[html stringByAppendingString:@"<p>参加者:</p>"];
    
    for(int i=0;i<[invitations count];i++)
    {
        NSDictionary *invation=[invitations objectAtIndex:i];
        NSDictionary *invation_user=[invation objectForKey:@"invited_user"];
        if([invation_user objectForKey:@"name"]!=nil)
        {
            html=[html stringByAppendingFormat:@"<p>%@ : %@</p>",[invation_user objectForKey:@"name"] ,[invation objectForKey:@"state"]];
        }
        
    }
    html=[html stringByAppendingString:@"<p>您是否参加此活动？<a href='http://invitation#yes'>是</a>,<a href='http://invitation#no'>否</a>,<a href='http://invitation#maybe'>也许</a></p>"];
    return html;
}
-(bool) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (self.interceptLinks && navigationType==UIWebViewNavigationTypeLinkClicked) {
        NSURL *url = request.URL;
        NSArray *chunk=[[url absoluteString] componentsSeparatedByString:@"#"];
        NSString *rsvp=@"";
        if([chunk count]==2)
        {
            rsvp=[chunk objectAtIndex:1];
            APIHandler *api=[[APIHandler alloc]init];
            NSString *responseString=[api sentRSVPWith:[[self.event objectForKey:@"id"] intValue] rsvp:(NSString*)rsvp];
            
            [api release];
            
            
            NSDictionary *eventdict = [responseString JSONValue];
            DBUtil *dbu=[DBUtil alloc];
            
            [dbu updateEventWithid:self.eventid event:responseString];
            [dbu release];

            
            NSString *html=[self GenerateHtmlWithEvent:eventdict];
            NSURL *baseURL = [NSURL fileURLWithPath:@""];
            [webview loadHTMLString:html baseURL:baseURL];

            [responseString release];
        }
            
        
        return NO;
    }
    //No need to intercept the initial request to fill the WebView
    else {
        NSLog(@"interceptLinks");
        self.interceptLinks = YES;
        return YES;
    }
    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
