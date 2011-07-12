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
//#import "JSON/JSON.h"
#import "JSON/SBJson.h"
#import <EventKit/EventKit.h>
#import "ImgCache.h"

#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f
#define CELL_IMAGE_WIDTH 40.0f
#define CELL_IMAGE_HEIGHT 40.0f

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
    
    barButtonItem = [[UIBarButtonItem alloc]
     initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
                     //UIBarButtonSystemItemRefresh
     target:self
     action:@selector(toconversation)];
	self.navigationItem.rightBarButtonItem = barButtonItem;
    DBUtil *dbu=[DBUtil sharedManager];
    comments=[dbu getCommentWithEventid:self.eventid];
    
//    NSURL *baseURL = [NSURL fileURLWithPath:@""];
    NSString *html=[self GenerateHtmlWithEvent];

    //NSString *path = [[NSBundle mainBundle] bundlePath];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *documentsDirectory = [paths objectAtIndex:0]; 

    NSURL *baseURL = [NSURL fileURLWithPath:documentsDirectory];
    [webview loadHTMLString:html baseURL:baseURL];

    showeventinfo=YES;
    
    keyboardIsVisible = NO;
    
    
    
    conversionViewController=[[ConversionTableViewController alloc]initWithNibName:@"ConversionTableViewController" bundle:nil];
    CGRect crect=conversionViewController.view.frame;
    conversionViewController.view.frame=CGRectMake(crect.origin.x, crect.origin.y, crect.size.width, crect.size.height-kDefaultToolbarHeight);
    [conversionViewController.view setSeparatorColor:[UIColor clearColor]];
    conversionViewController.comments=comments;
    conversionViewController.eventid=eventid;
    [self.view addSubview:conversionViewController.view];
    [conversionViewController.view setHidden:YES];
    [conversationview setHidden:YES];

}

- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
	/* Listen for keyboard */
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
//    [UIView transitionFromView:conversionViewController.view toView:self.view duration:1 options:UIViewAnimationOptionTransitionFlipFromRight completion:nil];

}

