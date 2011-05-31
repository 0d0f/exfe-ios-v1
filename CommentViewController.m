//
//  CommentViewController.m
//  exfe
//
//  Created by huoju on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommentViewController.h"
#import "EventViewController.h"
#import "APIHandler.h"
#import "DBUtil.h"

@implementation CommentViewController
@synthesize eventid;
@synthesize delegate;

+ (void)present:(UIViewController*)parentViewController event:(int)eventid delegate:(id)adelegate {
	CommentViewController *vc = [[[CommentViewController alloc] init] autorelease];
    vc.eventid=eventid;
    vc.delegate=adelegate;
	[parentViewController presentModalViewController:vc animated:NO];
//	_tweetViewController = [vc retain];
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
    [self setupViews];

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (void)setupViews {
    
	self.view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)] autorelease];
	
	UIToolbar *toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
	toolbar.barStyle = UIBarStyleBlackTranslucent;
    /*
     UIBarButtonItem *closeButton = [[[UIBarButtonItem alloc] 
     initWithTitle:@"close" 
     style:UIBarButtonItemStyleBordered 
     target:self action:@selector(closeButtonPushed:)] autorelease];
     */
	UIBarButtonItem *clearButton = [[[UIBarButtonItem alloc] 
                                     initWithTitle:@"close" 
                                     style:UIBarButtonItemStyleBordered 
                                     target:self action:@selector(closeButtonPushed:)] autorelease];
	
	UIView *expandView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 193, 44)] autorelease];
    
//	textLengthView = [[UILabel alloc] initWithFrame:CGRectMake(80, 5, 115, 34)];
//	textLengthView.font = [UIFont boldSystemFontOfSize:20];
//	textLengthView.textAlignment = UITextAlignmentRight;
//	textLengthView.textColor = [UIColor whiteColor];
//	textLengthView.backgroundColor = [UIColor clearColor];
//	textLengthView.text = @"140";
//	
//	[expandView addSubview:textLengthView];
	
	UIBarButtonItem	*expand = [[[UIBarButtonItem alloc] initWithCustomView:expandView] autorelease];
	
	UIBarButtonItem *sendButton = [[[UIBarButtonItem alloc] 
									initWithTitle:@"post" 
									style:UIBarButtonItemStyleBordered 
									target:self action:@selector(sendButtonPushed:)] autorelease];
	
	[toolbar setItems:[NSArray arrayWithObjects:clearButton, expand, sendButton, nil]];
	
	
//	tweetPostView = [[NTLNTweetPostView alloc] initWithFrame:CGRectMake(0, 44, 320, 200)];
//	tweetPostView.textViewDelegate = self;
	
	UIToolbar *bottonbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 200, 320, 44)] autorelease];
	bottonbar.barStyle = UIBarStyleBlackTranslucent;
    [self.view addSubview:toolbar];

    textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 44, 320, 200)];
    textView.font = [UIFont systemFontOfSize:16];
//    textView.delegate = self;
    textView.scrollEnabled = YES;
    textView.alwaysBounceVertical = YES;
//    textView.text=@"1111111";
    [self.view addSubview:textView];
    [textView becomeFirstResponder]; 
//	UIBarButtonItem *cameraButton = [[[UIBarButtonItem alloc] 
//                                      initWithBarButtonSystemItem:UIBarButtonSystemItemCamera 
//                                      target:self
//                                      action:@selector(cameraButtonPushed:)] autorelease];
	/*
     UIBarButtonItem *audioButton = [[[UIBarButtonItem alloc]
     initWithImage:[UIImage imageNamed:@"icons_07.png"]
     style:UIBarButtonItemStylePlain
     target:self 
     action:@selector(closeButtonPushed:)] autorelease];
     */
//	UIBarButtonItem *linkButton = [[[UIBarButtonItem alloc]
//                                    initWithImage:[UIImage imageNamed:@"icons_08.png"]
//                                    style:UIBarButtonItemStylePlain
//                                    target:self 
//                                    action:@selector(linkButtonPushed:)] autorelease];
//    
//	UIView *buttonExpandView = [[[UIView alloc] initWithFrame:CGRectMake(0, 200, 133, 24)] autorelease];
//	
//	UIBarButtonItem	*buttonExpand = [[[UIBarButtonItem alloc] initWithCustomView:buttonExpandView] autorelease];
//	
//	UIBarButtonItem *trashButton = [[[UIBarButtonItem alloc]
//                                     initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
//                                     target:self
//                                     action:@selector(trashButtonPushed:)] autorelease];
//	
//	UIBarButtonItem *actionButton = [[[UIBarButtonItem alloc]
//                                      initWithBarButtonSystemItem:UIBarButtonSystemItemAction
//                                      target:self
//                                      action:@selector(actionButtonPressed:)] autorelease];
//	
//	[bottonbar setItems:[NSArray arrayWithObjects:cameraButton, linkButton, buttonExpand, trashButton, actionButton, nil]];	
//    
//	imagePresentIcon = [[[UIImageView alloc] initWithFrame:CGRectMake(290, 170, 25, 25)] autorelease];
//	[imagePresentIcon setImage:[UIImage imageNamed:@"icons_10.png"]];
//	[self.view addSubview:tweetPostView];
//	[self.view addSubview:imagePresentIcon];
//	[self.view addSubview:bottonbar];
//	[self updateViewColors];
//	
//	imagePresentIcon.hidden = YES;
//	imageToPost = [[UIImage alloc] init];
//	
//	//Setup di activityIndicatorView
//	activityView =[[UIView alloc] initWithFrame:CGRectMake(50, 90, 230, 150)];
//	activityView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.7];
//	
//	UIActivityIndicatorView *act = [[UIActivityIndicatorView alloc] 
//									initWithFrame:CGRectMake(90, 20, 50, 50)];
//	[act setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
//	
//	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 100, 230, 30)];
//	label.text = @"Getting location...";
//	label.textColor = [UIColor whiteColor];
//	label.font = [UIFont boldSystemFontOfSize:20];
//	label.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.01];
//	
//	[act startAnimating];
//	[activityView addSubview:act];
//	[activityView addSubview:label];
//	
//	[label release];
//	[act release];
}

- (IBAction)closeButtonPushed:(id)sender {
	[textView resignFirstResponder];
    [self dismissModalViewControllerAnimated:NO];
//    [_tweetViewController dismissModalViewControllerAnimated:NO];

//	[NTLNTweetPostViewController dismiss];
}
- (IBAction)sendButtonPushed:(id)sender {
//	[[NTLNTwitterPost shardInstance] updateText:tweetPostView.textView.text];
//	[[NTLNTwitterPost shardInstance] updateImage:self.imageToPost];
//	[[NTLNTwitterPost shardInstance] post];
//	
//	[tweetPostView.textView resignFirstResponder];
    APIHandler *api=[[APIHandler alloc]init];
    NSString *commentjson=[api AddCommentById:self.eventid comment:textView.text];
   if([[commentjson JSONValue] objectForKey:@"comment"]!=nil)
   {
       NSString *eventjson=[api getEventById:self.eventid];
       DBUtil *dbu=[DBUtil sharedManager];
       [dbu updateEventWithid:self.eventid event:eventjson];
   }
    else
    {
        NSLog(@"comment failure");
    }
    NSLog(@"post:%@",commentjson);
 
//    [api getEventById:self.eventid];
    [commentjson release];
    [api release];
    
    [textView resignFirstResponder];
    [self.delegate updateEventView];
//    [(EventViewController*)delegate update];
    [self dismissModalViewControllerAnimated:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


@end
