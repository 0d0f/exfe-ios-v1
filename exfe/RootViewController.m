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
#import "DBUtil.h"

@implementation RootViewController
@synthesize interceptLinks;
@synthesize reload;

- (void)viewDidLoad
{
    [super viewDidLoad];
    interceptLinks=NO;
    eventData=[[NSMutableDictionary alloc]initWithCapacity:20];

    
    timer = [NSTimer scheduledTimerWithTimeInterval: 30
                                             target: self
                                           selector: @selector(setReload)
                                           userInfo: nil
                                            repeats: YES];    
}
- (void) setReload
{
    [NSThread detachNewThreadSelector:@selector(LoadUserEvents) toTarget:self withObject:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self LoadUserEventsFromDB];
}
- (BOOL)LoadUserEventsFromDB
{
    DBUtil *dbu=[DBUtil alloc];
    
    NSArray* eventobjects=[dbu getRecentEvent];
    [dbu release];
    if(eventobjects!=nil && [eventobjects count]>0)
    {
        [self RenderEvents:eventobjects tosave:NO];
        return YES;
    }
    return NO;
}
- (void)RenderEvents:(NSArray*)events tosave:(BOOL)save
{
    NSString *myevent=@"<h1>我发起的：</h1><ul>";
    NSString *myinvitation=@"<h1>我的邀请：</h1><ul>";
    BOOL hasevent=NO;
    BOOL hasinvitation=NO;
    exfeAppDelegate* app=(exfeAppDelegate*)[[UIApplication sharedApplication] delegate];
    DBUtil *dbu=[DBUtil alloc];

    for(int i=0;i<[events count];i++)
    {
        id event=[events objectAtIndex:i];
        
        if([event isKindOfClass:[NSDictionary class]])
        {
            NSLog(@"%@",[event JSONRepresentation]);
            if(save==YES)
                [dbu updateEventWithid:[[event objectForKey:@"id"] intValue]  event:[event JSONRepresentation]];
            
            [eventData setObject:event forKey:[NSString stringWithFormat:@"http://local_%@/",[event objectForKey:@"id"]]];
            int creator_id=[[(NSDictionary*)event objectForKey:@"creator_id"] intValue];
            NSLog(@"creator_id:%i",creator_id);
            if(creator_id==app.userid && [[event objectForKey:@"state"] isEqualToString:@"published"])
            {
                hasevent=YES;
                myevent=[myevent stringByAppendingFormat:@"<li><a href='http://local_%@/'>%@</a></li>",[[event objectForKey:@"id"] stringValue] ,[event objectForKey:@"title"]];
            }
            if(creator_id!=app.userid && [[event objectForKey:@"state"] isEqualToString:@"published"])
            {
                hasinvitation=YES;
                myinvitation=[myinvitation stringByAppendingFormat:@"<li><a href='http://local_%@/'>%@</a></li>",[[event objectForKey:@"id"] stringValue] ,[event objectForKey:@"title"]];
            }
        }
    }
    [dbu release];

    myevent=[myevent stringByAppendingString:@"</ul>"];
    myinvitation=[myinvitation stringByAppendingString:@"</ul>"];
    NSString *html=@"";
    if(hasevent==YES)
        html=[html stringByAppendingString:myevent];
    if(hasinvitation==YES)
        html=[html stringByAppendingString:myinvitation];
    [webview loadHTMLString:html baseURL:nil];   
    
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
    [self RenderEvents:userdict tosave:YES];
    }
    mapp.networkActivityIndicatorVisible = NO;
    [responseString release];
    [pool release];
    
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
    return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    // Configure the cell.
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
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
	*/
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
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"drag..");
}
-(bool) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (self.interceptLinks && navigationType==UIWebViewNavigationTypeLinkClicked) {
        NSURL *url = request.URL;
        NSLog(@"%@",[url absoluteString]);
        NSDictionary *event=[eventData objectForKey:[url absoluteString]];
        EventViewController *detailViewController=[[EventViewController alloc]initWithNibName:@"EventViewController" bundle:nil];
        
        if(event!=nil)
        {
//            detailViewController.event=event;
            detailViewController.eventid=[[event objectForKey:@"id"] intValue]                        ;
        }
        [self.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release]; 	
        
        return NO;
    }
    //No need to intercept the initial request to fill the WebView
    else {
        NSLog(@"interceptLinks");
        self.interceptLinks = YES;
        return YES;
    }
}

- (void)dealloc
{
    [eventData release];
    [super dealloc];
}

@end
