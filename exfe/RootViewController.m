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
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];  
    NSString *lastUpdateTime=[[NSUserDefaults standardUserDefaults] stringForKey:@"lastupdatetime"]; 
    if(lastUpdateTime==nil)
        [self LoadUserEvents]; 
    else
        [self LoadUpdate];
    
    [self stopLoading];

    [pool drain];    
}

- (BOOL)LoadUserEventsFromDB
{
    DBUtil *dbu=[DBUtil sharedManager];
    events=[dbu getRecentEventObj];
    
//    lastupdatetime
    [tableview reloadData];
    NSString *lastUpdateTime=[dbu getLastEventUpdateTime];
    [[NSUserDefaults standardUserDefaults] setObject:lastUpdateTime  forKey:@"lastupdatetime"];
    return NO;
}
- (void)LoadUpdate
{
    NSLog(@"load user update");
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    exfeAppDelegate* app=(exfeAppDelegate*)[[UIApplication sharedApplication] delegate];
    UIApplication* mapp = [UIApplication sharedApplication];
    mapp.networkActivityIndicatorVisible = YES;
    if(app.api_key==nil)
        return;
    APIHandler *api=[[APIHandler alloc]init];
    NSString *responseString=[api getUpdate];
    NSLog(@"%@",responseString);
    [api release];
    DBUtil *dbu=[DBUtil sharedManager];
    id jsonobj=[responseString JSONValue];
    id code=[[jsonobj objectForKey:@"meta"] objectForKey:@"code"];
    if([code isKindOfClass:[NSNumber class]] && [code intValue]==200)
    {
        id updateobjs=[jsonobj objectForKey:@"response"];
        if([updateobjs isKindOfClass:[NSArray class]])
        {
            NSArray *updatelist=(NSArray*)updateobjs;
            int count=[updatelist count];
            for(int i=count-1;i>=0;i--)
            {
                NSDictionary *updateobj=[updatelist objectAtIndex:i];
                id conversation=[updateobj objectForKey:@"conversation"];
                NSArray *confirmed=[updateobj objectForKey:@"confirmed"];
                NSArray *declined=[updateobj objectForKey:@"declined"];
                NSArray *change=[updateobj objectForKey:@"change"];
                
                int cross_id=[[updateobj objectForKey:@"cross_id"] intValue];
                if([conversation isKindOfClass:[NSArray class]])
                {
                        NSArray *conversations=(NSArray*)conversation;
                        NSMutableArray *objs=[[NSMutableArray alloc]initWithCapacity:50];
                        for(int idx=[conversations count]-1;idx>=0;idx--)
                        {
                            NSDictionary *conversationobj=[conversations objectAtIndex:idx];
                            id meta=[[conversationobj objectForKey:@"meta"] JSONValue];
                            if([meta isKindOfClass: [NSDictionary class]])
                            {
                                NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithCapacity:50];

                                id postid=[meta objectForKey:@"id"];
                                if(postid!=nil)
                                {
                                    [dict setObject:postid forKey:@"id"];
                                    [dict setObject:[conversationobj objectForKey:@"message"] forKey:@"content"];
                                    [dict setObject:[conversationobj objectForKey:@"identity"] forKey:@"identity"];
                                    [dict setObject:[conversationobj objectForKey:@"time"] forKey:@"created_at"];
                                    [dict setObject:[conversationobj objectForKey:@"time"] forKey:@"updated_at"];
                                    [objs addObject:dict];
                                    [dict release];
                                }
                            }
                        }
                        if([objs count]>0)
                            [dbu updateCommentobjWithid:cross_id event:objs];   
                        [objs release];
                }
                if([confirmed isKindOfClass:[NSArray class]])
                {
                    for(int idx=[confirmed count]-1;idx>=0;idx--)
                    {
                        NSDictionary *confirmedobj=[confirmed objectAtIndex:idx];
                        id meta=[[confirmedobj objectForKey:@"meta"] JSONValue];
                        NSDictionary *identity=[confirmedobj objectForKey:@"identity"];
                        if([meta isKindOfClass: [NSDictionary class]])
                        {
                            NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithCapacity:50];
                            
                            id invitation_id = [meta objectForKey:@"id"];
                            if(invitation_id!=nil)
                            {
                                [dict setObject:invitation_id forKey:@"invitation_id"];
                                [dict setObject:@"1" forKey:@"state"];
                                [dict setObject:[identity objectForKey:@"name"]  forKey:@"name"];
                                if([meta objectForKey:@"provider"]==nil)
                                    [dict setObject:@""  forKey:@"provider"];
                                else
                                    [dict setObject:[meta objectForKey:@"provider"]  forKey:@"provider"];
                                [dict setObject:[identity objectForKey:@"avatar_file_name"]  forKey:@"avatar_file_name"];
                                [dict setObject:[confirmedobj objectForKey:@"time"] forKey:@"updated_at"];
                                [dbu updateInvitationWithCrossId:cross_id invitation:dict];
                                [dict release];
                            }
                        }
                    }
                }
                if([declined isKindOfClass:[NSArray class]])
                {
                    for(int idx=[declined count]-1;idx>=0;idx--)
                    {
                        NSDictionary *declinedobj=[declined objectAtIndex:idx];
                        id meta=[[declinedobj objectForKey:@"meta"] JSONValue];
                        NSDictionary *identity=[declinedobj objectForKey:@"identity"];
                        if([meta isKindOfClass: [NSDictionary class]])
                        {
                            NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithCapacity:50];
                            
                            id invitation_id = [meta objectForKey:@"id"];
                            if(invitation_id!=nil)
                            {
                                [dict setObject:invitation_id forKey:@"invitation_id"];
                                [dict setObject:@"0" forKey:@"state"];
                                [dict setObject:[identity objectForKey:@"name"]  forKey:@"name"];
                                if([meta objectForKey:@"provider"]==nil)
                                    [dict setObject:@""  forKey:@"provider"];
                                else
                                    [dict setObject:[meta objectForKey:@"provider"]  forKey:@"provider"];
                                [dict setObject:[identity objectForKey:@"avatar_file_name"]  forKey:@"avatar_file_name"];
                                [dict setObject:[declinedobj objectForKey:@"time"] forKey:@"updated_at"];
                                [dbu updateInvitationWithCrossId:cross_id invitation:dict];
                                [dict release];
                            }
                        }
                    }
                }
                if([change isKindOfClass:[NSDictionary class]])
                {
//                    NSArray *keys=[(NSDictionary*)change allKeys];
//                    for (int idx=0;i<[keys count];i++)
//                    {
//                        NSString *key=[keys objectAtIndex:idx];
//                        id changeobj=[(NSDictionary*)change objectForKey:key];
//                    }
                }
                
                NSLog(@"%@",updateobj);
            }
        }

    }

//        id crosses=[[jsonobj objectForKey:@"response"] objectForKey:@"crosses"];
//        if([crosses isKindOfClass:[NSArray class]])
//        {
//            [self UpdateDBWithEventDicts:(NSArray*)crosses];
//        }
//    else
//    {
//        NSLog(@"error: %@",[[jsonobj objectForKey:@"meta"] objectForKey:@"error"]);
//        
//    }
    
    mapp.networkActivityIndicatorVisible = NO;
//    [self LoadUserEventsFromDB];
    
    
    [pool drain];    
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
    
    
    [pool drain];
    
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
    static NSString *MyIdentifier = @"tblCrossCellView";
    
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
        dispatch_queue_t imgQueue = dispatch_queue_create("fetchurl thread", NULL);
        
        dispatch_async(imgQueue, ^{
            NSString* imgName = [user.avatar_file_name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; 
            NSString *imgurl = [ImgCache getImgUrl:imgName];
            
            UIImage *image = [[ImgCache sharedManager] getImgFrom:imgurl];

            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(image!=nil && ![image isEqual:[NSNull null]]) 
                    [cell setAvartar:image];

            });
        });
        
        dispatch_release(imgQueue);        
        
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
    [events release];
    [eventData release];
    [super dealloc];
}

@end
