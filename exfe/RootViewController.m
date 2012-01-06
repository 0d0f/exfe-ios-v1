//
//  RootViewController.m
//  exfe
//
//  Created by huoju on 3/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "RootViewController.h"
#import "MeViewController.h"
#import "EventViewController.h"
#import "exfeAppDelegate.h"
#import "UserSettingViewController.h"
#import "APIHandler.h"
#import "JSON/SBJson.h"
#import "DBUtil.h"
#import "ImgCache.h"
#import "UIButton+StyledButton.h"
#import "UIBarButtonItem+StyledButton.h"


@implementation RootViewController
@synthesize interceptLinks;
@synthesize reload;

- (void)viewDidLoad
{
    [super viewDidLoad];
    reload=YES;
    NSString *uname=[[NSUserDefaults standardUserDefaults] stringForKey:@"username"]; 

    //self.navigationController.title=uname;
    [self.navigationController navigationBar].topItem.title=uname;
    NSString *settingbtnimgpath = [[NSBundle mainBundle] pathForResource:@"navbar_setting" ofType:@"png"];
    UIImage *settingbtnimg = [UIImage imageWithContentsOfFile:settingbtnimgpath];
    
    UIButton *settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingButton setImage:settingbtnimg forState:UIControlStateNormal];
    [settingButton addTarget:self action:@selector(ShowSettingView) forControlEvents:UIControlEventTouchUpInside];
    settingButton.frame = (CGRect) {
        .size.width = 40,
        .size.height = 30,
    };
    [[settingButton layer] setCornerRadius:5.0f];
    [[settingButton layer] setBorderWidth:1.0f];
    [[settingButton layer] setBorderColor:[UIColor blackColor].CGColor];

    barButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:settingButton] autorelease];

    //TOFIX: Add leftbutton for fill space, otherwise the custom title can't align center.
//    [self.navigationController navigationBar].topItem.leftBarButtonItem=barButtonItem;
    [self.navigationController navigationBar].topItem.rightBarButtonItem=barButtonItem;    

    self.navigationItem.backBarButtonItem = [UIBarButtonItem styledBackBarButtonItemWithTarget:self selector:@selector(pushback)];
    
    if ([[self.navigationController navigationBar] respondsToSelector:@selector (setBackgroundImage:forBarMetrics:)]) {  // iOS 5
        UIImage *toolBarIMG = [UIImage imageNamed: @"navbar_bg.jpg"];  
        [[self.navigationController navigationBar] setBackgroundImage:toolBarIMG forBarMetrics:0];
    }

    if(events==nil)
    {
        [self LoadUserEventsFromDB];
//        DBUtil *dbu=[DBUtil sharedManager];
//        events=[dbu getRecentEventObj];
    }
//    NSString *uname=[[NSUserDefaults standardUserDefaults] stringForKey:@"username"]; 
    NSString *apikey=[[NSUserDefaults standardUserDefaults] stringForKey:@"api_key"]; 
    if(uname!=nil && [apikey length]>2 )
    {
        [NSThread detachNewThreadSelector:@selector(refresh) toTarget:self withObject:nil];
    }
}

- (void) refresh
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];  
    NSString *lastUpdateTime=[[NSUserDefaults standardUserDefaults] stringForKey:@"lastupdatetime"]; 
    if(lastUpdateTime==nil)
        [self LoadUserEvents:NO]; 
    else
    {
        [self LoadUserEvents:YES]; 
        [self LoadUpdate];
    }
    
    [self stopLoading];

    [pool drain];    
}

- (BOOL)LoadUserEventsFromDB
{
    DBUtil *dbu=[DBUtil sharedManager];
    events=[dbu getRecentEventObj];
    [tableview reloadData];
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
    [api release];
    DBUtil *dbu=[DBUtil sharedManager];
    id jsonobj=[responseString JSONValue];
    id code=[[jsonobj objectForKey:@"meta"] objectForKey:@"code"];
    if([code isKindOfClass:[NSNumber class]] && [code intValue]==200)
    {
        NSString *lastUpdateTime=[[NSUserDefaults standardUserDefaults] stringForKey:@"lastupdatetime"]; 
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];

        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *lastUpdateTime_datetime = [dateFormat dateFromString:lastUpdateTime]; 
        
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
                            NSDate *update_datetime = [dateFormat dateFromString:[conversationobj objectForKey:@"time"]]; 
                            lastUpdateTime_datetime=[update_datetime laterDate:lastUpdateTime_datetime];

                        }
                        if([objs count]>0)
                        {
                            [dbu updateCommentobjWithid:cross_id event:objs];   
                            [dbu setCrossStatusWithCrossId:cross_id status:1];
                        }
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
                                [dbu setCrossStatusWithCrossId:cross_id status:1];

                                [dict release];

                            }
                        }
                        NSDate *update_datetime = [dateFormat dateFromString:[confirmedobj objectForKey:@"time"]]; 
                        lastUpdateTime_datetime=[update_datetime laterDate:lastUpdateTime_datetime];

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
                                [dbu setCrossStatusWithCrossId:cross_id status:1];

                                [dict release];
                                NSDate *update_datetime = [dateFormat dateFromString:[declinedobj objectForKey:@"time"]]; 
                                lastUpdateTime_datetime=[update_datetime laterDate:lastUpdateTime_datetime];

                            }
                        }
                    }
                }
                if([change isKindOfClass:[NSDictionary class]])
                {
                    NSDate* changeupdatetime=[dbu updateCrossWithCrossId:cross_id change:(NSDictionary*)change lastupdatetime:lastUpdateTime_datetime] ;
                    [dbu setCrossStatusWithCrossId:cross_id status:1];

                    lastUpdateTime_datetime=[changeupdatetime laterDate:lastUpdateTime_datetime];

                }
                for (NSString *key in (NSDictionary*)updateobj)
                {
                    NSLog(@"%@",key);
                }
