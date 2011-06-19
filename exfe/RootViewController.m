//
//  RootViewController.m
//  exfe
//
//  Created by huoju on 3/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "MeViewController.h"
#import "EventViewController.h"
#import "exfeAppDelegate.h"
#import "APIHandler.h"
#import "JSON/JSON.h"
#import "Event.h"
#import "DBUtil.h"

@implementation RootViewController
@synthesize interceptLinks;
@synthesize reload;

- (void)viewDidLoad
{
    [super viewDidLoad];
    eventData=[[NSMutableDictionary alloc]initWithCapacity:20];

    reload=YES;
//    timer = [NSTimer scheduledTimerWithTimeInterval: 30
//                                             target: self
//                                           selector: @selector(setReload)
//                                           userInfo: nil
//                                            repeats: YES];    
    barButtonItem = [[UIBarButtonItem alloc]
                     initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                     target:self
                     action:@selector(setReload)];
	self.navigationItem.rightBarButtonItem = barButtonItem;
    
    if(events==nil)
    {
        DBUtil *dbu=[DBUtil sharedManager];
        events=[dbu getRecentEventObj];
    }
    
    LoginViewController *loginview = [[LoginViewController alloc]
                                      initWithNibName:@"LoginViewController" bundle:nil];
    
    
    

}
- (void) setReload
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

    [NSThread detachNewThreadSelector:@selector(refresh) toTarget:self withObject:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(liftMainViewWhenKeybordAppears:) name:UIKeyboardWillShowNotification object:nil];

//    [super viewWillAppear:animated];
//    [self LoadUserEventsFromDB];

}
- (void) liftMainViewWhenKeybordAppears:(NSNotification*)aNotification{
    NSDictionary* userInfo = [aNotification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardBoundsUserInfoKey] getValue:&keyboardFrame];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - keyboardFrame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView commitAnimations];
}

- (BOOL)LoadUserEventsFromDB
{
//    NSArray* eventobjects=[dbu getRecentEvent];
//    NSArray* eventobjects=[dbu getRecentEventObj];
    DBUtil *dbu=[DBUtil sharedManager];
    events=[dbu getRecentEventObj];
    [tableview reloadData];
//    if(events!=nil && [eventobjects count]>0)
//    {
//        [self RenderEvents:eventobjects tosave:NO];
//        [eventobjects release];
//        return YES;
//    }
    return NO;
}

