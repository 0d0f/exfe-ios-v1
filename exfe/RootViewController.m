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
#import "ImgCache.h"

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
//    barButtonItem = [[UIBarButtonItem alloc]
//                     initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
//                     target:self
//                     action:@selector(refresh)];
//	self.navigationItem.rightBarButtonItem = barButtonItem;
    
    if(events==nil)
    {
        DBUtil *dbu=[DBUtil sharedManager];
        events=[dbu getRecentEventObj];
    }
}
- (void)dorefresh
{
    NSLog(@"refreshing");
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
    
    [self LoadUserEvents]; 
    [tableview reloadData];
    [self stopLoading];
}
- (void) refresh
{
    [self performSelector:@selector(dorefresh) withObject:nil afterDelay:0.1];
}

- (BOOL)LoadUserEventsFromDB
{
    DBUtil *dbu=[DBUtil sharedManager];
    events=[dbu getRecentEventObj];
    [tableview reloadData];
    return NO;
}

- (void)LoadUserEvents
{
    NSLog(@"load user events");
    
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
        NSLog(@"here1");

    NSArray *userdict = (NSArray*)jsonobj;
    [self UpdateDBWithEventDicts:userdict];
    }
    mapp.networkActivityIndicatorVisible = NO;
    [responseString release];
    [self LoadUserEventsFromDB];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
}
- (void)UpdateDBWithEventDicts:(NSArray*)_events
{
    NSLog(@"here2");

    DBUtil *dbu=[DBUtil sharedManager];
    for(int i=0;i<[_events count];i++)
    {
        NSDictionary* eventdict=(NSDictionary*)[_events objectAtIndex:i];
        
        [dbu updateEventobjWithid:[[eventdict objectForKey:@"id"] integerValue] event:eventdict];
        [dbu updateCommentobjWithid:[[eventdict objectForKey:@"id"] integerValue] event:[eventdict objectForKey:@"comments"]];
        [dbu updateInvitationobjWithid:[[eventdict objectForKey:@"id"] integerValue] event:[eventdict objectForKey:@"invitations"]];
        
        [dbu updateUserobjWithid:[[[eventdict objectForKey:@"host"] objectForKey:@"id"] integerValue] user:[eventdict objectForKey:@"host"]];
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event *event=[events objectAtIndex:indexPath.row];

    UIFont *cellFont = [UIFont systemFontOfSize:11];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    CGSize labelSize = [event.title sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    if(labelSize.height+30<50)
        return 50;
    else
        return labelSize.height+30;
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    DBUtil *dbu=[DBUtil sharedManager];
    Event *event=[events objectAtIndex:indexPath.row];
    User* user=[dbu getUserWithid:event.creator_id];

    UILabel *time = [[[UILabel alloc] initWithFrame:CGRectMake(210.0,0.0,100.0,20)] autorelease];
    time.font = [UIFont systemFontOfSize:11];
    time.textAlignment = UITextAlignmentLeft;
    time.textColor = [UIColor blackColor];
    time.lineBreakMode = UILineBreakModeWordWrap;
    time.numberOfLines = 3;
    time.autoresizesSubviews = YES;
    
    time.text=[event.begin_at substringToIndex:10];;
    [cell.contentView addSubview:time];

    
    UILabel *name = [[[UILabel alloc] initWithFrame:CGRectMake(60.0,0.0,100.0,20)] autorelease];
    name.font = [UIFont systemFontOfSize:11];
    name.textAlignment = UITextAlignmentLeft;
    name.textColor = [UIColor blackColor];
    name.lineBreakMode = UILineBreakModeWordWrap;
    name.numberOfLines = 3;
    name.autoresizesSubviews = YES;
    name.text=user.name;
    [cell.contentView addSubview:name];
    

    

    UILabel *title = [[[UILabel alloc] initWithFrame:CGRectMake(60,20,260.0,30)] autorelease];
    title.font = [UIFont systemFontOfSize:11];
    title.textAlignment = UITextAlignmentLeft;
    title.textColor = [UIColor blackColor];
    title.lineBreakMode = UILineBreakModeWordWrap;
    title.numberOfLines = 3;
    title.autoresizesSubviews = YES;
    title.text=event.title;
    [cell.contentView addSubview:title];
    
    if(user.avatar_file_name!=nil)
    {
    UIImageView *imageview=[[UIImageView alloc] initWithFrame:CGRectMake(10.0,10.0,40.0,40)] ;
    NSString* imgName = [user.avatar_file_name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; 
    NSString *imgurl=[NSString stringWithFormat:@"http://api.exfe.com/system/avatars/%u/thumb/%@",user.id,imgName];
    
    UIImage *image = [[ImgCache sharedManager] getImgFrom:imgurl];
    imageview.image=image;
    [cell.contentView addSubview:imageview];
    [imageview release];
    }
//    
//    
//    
//    UIImage *image = [[ImgCache sharedManager] getImgFrom:imgurl];
//    cell.imageView.image=image;

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
    NSLog(@"table selected");
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
