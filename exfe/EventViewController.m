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
#import "JSON/SBJson.h"
#import <EventKit/EventKit.h>
#import "UIButton+StyledButton.h"
#import "ImgCache.h"
#import "ConversationCellView.h"
#import "exfeAppDelegate.h"

const int INVITATION_YES=1;
const int INVITATION_NO=2;
const int INVITATION_MAYBE=3;

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
    [placeholder release];
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
    if ([[webview subviews] count] > 0) {
        // hide the shadows
        for (UIView* shadowView in [[[webview subviews] objectAtIndex:0] subviews]) {
            [shadowView setHidden:YES];
        }
        // show the content
        [[[[[webview subviews] objectAtIndex:0] subviews] lastObject] setHidden:NO];
    }
    webview.backgroundColor = [UIColor whiteColor];
    
    NSString *backbtnimgpath = [[NSBundle mainBundle] pathForResource:@"backbtn" ofType:@"png"];
    UIImage *backbtnimg = [UIImage imageWithContentsOfFile:backbtnimgpath];
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setBackgroundImage:backbtnimg forState:UIControlStateNormal];
    [button setTitle:@" Back" forState:UIControlStateNormal];

    button.titleLabel.font  = [UIFont boldSystemFontOfSize:12.0f];
    [button setTitleColor:[UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1] forState:UIControlStateNormal];

    button.frame = CGRectMake(0, 0, backbtnimg.size.width, backbtnimg.size.height);
    
	[button addTarget:self action:@selector(pushback) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
	self.navigationItem.leftBarButtonItem = customBarItem;
    [customBarItem release];
    
    NSString *chatimgpath = [[NSBundle mainBundle] pathForResource:@"chat" ofType:@"png"];
    UIImage *chatimg = [UIImage imageWithContentsOfFile:chatimgpath];
    UIButton *chatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [chatButton setTitle:@"Chat" forState:UIControlStateNormal];
    [chatButton setImage:chatimg forState:UIControlStateNormal];
    chatButton.frame = CGRectMake(0, 0, chatimg.size.width, chatimg.size.height);
    [chatButton addTarget:self action:@selector(toconversation) forControlEvents:UIControlEventTouchUpInside];

    barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:chatButton];
    
	self.navigationItem.rightBarButtonItem = barButtonItem;
    [barButtonItem release];
    
    CGRect frame = CGRectMake(0, 0,400 , 44);
    UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1];
    label.text = eventobj.title;
    self.navigationItem.titleView=label;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *documentsDirectory = [paths objectAtIndex:0]; 
    
    NSURL *baseURL = [NSURL fileURLWithPath:documentsDirectory];
    showeventinfo=YES;
    keyboardIsVisible = NO;
    placeholder=[[UITextField alloc]init];
    [self.view addSubview:placeholder];
    [placeholder release];

    dispatch_queue_t loaddata= dispatch_queue_create("loaddata", NULL);
    dispatch_async(loaddata, ^{
        NSString *html=[self GenerateHtmlWithEvent];
        [eventobj release];
        dispatch_async(dispatch_get_main_queue(), ^{
            [webview loadHTMLString:html baseURL:baseURL];
            conversionViewController=[[ConversionTableViewController alloc]initWithNibName:@"ConversionTableViewController" bundle:nil];

            conversionViewController.placeholder=placeholder;

            CGRect crect=conversionViewController.view.frame;
            conversionViewController.view.frame=CGRectMake(crect.origin.x, crect.origin.y, crect.size.width, crect.size.height-kDefaultToolbarHeight);
            DBUtil *dbu=[DBUtil sharedManager];
            conversionViewController.comments=[dbu getCommentWithEventid:self.eventid];
            conversionViewController.eventid=eventid;
            [self.view addSubview:conversionViewController.view];
            [conversionViewController.view setHidden:YES];
            [conversationview setHidden:YES];
        });
    });
    dispatch_release(loaddata);
}
- (void)loadConversationData
{
            conversionViewController=[[ConversionTableViewController alloc]initWithNibName:@"ConversionTableViewController" bundle:nil];
            conversionViewController.placeholder=placeholder;
    
            CGRect crect=conversionViewController.view.frame;
            conversionViewController.view.frame=CGRectMake(crect.origin.x, crect.origin.y, crect.size.width, crect.size.height-kDefaultToolbarHeight);
            DBUtil *dbu=[DBUtil sharedManager];
            NSArray* _comments=[dbu getCommentWithEventid:self.eventid];
            comments=[NSMutableArray arrayWithArray: _comments];
            conversionViewController.comments=comments;
            conversionViewController.eventid=eventid;
            [self.view addSubview:conversionViewController.view];
            [conversionViewController.view setHidden:YES];
            [conversationview setHidden:YES];
    [self toconversation];
}
- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
#ifdef __IPHONE_5_0
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
#endif    
    
}

