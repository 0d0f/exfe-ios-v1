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
    
    
    NSString *html=[self GenerateHtmlWithEvent];
    NSURL *baseURL = [NSURL fileURLWithPath:@""];
    [webview loadHTMLString:html baseURL:baseURL];

    showeventinfo=YES;
    
    keyboardIsVisible = NO;
    
    [conversationview setSeparatorColor:[UIColor clearColor]];
    
    conversionViewController=[[ConversionTableViewController alloc]initWithNibName:@"ConversionTableViewController" bundle:nil];
    CGRect crect=conversionViewController.view.frame;
    conversionViewController.view.frame=CGRectMake(crect.origin.x, crect.origin.y, crect.size.width, crect.size.height-kDefaultToolbarHeight);
    conversionViewController.comments=comments;
    [self.view addSubview:conversionViewController.view];
    [conversionViewController.view setHidden:YES];
    [conversationview setHidden:YES];
//    CGRect screenFrame = [self.view frame];
    
//    CGRect crect=conversionViewController.view.frame;
//      CGRect crect=self.view.frame;  
//    conversionViewController.view.frame=CGRectMake(crect.origin.x, crect.origin.y, crect.size.width, crect.size.height-kDefaultToolbarHeight);
//    CGRect toolbarframe=CGRectMake(0, screenFrame.size.height-kDefaultToolbarHeight, screenFrame.size.width, kDefaultToolbarHeight);
//    
//    self.inputToolbar = [[UIInputToolbar alloc] initWithFrame:toolbarframe];
//    inputToolbar.delegate = self;
//    [self.view addSubview:conversionViewController.view];
//    [self.view addSubview:self.inputToolbar];


    
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
-(void)inputButtonPressed:(NSString *)inputText
{
    /* Called when toolbar button is pressed */
//    NSLog(@"Pressed button with text: '%@'", inputText);
//    [NSThread detachNewThreadSelector:@selector(postComment:) toTarget:self withObject:inputText];
    [self performSelector:@selector(postComment:) withObject:inputText];
 
}
- (void)postComment:(NSString*)inputtext
{
    APIHandler *api=[[APIHandler alloc]init];
    NSString *commentjson=[api AddCommentById:self.eventid comment:inputtext];
    NSLog(@"commentjson:%@",commentjson);
    if([[commentjson JSONValue] objectForKey:@"comment"]!=nil)
    {
        DBUtil *dbu=[DBUtil sharedManager];
        NSArray *arr=[[NSArray alloc]initWithObjects:[commentjson JSONValue], nil];
        [dbu updateCommentobjWithid:self.eventid event:arr];
        [arr release];
        Comment *comment=[Comment initWithDict:[commentjson JSONValue] EventID:self.eventid];
//        [comments addObject:comment];
        [comments insertObject:comment atIndex:0];
        [conversationview reloadData];
//        comments=[dbu getCommentWithEventid:self.eventid];
        

        
    }
    else
    {
        NSLog(@"comment failure");
    }
    [commentjson release];
    [api release];    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [comments count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Comment *comment=[comments objectAtIndex:indexPath.row];
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2 + CELL_IMAGE_WIDTH), 20000.0f);
    
    CGSize labelSize = [comment.comment sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];

    return MAX(labelSize.height+CELL_CONTENT_MARGIN, 60.00f);

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    Comment *comment=[comments objectAtIndex:indexPath.row];
    //initWithDict
    User *user=[User initWithDict:[comment.userjson JSONValue]];
//    NSDictionary *user=;
    UILabel *label=nil;
    UIImageView *imageview=nil;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        [label setLineBreakMode:UILineBreakModeWordWrap];
        [label setMinimumFontSize:FONT_SIZE];
        [label setNumberOfLines:0];
        [label setFont:[UIFont systemFontOfSize:FONT_SIZE]];
        [label setTag:1];
//        [[label layer] setBorderWidth:2.0f];
        [[cell contentView] addSubview:label];
       
        imageview=[[UIImageView alloc] initWithFrame:CGRectZero];
        [imageview setTag:2];
        [[cell contentView] addSubview:imageview];

    }
    
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2 + CELL_IMAGE_WIDTH ), 20000.0f);
    
    CGSize size = [comment.comment sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    if (!imageview)
        label = (UILabel*)[cell viewWithTag:1];
    
    [label setText:comment.comment];
    [label setFrame:CGRectMake(CELL_CONTENT_MARGIN+CELL_IMAGE_WIDTH, CELL_CONTENT_MARGIN, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2 + CELL_IMAGE_WIDTH), MAX(size.height, 50.0f))];

    if (!imageview)
        imageview = (UIImageView*)[imageview viewWithTag:2];
    
    if(user.avatar_file_name!=nil && ![user.avatar_file_name isEqualToString:@""])
    {
        NSLog(@"update image%@",user.avatar_file_name);
        [imageview setFrame:CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN, CELL_IMAGE_WIDTH, CELL_IMAGE_HEIGHT)];
        NSString* imgName = [user.avatar_file_name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; 
        NSString *imgurl=[NSString stringWithFormat:@"http://exfe.com/system/avatars/%u/thumb/%@",user.id,imgName];
        UIImage *image = [[ImgCache sharedManager] getImgFrom:imgurl];
        if(image!=nil && ![image isEqual:[NSNull null]]) 
            imageview.image=image;
    }
    return cell;
}
@end
