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
#import "CommentViewController.h"
#import <EventKit/EventKit.h>

@implementation EventViewController
@synthesize event;
@synthesize eventobj;
@synthesize eventid;
@synthesize interceptLinks;
@synthesize inputToolbar;

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
    conversationview.alpha= 0.0;
    barButtonItem = [[UIBarButtonItem alloc]
     initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
                     //UIBarButtonSystemItemRefresh
     target:self
     action:@selector(toconversation)];
	self.navigationItem.rightBarButtonItem = barButtonItem;
    
    DBUtil *dbu=[DBUtil sharedManager];
    
    NSString* eventjson=[dbu getEventWithid:self.eventid];
    if(eventjson==nil)
    {
        APIHandler *api=[[APIHandler alloc]init];
        eventjson=[api getEventById:self.eventid];
        [api release];
    }
    
    self.event=[eventjson JSONValue];
    
    NSString *html=[self GenerateHtmlWithEvent];
    NSURL *baseURL = [NSURL fileURLWithPath:@""];
    [webview loadHTMLString:html baseURL:baseURL];

    NSString *htmlcomment=[self GenerateHtmlWithComment];
    NSURL *baseURLcomment = [NSURL fileURLWithPath:@""];
    [conversationview loadHTMLString:htmlcomment baseURL:baseURLcomment];
    showeventinfo=YES;
    
    keyboardIsVisible = NO;
    
}

- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
	/* Listen for keyboard */
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated 
{
	[super viewWillDisappear:animated];
	/* No longer listen for keyboard */
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (NSString*)GenerateHtmlWithComment
{
    DBUtil *dbu=[DBUtil sharedManager];
    NSArray *comments=[dbu getCommentWithEventid:self.eventid];
    NSString *html=@"";
//    id comments=[aevent objectForKey:@"comments"];
    if(comments!=nil && [comments count]>0)
    {
        for (int i=0;i<[comments count];i++)
        {
            Comment *comment=[comments objectAtIndex:i];
            NSDictionary *user=[comment.userjson JSONValue];
            NSString *username=@"";
            if([user objectForKey:@"username"]!=[NSNull null])
                username=[user objectForKey:@"name"];
            html=[html stringByAppendingFormat:@"<p>%@ </p>",comment.comment];
            html=[html stringByAppendingFormat:@"<p>-- by %@ </p>",username];
        }
    }
    html=[html stringByAppendingFormat:@"<p><a href='http://comment/#%i'>%@</a></p>",self.eventid,@"回复"];
    
    return html;
}
- (NSString*)GenerateHtmlWithEvent
{
    DBUtil *dbu=[DBUtil sharedManager];
    NSArray *invitations=[dbu getInvitationWithEventid:self.eventid];

    NSString *html=[NSString stringWithFormat:@"<h1>%@</h1>",eventobj.title];

    html=[html stringByAppendingFormat:@"<p>时间：%@</p>",eventobj.begin_at];
    html=[html stringByAppendingFormat:@"<p>地点：%@</p>",eventobj.venue];
    html=[html stringByAppendingFormat:@"<p>%@</p>",eventobj.description];
//    NSArray* invitations=[aevent objectForKey:@"invitations"];
//    
    if(invitations !=nil&&[invitations count]>0)
    {
        html=[html stringByAppendingString:@"<p>参加者:</p>"];
        for (int i=0;i<[invitations count];i++)
        {
            Invitation *invitation=[invitations objectAtIndex:i];
            html=[html stringByAppendingFormat:@"<p>%@ state:%@ via %@ </p>",invitation.username,invitation.state,invitation.provider];
        }    
    }
    
//    for(int i=0;i<[invitations count];i++)
//    {
//        NSDictionary *invation=[invitations objectAtIndex:i];
//        NSDictionary *invation_user=[invation objectForKey:@"invited_identity_list"];
//        if([invation_user objectForKey:@"name"]!=nil)
//        {
//            html=[html stringByAppendingFormat:@"<p>%@ : %@</p>",[invation_user objectForKey:@"name"] ,[invation objectForKey:@"state"]];
//        }
//        
//    }
    html=[html stringByAppendingString:@"<p>您是否参加此活动？<a href='http://invitation/#yes'>是</a>,<a href='http://invitation/#no'>否</a>,<a href='http://invitation/#maybe'>也许</a></p>"];
    NSString *identifier=[dbu getIdentifierWithid:self.eventid];
    if(identifier!=nil)
        html=[html stringByAppendingFormat:@"<p><a href='http://addical/#%i'>%@</a></p>",self.eventid,@"删除日历"];
    else
        html=[html stringByAppendingFormat:@"<p><a href='http://addical/#%i'>%@</a></p>",self.eventid,@"添加日历"];
    
//    id comments=[aevent objectForKey:@"comments"];
//    if(comments!=nil && [comments count]>0)
//    {
//        for (int i=0;i<[comments count];i++)
//        {
//            id comment=[comments objectAtIndex:i];
//            NSLog(@"comment:%@",comment);
//            html=[html stringByAppendingFormat:@"<p>%@ </p>",[comment objectForKey:@"comment"]];
//            html=[html stringByAppendingFormat:@"<p>-- by %@ </p>",[comment objectForKey:@"user_id"]];
//        }
//    }
//    html=[html stringByAppendingFormat:@"<p><a href='http://comment/#%i'>%@</a></p>",self.eventid,@"回复"];
    
    return html;
}
-(bool) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (self.interceptLinks && navigationType==UIWebViewNavigationTypeLinkClicked) {
        NSURL *url = request.URL;
        NSLog(@"url click %@",[url absoluteString]);
        NSArray *chunk=[[url absoluteString] componentsSeparatedByString:@"#"];
        if([chunk count]==2)
        {
            if( [[chunk objectAtIndex:0] isEqualToString:@"http://invitation/"])
            {
            NSString *rsvp=[chunk objectAtIndex:1];
            APIHandler *api=[[APIHandler alloc]init];
            NSString *responseString=[api sentRSVPWith:[[self.event objectForKey:@"id"] intValue] rsvp:(NSString*)rsvp];
            
            [api release];
            
            
            NSDictionary *eventdict = [responseString JSONValue];
            DBUtil *dbu=[DBUtil sharedManager];
            [dbu updateEventobjWithid:self.eventid event:eventdict];
            [dbu updateInvitationobjWithid:self.eventid event:(NSArray*)[eventdict objectForKey:@"invitations"]];
            //[dbu updateEventWithid:self.eventid event:responseString];
            
            
            NSString *html=[self GenerateHtmlWithEvent];
            NSURL *baseURL = [NSURL fileURLWithPath:@""];
            [webview loadHTMLString:html baseURL:baseURL];
            }
            else if( [[chunk objectAtIndex:0] isEqualToString:@"http://addical/"])
            {
                NSLog(@"addical");
                NSString *datestr=[self.event objectForKey:@"begin_at"];
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                
                if (datestr.length > 20) {
                    datestr = [datestr stringByReplacingOccurrencesOfString:@":" withString:@"" options:0 range:NSMakeRange(20, datestr.length-20)];                                    
                }                 
                [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
                NSDate *sdate=[dateFormat dateFromString:datestr];
//                NSString *dateString = [dateFormat stringFromDate:date];  
                [dateFormat release];                
                
                DBUtil *dbu=[DBUtil sharedManager];
                
                EKEventStore *eventStore = [[EKEventStore alloc] init];
                EKEvent *sevent  = [EKEvent eventWithEventStore:eventStore];
                sevent.title     = [self.event objectForKey:@"title"];
                sevent.startDate =  sdate;//[[NSDate alloc] init];
                sevent.endDate   = [[NSDate alloc] initWithTimeInterval:600 sinceDate:sevent.startDate];
                sevent.location =[self.event objectForKey:@"venue"];


                [sevent setCalendar:[eventStore defaultCalendarForNewEvents]];
                NSError *err;
                [eventStore saveEvent:sevent span:EKSpanThisEvent error:&err]; 
                [dbu updateEventicalWithid:self.eventid identifier:sevent.eventIdentifier];
                NSLog(@"identifier:%@",sevent.eventIdentifier);
                
            }
            else if( [[chunk objectAtIndex:0] isEqualToString:@"http://comment/"])
            {

                [CommentViewController present:self event:self.eventid delegate:self];
                
//                DBUtil *dbu=[DBUtil sharedManager];
//                NSString *responseString=[dbu getEventWithid:self.eventid];
//                NSDictionary *eventdict = [responseString JSONValue];
//                
//                
//                NSString *html=[self GenerateHtmlWithEvent:eventdict];
//                NSURL *baseURL = [NSURL fileURLWithPath:@""];
//                [webview loadHTMLString:html baseURL:baseURL];
//                [responseString release];

            }
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
    [barButtonItem release];
}
- (void)toconversation
{
    [UIView beginAnimations:@"ToggleViews" context:nil];
    [UIView setAnimationDuration:1.0];
    if(showeventinfo==YES)
    {
        webview.alpha = 0.0;
        conversationview.alpha= 1.0;
        //    self.view = [[UIView alloc] initWithFrame:screenFrame];
        //    self.view.backgroundColor = [UIColor whiteColor];
        /* Create toolbar */

    }   
    else
    {
        webview.alpha = 1.0;
        conversationview.alpha= 0.0;
    }
    [UIView commitAnimations];  
    
    if(showeventinfo==YES)
    {
//        CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
        CGRect screenFrame = [self.view frame];
        
        CGRect toolbarframe=CGRectMake(0, screenFrame.size.height-kDefaultToolbarHeight, screenFrame.size.width, kDefaultToolbarHeight);
        self.inputToolbar = [[UIInputToolbar alloc] initWithFrame:toolbarframe];
    
    [self.view addSubview:self.inputToolbar];

    }
    else
    {
        [self.inputToolbar removeFromSuperview];
    }
    showeventinfo=!showeventinfo;

//    inputToolbar.delegate = self;
    
}
- (void)refresh
{
    CGRect frame = CGRectMake(0.0, 0.0, 25.0, 25.0);  
    UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] initWithFrame:frame];  
    [loading sizeToFit];  
    loading.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);  
    [loading startAnimating];  
    UIBarButtonItem *statusInd = [[UIBarButtonItem alloc] initWithCustomView:loading];  
    
    statusInd.style = UIBarButtonItemStylePlain;  
    self.navigationItem.rightBarButtonItem =statusInd;
    [loading release];
    [statusInd release];
    
    [NSThread detachNewThreadSelector:@selector(LoadEvent) toTarget:self withObject:nil];
}
- (void)LoadEvent
{
    APIHandler *api=[[APIHandler alloc]init];
    NSString* eventjson=[api getEventById:self.eventid];
    [api release];
    if( [eventjson JSONValue]!=nil)
    {
        DBUtil *dbu=[DBUtil sharedManager];
        [dbu updateEventobjWithid:self.eventid event:self.event];
        [self updateEventView];  
    }
    self.navigationItem.rightBarButtonItem = barButtonItem;

    
}