- (void)viewWillDisappear:(BOOL)animated 
{
	[super viewWillDisappear:animated];
	/* No longer listen for keyboard */
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

#ifdef __IPHONE_5_0
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {

	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    }
#endif
}

- (NSString*)GenerateHtmlWithEvent
{
    exfeAppDelegate *app=(exfeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    DBUtil *dbu=[DBUtil sharedManager];
   
    NSDate *theDate = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    theDate = [dateFormatter dateFromString:eventobj.begin_at];  

    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateString = [dateFormatter stringFromDate:theDate];
    [dateFormatter release];
    
    
    NSDateFormatter *dateFormatter_human = [[NSDateFormatter alloc] init];
    [dateFormatter_human setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter_human setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter_human setLocale:[NSLocale currentLocale]];
    
    [dateFormatter_human setDoesRelativeDateFormatting:YES];
    
    NSString *dateString_human = [dateFormatter_human stringFromDate:theDate];
    [dateFormatter_human release];
    
    if(dateString==nil)
    {
        dateString_human=@"Anytime";
        dateString=@"";
    }
    
    NSString *xpath=[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"x.html"];
    NSString *html=[NSString stringWithContentsOfFile:xpath encoding:NSUTF8StringEncoding error:nil];
    html=[html stringByReplacingOccurrencesOfString:@"{#begin_at_human#}" withString:[Util formattedDateRelativeToNow:eventobj.begin_at withTimeType:eventobj.time_type]];
    
    html=[html stringByReplacingOccurrencesOfString:@"{#begin_at#}" withString:[Util getNormalLocalTimeStrWithTimetype:eventobj.time_type time:eventobj.begin_at]];
    
    
    if([eventobj.place_line1 isEqualToString:@""])
    {
        html=[html stringByReplacingOccurrencesOfString:@"{#place_line1#}" withString:@"Any Place"];
        html=[html stringByReplacingOccurrencesOfString:@"{#place_line2#}" withString:@""];
        html=[html stringByReplacingOccurrencesOfString:@"{#map_display}" withString:@"none"];
    }
    else
    {
        html=[html stringByReplacingOccurrencesOfString:@"{#place_line1#}" withString:eventobj.place_line1];
        html=[html stringByReplacingOccurrencesOfString:@"{#map_display}" withString:@"inline"];

        NSString *place_line2=[eventobj.place_line2 stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
        html=[html stringByReplacingOccurrencesOfString:@"{#place_line2#}" withString:place_line2];
    }
    html=[html stringByReplacingOccurrencesOfString:@"{#title#}" withString:eventobj.title];

    NSString *rsvpstatus=@"<a id='x_rsvp_yes' href='http://invitation/#yes' class='x_rsvp_button'>Accept</a><a id='x_rsvp_no' href='http://invitation/#no' class='x_rsvp_button'>Decline</a><a id='x_rsvp_maybe' href='http://invitation/#maybe' class='x_rsvp_button'>interested</a>";
    
    NSString *exfeelist=@"";
    NSArray *invitations=[dbu getInvitationWithEventid:self.eventid];

    if(invitations !=nil&&[invitations count]>0)
    {
        for (int i=0;i<[invitations count];i++)
        {
            Invitation *invitation=[invitations objectAtIndex:i];
            if(![invitation.avatar isEqualToString:@""])
            {
                if(![invitation.avatar isEqualToString:@""])
                {
                    NSString* imgName = invitation.avatar;
                    
                    NSString *imgurl = [ImgCache getImgUrl:imgName];
                    NSString *imgcachename=[ImgCache getImgName:imgurl];
                    
                    if(invitation.state ==INVITATION_YES)
                    {
                        exfeelist=[exfeelist stringByAppendingFormat:@"<li id='avatar_%d'><img alt='' width='40px' height='40px' src='images/%@' /></li>",invitation.identity_id,imgcachename];
                    }
                    else
                        exfeelist=[exfeelist stringByAppendingFormat:@"<li id='avatar_%d' class='opacity'><img alt='' width='40px' height='40px' src='images/%@' />",invitation.identity_id,imgcachename];
                    
                }
            }
            if(invitation.user_id==app.userid)
            {
                if(invitation.state!=0)
                    rsvpstatus=@"<ol class='clearfix'><li class='ui-btn accept-btn' data-rsvp='1'>Accept</li><li class='ui-btn declined-btn' data-rsvp='2'>Declined</li><li class='interested-btn' data-rsvp='3'>Interested</li></ol>";
                    //@"<a id='x_rsvp_yes' href='http://invitation/#yes' style='display: none;' class='x_rsvp_button'>Accept</a><a id='x_rsvp_no' href='http://invitation/#no' style='display: none;' class='x_rsvp_button'>Decline</a><a id='x_rsvp_maybe' href='http://invitation/#maybe' style='display: none;' class='x_rsvp_button'>interested</a>";

//                if(invitation.state ==INVITATION_YES)
//                    rsvpstatus=[rsvpstatus stringByAppendingString:@"<span id='x_rsvp_msg'>Your RSVP is \"<span id='x_rsvp_status'>Accepted</span>\".</span>                <a id='x_rsvp_change' href='http://changersvp/#1' style='display: inline;'>Change?</a>"];
//                else if(invitation.state ==INVITATION_NO)
//                    rsvpstatus=[rsvpstatus stringByAppendingString:@"<span id='x_rsvp_msg'>Your RSVP is \"<span id='x_rsvp_status'>Declined</span>\".</span>                <a id='x_rsvp_change' href='http://changersvp/#1' style='display: inline;'>Change?</a>"];
//                else if(invitation.state ==INVITATION_MAYBE)
//                    rsvpstatus=[rsvpstatus stringByAppendingString:@"<span id='x_rsvp_msg'>Your RSVP is \"<span id='x_rsvp_status'>Interested</span>\".</span> <a id='x_rsvp_change' href='http://changersvp/#1' style='display: inline;'>Change?</a>"];

            }
        }
    }    
    [invitations release];
    html=[html stringByReplacingOccurrencesOfString:@"{#exfee_list#}" withString:exfeelist];
    NSLog(@"exfeelist:%@",exfeelist);
    html=[html stringByReplacingOccurrencesOfString:@"{#rsvp_status#}" withString:rsvpstatus];

    NSString *description=[eventobj.description stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
    html=[html stringByReplacingOccurrencesOfString:@"{#description#}" withString:description];
    
    return html;
}
-(bool) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestString = [[request URL] absoluteString];
    NSLog(@"%@",requestString);
    if ([requestString hasPrefix:@"js-frame:"]) {
        NSArray *components = [requestString componentsSeparatedByString:@":"];
        
        NSString *function = (NSString*)[components objectAtIndex:1];
		int callbackId = [((NSString*)[components objectAtIndex:2]) intValue];
        NSString *argsAsString = [(NSString*)[components objectAtIndex:3] 
                                  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [self handleCall:function callbackId:callbackId args:[argsAsString JSONValue]];
    }
    
    if (self.interceptLinks && navigationType==UIWebViewNavigationTypeLinkClicked) {
        NSURL *url = request.URL;
        NSArray *chunk=[[url absoluteString] componentsSeparatedByString:@"#"];
        if([chunk count]==2)
        {
            if( [[chunk objectAtIndex:0] isEqualToString:@"http://invitation/"])
            {
                NSString *rsvp=[chunk objectAtIndex:1];
                APIHandler *api=[[APIHandler alloc]init];
                NSString *responseString=[api sentRSVPWith:self.eventid rsvp:(NSString*)rsvp];
                
                [api release];
                
                NSDictionary *rsvpDict = [responseString JSONValue];
                id code=[[rsvpDict objectForKey:@"meta"] objectForKey:@"code"];
                if([code isKindOfClass:[NSNumber class]] && [code intValue]==200)
                {
                DBUtil *dbu=[DBUtil sharedManager];
                    
                [dbu updateInvitationobjWithid:self.eventid event:(NSArray*)[[rsvpDict objectForKey:@"response"] objectForKey:@"invitations"]];
                
                NSString *html=[self GenerateHtmlWithEvent];
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
                NSString *documentsDirectory = [paths objectAtIndex:0]; 
                
                NSURL *baseURL = [NSURL fileURLWithPath:documentsDirectory];
                [webview loadHTMLString:html baseURL:baseURL];
                }
                
            }
            else if( [[chunk objectAtIndex:0] isEqualToString:@"http://addical/"])
            {
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
                NSLog(@"%@",sevent.eventIdentifier);
                [sevent setCalendar:[eventStore defaultCalendarForNewEvents]];
                NSError *err;
                [eventStore saveEvent:sevent span:EKSpanThisEvent error:&err]; 
                [dbu updateEventicalWithid:self.eventid identifier:sevent.eventIdentifier];
            }
            else if( [[chunk objectAtIndex:0] isEqualToString:@"http://changersvp/"])
            {
                NSString* scriptstr=@"document.getElementById('x_rsvp_msg').style.display='none';document.getElementById('x_rsvp_change').style.display='none';document.getElementById('x_rsvp_yes').style.display='block';document.getElementById('x_rsvp_no').style.display='block';document.getElementById('x_rsvp_maybe').style.display='block';";
                NSString *rsvp =[webview stringByEvaluatingJavaScriptFromString:scriptstr];  
            }
        }
        else if( [[chunk objectAtIndex:0] isEqualToString:@"http://showmap/"])
        {
            NSString *q =@"";
            if(![eventobj.place_line2 isEqualToString:@""])
                q =[NSString stringWithFormat:@"%@",eventobj.place_line2];
            else
                q =[NSString stringWithFormat:@"%@",eventobj.place_line1];
            int zoom = 13;
            NSString *stringURL = [[NSString stringWithFormat:@"http://maps.google.com/maps?q=%@&z=%d", q,zoom] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *url = [NSURL URLWithString:stringURL];
            [[UIApplication sharedApplication] openURL:url];
            
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
- (void)returnResult:(int)callbackId args:(id)arg;
{
//    NSString *resultArrayString = [arg JSONRepresentation];    
//    {"invitations":[{"identity_id":"11","invitation_id":"268","user_id":42,"avatar_file_name":"http://www.gravatar.com/avatar/e461fe2d48746288ffef676def2f6e82?d=http%3A%2F%2Fimg.exfe.com%2F9%2Faa%2F80_80_9aa40bcf6b39a65d55e028e0e4896829.png","name":"huo ju ","bio":"","updated_at":"2012-02-27 09:46:22","state":2,"external_username":"hj@exfe.com","provider":"email","external_identity":"hj@exfe.com"}]}
    NSMutableDictionary* invitation=[[arg objectForKey:@"invitations"] objectAtIndex:0];
    if([[invitation objectForKey:@"state"] intValue]==1)
        [invitation setObject:@"Accepted" forKey:@"state_str"];
    else if([[invitation objectForKey:@"state"] intValue]==2)
        [invitation setObject:@"Declined" forKey:@"state_str"];
    else if([[invitation objectForKey:@"state"] intValue]==3)
        [invitation setObject:@"Interested" forKey:@"state_str"];
        
    NSString *result=[[[arg objectForKey:@"invitations"] objectAtIndex:0] JSONRepresentation] ;
    [webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"NativeBridge.resultForCallback(%d,%@);",callbackId,result]];
}

- (void)handleCall:(NSString*)functionName callbackId:(int)callbackId args:(NSArray*)args
{
    if ([functionName isEqualToString:@"rsvp"]) {
        int rsvp_int=[[args objectAtIndex:0] intValue];
        NSString* rsvp=@"";
        if(rsvp_int==1)
            rsvp=@"yes";
        else if(rsvp_int==2)
            rsvp=@"no";
        else if(rsvp_int==3)
            rsvp=@"maybe";
        
        APIHandler *api=[[APIHandler alloc]init];
        NSString *responseString=[api sentRSVPWith:self.eventid rsvp:(NSString*)rsvp];
        
        [api release];
        
        NSDictionary *rsvpDict = [responseString JSONValue];
        id code=[[rsvpDict objectForKey:@"meta"] objectForKey:@"code"];
        if([code isKindOfClass:[NSNumber class]] && [code intValue]==200)
        {
            DBUtil *dbu=[DBUtil sharedManager];
            
            [dbu updateInvitationobjWithid:self.eventid event:(NSArray*)[[rsvpDict objectForKey:@"response"] objectForKey:@"invitations"]];
        }

        [self returnResult:callbackId args:[rsvpDict objectForKey:@"response"] ];
        
    } else if ([functionName isEqualToString:@"prompt"]) {
        
        if ([args count]!=1) {
            NSLog(@"prompt wait exactly one argument!");
            return;
        }
        
        NSString *message = (NSString*)[args objectAtIndex:0];
        
//        alertCallbackId = callbackId;
        UIAlertView *alert=[[[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil] autorelease];
        [alert show];
        
    } else {
        NSLog(@"Unimplemented method '%@'",functionName);
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
        conversionViewController.inputToolbar=inputToolbar;
    }
    else
    {
        [self.inputToolbar removeFromSuperview];
    }
    showeventinfo=!showeventinfo;
    
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
        [dbu updateEventobjWithid:self.eventid event:self.event isnew:NO];
    }
//    self.navigationItem.rightBarButtonItem = barButtonItem;
}

-(void)inputButtonPressed:(NSString *)inputText
{
    [placeholder becomeFirstResponder];
    [inputToolbar setInputEnabled:NO];

    dispatch_queue_t commentQueue = dispatch_queue_create("comment thread", NULL);
    dispatch_async(commentQueue, ^{
        BOOL result=[conversionViewController postComment:inputText];

        dispatch_async(dispatch_get_main_queue(), ^{
            if(result==true)
            {
                [conversionViewController refreshAndHideKeyboard];
                //[conversionViewController refreshAndHideKeyboard:inputToolbar placeholder:placeholder];
            }
            else
            {
                
                [inputToolbar becomeFirstResponder];
                [inputToolbar setInputEnabled:YES];
            }
        });
    });
    dispatch_release(commentQueue);     
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)keyboardWillShow:(NSNotification *)notification 
{
    CGRect keyboardEndFrame;
    
    [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];

    /* Move the toolbar to above the keyboard */
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	CGRect frame = self.inputToolbar.frame;
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
    frame.origin.y = self.view.frame.size.height - frame.size.height - keyboardEndFrame.size.height;

    }
    else {
        frame.origin.y = self.view.frame.size.width - frame.size.height - keyboardEndFrame.size.height - kStatusBarHeight;
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

- (void)pushback
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