- (void)viewWillDisappear:(BOOL)animated 
{
	[super viewWillDisappear:animated];
	/* No longer listen for keyboard */
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (NSString*)GenerateHtmlWithEvent
{
    DBUtil *dbu=[DBUtil sharedManager];
    NSArray *invitations=[dbu getInvitationWithEventid:self.eventid];

//    NSString *html=[NSString stringWithFormat:@"<h1>%@</h1>",eventobj.title];
//
//    html=[html stringByAppendingFormat:@"<p>时间：%@</p>",eventobj.begin_at];
//    html=[html stringByAppendingFormat:@"<p>地点：%@</p>",eventobj.place_line1];
//    html=[html stringByAppendingFormat:@"<p>地%@</p>",eventobj.place_line2];
//    html=[html stringByAppendingFormat:@"<p>%@</p>",eventobj.description];
////    NSArray* invitations=[aevent objectForKey:@"invitations"];
////    
//    if(invitations !=nil&&[invitations count]>0)
//    {
//        html=[html stringByAppendingString:@"<p>参加者:</p>"];
//        for (int i=0;i<[invitations count];i++)
//        {
//            Invitation *invitation=[invitations objectAtIndex:i];
//            html=[html stringByAppendingFormat:@"<p>%@ state:%@ via %@ </p>",invitation.username,invitation.state,invitation.provider];
//        }    
//    }
//    
//
//    html=[html stringByAppendingString:@"<p>您是否参加此活动？<a href='http://invitation/#yes'>是</a>,<a href='http://invitation/#no'>否</a>,<a href='http://invitation/#maybe'>也许</a></p>"];
//    NSString *identifier=[dbu getIdentifierWithid:self.eventid];
//    if(identifier!=nil)
//        html=[html stringByAppendingFormat:@"<p><a href='http://addical/#%i'>%@</a></p>",self.eventid,@"删除日历"];
//    else
//        html=[html stringByAppendingFormat:@"<p><a href='http://addical/#%i'>%@</a></p>",self.eventid,@"添加日历"];
//    
    

    
    
    NSDateFormatter *rfc3339TimestampFormatterWithTimeZone = [[NSDateFormatter alloc] init];
    [rfc3339TimestampFormatterWithTimeZone setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
    [rfc3339TimestampFormatterWithTimeZone setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    NSDate *theDate = nil;
    NSError *error = nil; 
    if (![rfc3339TimestampFormatterWithTimeZone getObjectValue:&theDate forString:eventobj.begin_at range:nil error:&error]) {
        NSLog(@"Date '%@' could not be parsed: %@", eventobj.begin_at, error);
    }
    
    [rfc3339TimestampFormatterWithTimeZone release];
    

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
//    -MM-dd HH:mm
//    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
//    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
//    NSLocale *Locale = [[NSLocale alloc] initWithLocaleIdentifier:[[NSLocale currentLocale] identifier]];
//    [dateFormatter setLocale:Locale];
//    
//    [dateFormatter setDoesRelativeDateFormatting:YES];
    
    
    NSString *dateString = [dateFormatter stringFromDate:theDate];
    [dateFormatter release];
    if(dateString==nil)
        dateString=@"Anytime";
    NSLog(@"dateString: %@", dateString);    
    
    NSString *xpath=[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"x.html"];
    NSString *html=[NSString stringWithContentsOfFile:xpath encoding:NSUTF8StringEncoding error:nil];
    html=[html stringByReplacingOccurrencesOfString:@"{#begin_at#}" withString:dateString];
    html=[html stringByReplacingOccurrencesOfString:@"{#place_line1#}" withString:eventobj.place_line1];
    html=[html stringByReplacingOccurrencesOfString:@"{#title#}" withString:eventobj.title];

    NSString *exfeelist=@"";
    //exfee avatar list
    html=[html stringByReplacingOccurrencesOfString:@"{#exfee_list#}" withString:exfeelist];

    NSString *description=[[eventobj.description stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"] stringByReplacingOccurrencesOfString:@"\r" withString:@"<br/>"];
    
    html=[html stringByReplacingOccurrencesOfString:@"{#description#}" withString:description];
    
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
            NSString *responseString=[api sentRSVPWith:self.eventid rsvp:(NSString*)rsvp];
            
            [api release];
            
            
            NSDictionary *eventdict = [responseString JSONValue];
            DBUtil *dbu=[DBUtil sharedManager];
            [dbu updateEventobjWithid:self.eventid event:eventdict];
            [dbu updateInvitationobjWithid:self.eventid event:(NSArray*)[eventdict objectForKey:@"invitations"]];
            
            
            NSString *html=[self GenerateHtmlWithEvent];
//            NSString *path = [[NSBundle mainBundle] bundlePath];
//            NSURL *baseURL = [NSURL fileURLWithPath:path];
            [webview loadHTMLString:html baseURL:[NSURL URLWithString:[[NSBundle mainBundle] bundlePath]]];
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
    [conversionViewController.view setHidden:NO];
//    [conversionViewController.view setHidden:YES];
    if(showeventinfo==YES)
    {
        [UIView transitionFromView:webview toView:conversionViewController.view duration:1 options:UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
    }   
    else
    {
        
        [UIView transitionFromView:conversionViewController.view toView:webview duration:1 options:UIViewAnimationOptionTransitionFlipFromRight completion:nil];
    }
////    
    if(showeventinfo==YES)
    {
        CGRect screenFrame = [self.view frame];
  
        CGRect crect=conversationview.frame;
        conversationview.frame=CGRectMake(crect.origin.x, crect.origin.y, crect.size.width, crect.size.height-kDefaultToolbarHeight);
        CGRect toolbarframe=CGRectMake(0, screenFrame.size.height-kDefaultToolbarHeight, screenFrame.size.width, kDefaultToolbarHeight);

        self.inputToolbar = [[UIInputToolbar alloc] initWithFrame:toolbarframe];
        inputToolbar.delegate = self;
        [self.view addSubview:self.inputToolbar];
//        [baseview addSubview:self.inputToolbar];


    }
    else
    {
        [self.inputToolbar removeFromSuperview];
    }
    showeventinfo=!showeventinfo;
 
}
- (void)refresh
{
    NSLog(@"refresh");
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

-(void)inputButtonPressed:(NSString *)inputText
{
    [conversionViewController performSelector:@selector(postComment:) withObject:inputText];
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)keyboardWillShow:(NSNotification *)notification 
{
    NSLog(@"show keyboard");
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