- (void)updateEventView
{
    NSString *html=[self GenerateHtmlWithComment];
    NSURL *baseURL = [NSURL fileURLWithPath:@""];
    [conversationview loadHTMLString:html baseURL:baseURL];

    NSLog(@"event update");
}
- (void)updateConversationView
{
    NSString *htmlcomment=[self GenerateHtmlWithComment];
    NSURL *baseURLcomment = [NSURL fileURLWithPath:@""];
    [conversationview loadHTMLString:htmlcomment baseURL:baseURLcomment];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)keyboardWillShow:(NSNotification *)notification 
{
    /* Move the toolbar to above the keyboard */
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	CGRect frame = self.inputToolbar.frame;
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        frame.origin.y = self.view.frame.size.height - frame.size.height - kKeyboardHeightPortrait;
    }
    else {
        frame.origin.y = self.view.frame.size.width - frame.size.height - kKeyboardHeightLandscape - kStatusBarHeight;
    }
	self.inputToolbar.frame = frame;
	[UIView commitAnimations];
    keyboardIsVisible = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification 
{
    /* Move the toolbar back to bottom of the screen */
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	CGRect frame = self.inputToolbar.frame;
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        frame.origin.y = self.view.frame.size.height - frame.size.height;
    }
    else {
        frame.origin.y = self.view.frame.size.width - frame.size.height;
    }
	self.inputToolbar.frame = frame;
	[UIView commitAnimations];
    keyboardIsVisible = NO;
}

@end