//                NSLog(@"%@",updateobj);
            }
        }
        lastUpdateTime = [dateFormat stringFromDate:lastUpdateTime_datetime]; 
        [dateFormat release];
        [[NSUserDefaults standardUserDefaults] setObject:lastUpdateTime  forKey:@"lastupdatetime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    mapp.networkActivityIndicatorVisible = NO;
    [self LoadUserEventsFromDB];
    
    [pool drain];    
    NSString *lastUpdateTime=[[NSUserDefaults standardUserDefaults] stringForKey:@"lastupdatetime"]; 
    NSLog(@"update:%@",lastUpdateTime);

}
- (void)emptyView
{
    NSMutableArray *discardedItems = [NSMutableArray array];
    Cross *item;
    
    for (item in events) {
            [discardedItems addObject:item];
    }
    
    [events removeObjectsInArray:discardedItems];    
    [tableview reloadData];
}

- (void)LoadUserEvents:(BOOL)isnew
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
            [self UpdateDBWithEventDicts:(NSArray*)crosses isnew:isnew];
        }
    }
    else
    {
        NSLog(@"error: %@",[[jsonobj objectForKey:@"meta"] objectForKey:@"error"]);
        
    }

    mapp.networkActivityIndicatorVisible = NO;
    [self LoadUserEventsFromDB];
    
    //getLastEventUpdateTime
    NSString *lastUpdateTime=[[NSUserDefaults standardUserDefaults] stringForKey:@"lastupdatetime"]; 

    if(isnew==NO && lastUpdateTime == nil)
    {
        DBUtil *dbu=[DBUtil sharedManager];
        lastUpdateTime=[dbu getLastEventUpdateTime];
        [[NSUserDefaults standardUserDefaults] setObject:lastUpdateTime  forKey:@"lastupdatetime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [pool drain];
    
}
- (void)UpdateDBWithEventDicts:(NSArray*)_events isnew:(BOOL)isnew
{

    DBUtil *dbu=[DBUtil sharedManager];
    for(int i=0;i<[_events count];i++)
    {
        NSDictionary* eventdict=(NSDictionary*)[_events objectAtIndex:i];
        
        [dbu updateEventobjWithid:[[eventdict objectForKey:@"id"] integerValue] event:eventdict isnew:isnew];
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
    Cross *event=[events objectAtIndex:indexPath.row];
    
    NSString *place=event.place_line1;
    NSString *time=[event.begin_at substringToIndex:10];

    if([place isEqualToString:@""]  && [time isEqualToString:@"0000-00-00"])
        return 44;

    return 62;
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

    NSString *place=[event.place_line1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *time=[event.begin_at stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    NSString *time_str=[time substringWithRange:NSMakeRange(11,8)];
    if([place isEqualToString:@""]  && ([time isEqualToString:@"0000-00-00 00:00:00"] || event.time_type==3))
        [cell setCellModel:1];
    else
        [cell setCellModel:2];

    [cell setLabelText: [event.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    
    if([time isEqualToString:@"0000-00-00 00:00:00"])
        [cell setLabelTime:@""];
    else
    {   
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *time_datetime = [dateFormat dateFromString:time]; 
        [dateFormat setDateFormat:@"ha ccc MM-dd"];
        if(event.time_type==2)
        {
            [dateFormat setDateFormat:@"ccc MM-dd"];
        }
        NSString *result=[dateFormat stringFromDate:time_datetime]; 
        
//        ccc
//        if([time length]==10)
//            time=[time substringWithRange:NSMakeRange(5,5)];
        [cell setLabelTime:result];
        [dateFormat release];
    }
    [cell setLabelPlace:place];

    if(event.flag==1)
        [cell setNewTitleColor:YES];
    else
        [cell setNewTitleColor:NO];
    
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
    DBUtil *dbu=[DBUtil sharedManager];
    [dbu setCrossStatusWithCrossId:event.id status:0];
    if(event.flag==1)
    {
        event.flag=0;
        
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

-(void)ShowSettingView
{
    UserSettingViewController *settingview=[[UserSettingViewController alloc] initWithNibName:@"UserSettingViewController" bundle:nil];
    [self presentModalViewController:settingview animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

-(void)pushback
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (Cross*)getEventByCrossId:(int)cross_id
{
    for (Cross *event in events)
    {
        NSLog(@"cross_id:%u",event.id);
        if(event.id==cross_id)
            return event;
    }
    return nil;
    
}

- (void)dealloc
{
    [events release];
//    [eventData release];
    [super dealloc];
}

@end