- (void)RenderEvents:(NSArray*)events tosave:(BOOL)save
{
//    NSString *myevent=@"";
////    BOOL hasevent=NO;
////    BOOL hasinvitation=NO;
////    exfeAppDelegate* app=(exfeAppDelegate*)[[UIApplication sharedApplication] delegate];
////
//    DBUtil *dbu=[DBUtil sharedManager];
//    for(int i=0;i<[events count];i++)
//    {
//        Event* event=(Event*)[events objectAtIndex:i];
//        
//        if([event isKindOfClass:[Event class]])
//        {
//            if(save==YES)
//            {
////                [dbu updateEventWithid:[[event objectForKey:@"id"] intValue]  event:[event JSONRepresentation]];
////                [dbu updateEventobjWithid:[[event objectForKey:@"id"] intValue] event:event];
//            }
//            
//            [eventData setObject:event forKey:[NSString stringWithFormat:@"http://local_%u/",event.id]];
//            
//            if([event.state isEqualToString:@"published"])
//            {
//                User* user=[dbu getUserWithid:event.creator_id];
//                NSString *username=user.name;
//                if(username==nil || username.length<1)
//                    username=user.email;
//                NSString *imgurl=[NSString stringWithFormat:@"http://exfe.com/system/avatars/%u/thumb/%@",user.id,user.avatar_file_name ];
//
//                myevent=[myevent stringByAppendingFormat:@"<div class=\"tl clear\"><div class='face'><img src='%@'></div><a href='http://local_%u/'><div class=\"content\"><p><strong>%@</strong><span>%@</span></p><p>%@..</p></div></a></div>",imgurl,event.id,username,[event.created_at substringToIndex:10],event.title];
//                [user release];
//                
//                
//                
//                
//                
////                myevent=[myevent stringByAppendingFormat:@"<li><a href='http://local_%u/'>%@</a></li>",event.id  ,];
//            }
//            
//        }
//    }
//
//    myevent=[myevent stringByAppendingString:@""];
//    NSString *html=@"<head>\
//    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=GUTF=8\" />\
//    <title>timeline</title>\
//    <style type=\"text/css\">\
//    a {text-decoration:none}\
//    .clear{ clear:both; }\
//    .tl { font-family:Verdana, Arial, Helvetica, sans-serif; font-size:13px; width:310px; color:#333333;  border-top: 1px #999 solid;}\
//    .tl  .face{ float:left; width:48px}\
//    .tl  .face img{-moz-border-radius: 3px;\
//	-webkit-border-radius: 3px;\
//    border-radius: 3px;\
//    border:1px solid gray;\
//    margin:5px}\
//    .tl  .content{ float:right; width:242px;background: url(arrow.png) no-repeat right center; }\
//    .tl  .content strong{ font-size:13px;  width:130px; float:left; margin-bottom:5px}\
//    .tl  .content p{ color:#666666; clear:both; }\
//    .tl  .content span{ float:right; co57866lor:#0099FF; width:80px; font-size:12px; margin-right:20px}\
//    </style></head><body>";
//    html=[html stringByAppendingString:myevent];
//    html=[html stringByAppendingString:@"</body></html>"];
//    NSString *basepath = [[NSBundle mainBundle] bundlePath];
//    NSURL *baseURL = [NSURL fileURLWithPath:basepath];
//    NSLog(@"%@",html);
//
//    [webview loadHTMLString:html baseURL:baseURL];   
    
}
- (void)refresh
{
    [self LoadUserEvents];

}
- (void)LoadUserEvents
{
    NSLog(@"load user events");
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    

    exfeAppDelegate* app=(exfeAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    UIApplication* mapp = [UIApplication sharedApplication];
    mapp.networkActivityIndicatorVisible = YES;
    
    
    if(app.api_key==nil)
        return;
    APIHandler *api=[[APIHandler alloc]init];
    NSString *responseString=[api getUserEvents];
    [api release];
    id jsonobj=[responseString JSONValue];

    if([jsonobj isKindOfClass:[NSDictionary class]] && [jsonobj objectForKey:@"error"]!=nil )
    {
        NSLog(@"error");
    }
    else if([jsonobj isKindOfClass:[NSArray class]])
    {
    NSArray *userdict = (NSArray*)jsonobj;
    [self UpdateDBWithEventDicts:userdict];
    }
    mapp.networkActivityIndicatorVisible = NO;
    [responseString release];
    [self LoadUserEventsFromDB];
    self.navigationItem.rightBarButtonItem = barButtonItem;

    [pool release];
    
}
- (void)UpdateDBWithEventDicts:(NSArray*)events
{
    DBUtil *dbu=[DBUtil sharedManager];
    for(int i=0;i<[events count];i++)
    {
        NSDictionary* eventdict=(NSDictionary*)[events objectAtIndex:i];
        
        [dbu updateEventobjWithid:[[eventdict objectForKey:@"id"] integerValue] event:eventdict];
        [dbu updateCommentobjWithid:[[eventdict objectForKey:@"id"] integerValue] event:[eventdict objectForKey:@"comments"]];
        [dbu updateInvitationobjWithid:[[eventdict objectForKey:@"id"] integerValue] event:[eventdict objectForKey:@"invitations"]];
        
        [dbu updateUserobjWithid:[[[eventdict objectForKey:@"creator"] objectForKey:@"id"] integerValue] user:[eventdict objectForKey:@"creator"]];
    }
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [events count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    DBUtil *dbu=[DBUtil sharedManager];
    Event *event=[events objectAtIndex:indexPath.row];
    User* user=[dbu getUserWithid:event.creator_id];

	cell.textLabel.text = user.name;//event.title; 
    cell.detailTextLabel.text=event.title;
    
    NSString* imgName = [user.avatar_file_name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; 
    NSString *imgurl=[NSString stringWithFormat:@"http://exfe.com/system/avatars/%u/thumb/%@",user.id,imgName];
    
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imgurl]]];
    cell.imageView.image=image;

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"%@",[url absoluteString]);
    Event *event=[events objectAtIndex:indexPath.row];
    EventViewController *detailViewController=[[EventViewController alloc]initWithNibName:@"EventViewController" bundle:nil];
    
    if(event!=nil)
    {
        detailViewController.eventid=event.id;
        detailViewController.eventobj=event;
    }
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release]; 	


}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    NSLog(@"drag..");
//}
//-(bool) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
//{
//    if (self.interceptLinks && navigationType==UIWebViewNavigationTypeLinkClicked) {
//        NSURL *url = request.URL;
//        NSLog(@"%@",[url absoluteString]);
//        Event *event=[eventData objectForKey:[url absoluteString]];
//        EventViewController *detailViewController=[[EventViewController alloc]initWithNibName:@"EventViewController" bundle:nil];
//        
//        if(event!=nil)
//        {
//            detailViewController.eventid=event.id;
//            detailViewController.eventobj=event;
//        }
//        [self.navigationController pushViewController:detailViewController animated:YES];
//        [detailViewController release]; 	
//        
//        return NO;
//    }
//    //No need to intercept the initial request to fill the WebView
//    else {
//        NSLog(@"interceptLinks");
//        self.interceptLinks = YES;
//        return YES;
//    }
//}

- (void)dealloc
{
    [eventData release];
    [super dealloc];
}

@end
