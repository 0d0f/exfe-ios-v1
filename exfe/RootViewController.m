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
//#import "JSON/JSON.h"
#import "JSON/SBJson.h"
#import "Cross.h"
#import "DBUtil.h"
#import "ImgCache.h"

@implementation RootViewController
@synthesize interceptLinks;
@synthesize reload;

- (void)viewDidLoad
{
    [super viewDidLoad];
    eventData=[[NSMutableDictionary alloc]initWithCapacity:20];
//     DBUtil *dbu=[DBUtil sharedManager];
//    [dbu getLastEventUpdateTime];
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
//- (void)dorefresh
//{
//    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];  
//    
//    [self LoadUserEvents]; 
//    [self stopLoading];
//    [pool release];    
//}
- (void) refresh
{
    
    [self LoadUserEvents]; 
    [self stopLoading];

//    [NSThread detachNewThreadSelector:@selector(dorefresh) toTarget:self withObject:nil];
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

    id code=[[jsonobj objectForKey:@"meta"] objectForKey:@"code"];
    if([code isKindOfClass:[NSNumber class]] && [code intValue]==200)
    {
        id crosses=[[jsonobj objectForKey:@"response"] objectForKey:@"crosses"];
        if([crosses isKindOfClass:[NSArray class]])
        {
            [self UpdateDBWithEventDicts:(NSArray*)crosses];
        }
    }
    else
    {
        NSLog(@"error: %@",[[jsonobj objectForKey:@"meta"] objectForKey:@"error"]);
        
    }

    mapp.networkActivityIndicatorVisible = NO;
    [self LoadUserEventsFromDB];
    
}
- (void)UpdateDBWithEventDicts:(NSArray*)_events
{

    DBUtil *dbu=[DBUtil sharedManager];
    for(int i=0;i<[_events count];i++)
    {
        NSDictionary* eventdict=(NSDictionary*)[_events objectAtIndex:i];
        
        [dbu updateEventobjWithid:[[eventdict objectForKey:@"id"] integerValue] event:eventdict];
        [dbu updateCommentobjWithid:[[eventdict objectForKey:@"id"] integerValue] event:[eventdict objectForKey:@"conversations"]];
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
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    MyIdentifier = @"tblCellView";
    
    CrossCellView *cell = (CrossCellView *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if(cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"CrossCellView" owner:self options:nil];
        cell = tblCell;
    }
    Cross *event=[events objectAtIndex:indexPath.row];
    [cell setLabelText:event.title];
    [cell setLabelTime:[event.begin_at substringToIndex:10]];

    DBUtil *dbu=[DBUtil sharedManager];
    User* user=[dbu getUserWithid:event.creator_id];
    if(user.avatar_file_name!=nil)
    {
        NSString* imgName = [user.avatar_file_name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; 
//        NSString *imgurl=[NSString stringWithFormat:@"%@/eimgs/80_80_%@",[APIHandler URL_API_DOMAIN],imgName];
        NSString *imgurl = [ImgCache getImgUrl:imgName];
        
        UIImage *image = [[ImgCache sharedManager] getImgFrom:imgurl];
        [cell setAvartar:image];
    }    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"table selected");
    Cross *event=[events objectAtIndex:indexPath.row];
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
}


- (void)dealloc
{
    [eventData release];
    [super dealloc];
}

@end
