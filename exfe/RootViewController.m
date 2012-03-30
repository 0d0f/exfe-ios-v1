//
//  RootViewController.m
//  exfe
//
//  Created by huoju on 3/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "RootViewController.h"
#import "EventViewController.h"
#import "exfeAppDelegate.h"
#import "UserSettingViewController.h"
#import "ActivityViewController.h"
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
    uiInit=true;
    [self initUI];
    uiInit=false;
    
    NSString *uname=[[NSUserDefaults standardUserDefaults] stringForKey:@"username"]; 
    
    if(events==nil)
    {
        [self LoadUserEventsFromDB];
    }
    NSString *apikey=[[NSUserDefaults standardUserDefaults] stringForKey:@"api_key"]; 
    if(uname!=nil && [apikey length]>2 )
    {
        [self refreshWithprogress:NO];
    }
}

- (void)initUI
{
    NSString *uname=[[NSUserDefaults standardUserDefaults] stringForKey:@"username"]; 
    if(uname!=nil){
        [self.navigationController navigationBar].topItem.title=uname;
        [[self.navigationController navigationBar] setNeedsDisplay];
    }

    NSString *settingbtnimgpath = [[NSBundle mainBundle] pathForResource:@"navbar_setting" ofType:@"png"];
    UIImage *settingbtnimg = [UIImage imageWithContentsOfFile:settingbtnimgpath];
    
    UIButton *settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingButton setImage:settingbtnimg forState:UIControlStateNormal];
    settingButton.frame = CGRectMake(0, 0, settingbtnimg.size.width, settingbtnimg.size.height);
    [settingButton addTarget:self action:@selector(ShowSettingView) forControlEvents:UIControlEventTouchUpInside];
    barButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:settingButton] autorelease];
    
    [self.navigationController navigationBar].topItem.rightBarButtonItem=barButtonItem;      
    notificationHint=false;
    if(activeButton==nil)
    {
        activeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [activeButton addTarget:self action:@selector(ShowActiveView) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationController navigationBar].topItem.leftBarButtonItem =[[[UIBarButtonItem alloc] initWithCustomView:activeButton]autorelease];
        [self setNotificationButton:false];
        [[self.navigationController navigationBar] setNeedsDisplay];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
    
}
- (void)refresh
{
    [self refreshWithprogress:NO];
}
- (void)refreshWithprogress:(BOOL)show
{
    UIApplication* mapp = [UIApplication sharedApplication];
    mapp.networkActivityIndicatorVisible = YES;

    MBProgressHUD *hud = nil;
    if(show==YES)
    {
        hud=[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.labelText = @"Loading";
    }

    dispatch_queue_t refreshQueue = dispatch_queue_create("refresh cross thread", NULL);
    dispatch_async(refreshQueue, ^{

        NSString *lastUpdateTime=[[NSUserDefaults standardUserDefaults] stringForKey:@"lastupdatetime"]; 
        if(lastUpdateTime==nil)
        {
            [self LoadUserEvents:NO]; 
            [self LoadUpdate:YES]; //YES: ignore timestamp
        }
        else
        {
            [self LoadUserEvents:YES]; 
            [self LoadUpdate:NO];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopLoading];
            [tableview reloadData];
            mapp.networkActivityIndicatorVisible = NO;
            if(show==YES)
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        });
    });
    dispatch_release(refreshQueue);            
}

- (BOOL)LoadUserEventsFromDB
{
    DBUtil *dbu=[DBUtil sharedManager];
    NSMutableArray *newevents=[dbu getRecentEventObj];
    if(newevents!=nil && [newevents count]>0)
    {
        if(events!=nil)
        {
            [events release];
            events=nil;
        }
        events=newevents;
    }
    if([newevents count]==0)
        [newevents release];
    
//    [tableview reloadData];
    return NO;
}
- (void)LoadUpdate:(BOOL)ignore_time
{
    exfeAppDelegate* app=(exfeAppDelegate*)[[UIApplication sharedApplication] delegate];
    if(app.api_key==nil)
        return;
    APIHandler *api=[[APIHandler alloc]init];
    NSString *responseString=[api getUpdate:ignore_time];
    [api release];
    DBUtil *dbu=[DBUtil sharedManager];
    id jsonobj=[responseString JSONValue];
    id code=[[jsonobj objectForKey:@"meta"] objectForKey:@"code"];
    [responseString release];
    
    if([code isKindOfClass:[NSNumber class]] && [code intValue]==200)
    {
        NSMutableArray *updateCrossIDList=[[NSMutableArray alloc] initWithCapacity:10];

        NSString *lastUpdateTime=[[NSUserDefaults standardUserDefaults] stringForKey:@"lastupdatetime"]; 
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];

        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *lastUpdateTime_datetime = [dateFormat dateFromString:lastUpdateTime]; 
        
        id updateobjs=[jsonobj objectForKey:@"response"];
        int vaildobjnum=0;
        if([updateobjs isKindOfClass:[NSArray class]])
        {
            NSArray *updatelist=(NSArray*)updateobjs;
            int count=[updatelist count];
            for(int i=count-1;i>=0;i--) {
                BOOL isSelf=NO;
                NSDictionary *updateobj=[updatelist objectAtIndex:i];
                int by_user_id=[[[updateobj objectForKey:@"by_identity"] objectForKey:@"user_id"] intValue];
                if(by_user_id==app.userid) 
                    if([[updateobj objectForKey:@"action"] isEqualToString:@"conversation"] || [[updateobj objectForKey:@"action"] isEqualToString:@"gather"])
                            isSelf=YES;
                if([[updateobj objectForKey:@"action"] isEqualToString:@"conversation"]) {
                    id meta=[[updateobj objectForKey:@"meta"] JSONValue];
                    if([meta isKindOfClass: [NSDictionary class]]) {
                        NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithCapacity:50];
                        id postid=[meta objectForKey:@"id"];
                        if(postid!=nil)
                        {
                            [dict setObject:postid forKey:@"id"];
                            [dict setObject:[updateobj objectForKey:@"message"] forKey:@"message"];
                            [dict setObject:[updateobj objectForKey:@"x_title"] forKey:@"title"];
                            [dict setObject:[updateobj objectForKey:@"by_identity"] forKey:@"by_identity"];
                            [dict setObject:[updateobj objectForKey:@"x_begin_at"] forKey:@"created_at"];
                            [dict setObject:[updateobj objectForKey:@"time"] forKey:@"updated_at"];
                            [dict setObject:[updateobj objectForKey:@"log_id"] forKey:@"log_id"];
                            [dict setObject:[updateobj objectForKey:@"x_title"] forKey:@"title"];
                            [dict setObject:[updateobj objectForKey:@"time"] forKey:@"time"];

                            [dbu updateConversationWithid:[[updateobj objectForKey:@"x_id"] intValue] cross:dict];
                            [dbu setCrossStatusWithCrossId:[[updateobj objectForKey:@"x_id"] intValue] status:1];
                            if(isSelf==NO)
                                [dbu updateActivityWithobj:dict action:@"conversation" cross_id:[[updateobj objectForKey:@"x_id"] intValue]];
                            vaildobjnum=vaildobjnum+1;
                        }
                        [dict release];
                    }
                }
                else if([[updateobj objectForKey:@"action"] isEqualToString:@"addexfee"] || [[updateobj objectForKey:@"action"] isEqualToString:@"delexfee"]) {
                    NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithCapacity:50];
                    id to_identity=[updateobj objectForKey:@"to_identity"];
                    if([to_identity isKindOfClass:[NSArray class]])
                        [dict setObject:[[updateobj objectForKey:@"to_identity"]  JSONRepresentation] forKey:@"to_identities"];
                    [dict setObject:[updateobj objectForKey:@"by_identity"] forKey:@"by_identity"];
                    [dict setObject:[updateobj objectForKey:@"x_begin_at"] forKey:@"x_begin_at"];
                    if([updateobj objectForKey:@"x_place"]!=nil){
                        if([[updateobj objectForKey:@"x_place"] objectForKey:@"line1"])
                            [dict setObject:[[updateobj objectForKey:@"x_place"] objectForKey:@"line1"] forKey:@"place_line1"];

                        if([[updateobj objectForKey:@"x_place"] objectForKey:@"line2"])
                            [dict setObject:[[updateobj objectForKey:@"x_place"] objectForKey:@"line2"] forKey:@"place_line2"];

                        if([[updateobj objectForKey:@"x_place"] objectForKey:@"provider"])
                            [dict setObject:[[updateobj objectForKey:@"x_place"] objectForKey:@"provider"] forKey:@"place_provider"];
                        if([[updateobj objectForKey:@"x_place"] objectForKey:@"external_id"])
                            [dict setObject:[[updateobj objectForKey:@"x_place"] objectForKey:@"external_id"] forKey:@"place_external_id"];

                        if([[updateobj objectForKey:@"x_place"] objectForKey:@"lng"])
                            [dict setObject:[[updateobj objectForKey:@"x_place"] objectForKey:@"lng"] forKey:@"place_lng"];

                        if([[updateobj objectForKey:@"x_place"] objectForKey:@"lat"])
                            [dict setObject:[[updateobj objectForKey:@"x_place"] objectForKey:@"lat"] forKey:@"place_lat"];
                    }
                    if([updateobj objectForKey:@"x_time_type"]!=nil)
                            [dict setObject:[updateobj objectForKey:@"x_time_type"]  forKey:@"x_time_type"];
                    [dict setObject:[updateobj objectForKey:@"time"] forKey:@"time"];
                    [dict setObject:[updateobj objectForKey:@"x_title"] forKey:@"title"];
                    [dict setObject:[updateobj objectForKey:@"log_id"] forKey:@"log_id"];
                    if(isSelf==NO)
                        [dbu updateActivityWithobj:dict action:[updateobj objectForKey:@"action"] cross_id:[[updateobj objectForKey:@"x_id"] intValue]];
                    [dict release];
                    vaildobjnum=vaildobjnum+1;
                    [updateCrossIDList addObject:[NSNumber numberWithInt:[[updateobj objectForKey:@"x_id"] intValue]]];
                }
                else if([[updateobj objectForKey:@"action"] isEqualToString:@"confirmed"] || [[updateobj objectForKey:@"action"] isEqualToString:@"declined"] || [[updateobj objectForKey:@"action"] isEqualToString:@"interested"])
                {
                    NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithCapacity:50];
                    id to_identity=[updateobj objectForKey:@"to_identity"];
                    if([to_identity isKindOfClass:[NSArray class]])
                        [dict setObject:[[updateobj objectForKey:@"to_identity"]  JSONRepresentation] forKey:@"to_identities"];

                    [dict setObject:[updateobj objectForKey:@"by_identity"] forKey:@"by_identity"];
                    [dict setObject:[updateobj objectForKey:@"x_title"] forKey:@"title"];
                    [dict setObject:[updateobj objectForKey:@"time"] forKey:@"time"];
                    [dict setObject:[updateobj objectForKey:@"log_id"] forKey:@"log_id"];
                    [dbu updateInvitationobjWithCrossid:[[updateobj objectForKey:@"x_id"] intValue] identity_id:to_identity rsvp:[updateobj objectForKey:@"action"]];
                    if(isSelf==NO)
                        [dbu updateActivityWithobj:dict action:[updateobj objectForKey:@"action"] cross_id:[[updateobj objectForKey:@"x_id"] intValue]];
                    [dict release];
                    vaildobjnum=vaildobjnum+1;
                }
                else if([[updateobj objectForKey:@"action"] isEqualToString:@"title"] || [[updateobj objectForKey:@"action"] isEqualToString:@"begin_at"]|| [[updateobj objectForKey:@"action"] isEqualToString:@"place"]|| [[updateobj objectForKey:@"action"] isEqualToString:@"description"])
                {
                    NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithCapacity:50];
                    [dict setObject:[updateobj objectForKey:@"log_id"] forKey:@"log_id"];
                    [dict setObject:[updateobj objectForKey:@"by_identity"] forKey:@"by_identity"];
                    if([[updateobj objectForKey:@"new_value"] isKindOfClass:[NSString class]])
                        [dict setObject:[updateobj objectForKey:@"new_value"] forKey:@"data"];
                    else if([updateobj objectForKey:@"new_value"] !=nil)
                        [dict setObject:[[updateobj objectForKey:@"new_value"]  JSONRepresentation] forKey:@"data"];
                    
                    [dict setObject:[updateobj objectForKey:@"time"] forKey:@"time"];
                    [dict setObject:[updateobj objectForKey:@"log_id"] forKey:@"log_id"];

                    if([updateobj objectForKey:@"x_time_type"]!=nil)
                        [dict setObject:[updateobj objectForKey:@"x_time_type"]  forKey:@"x_time_type"];

                    [dict setObject:[updateobj objectForKey:@"x_id"] forKey:@"id"];
                    
                    if([[updateobj objectForKey:@"action"] isEqualToString:@"title"])
                    {
                        if([updateobj objectForKey:@"old_value"] !=nil)
                            [dict setObject:[updateobj objectForKey:@"old_value"] forKey:@"title"];
                        else
                            [dict setObject:[updateobj objectForKey:@"x_title"] forKey:@"title"];
                    }
                    else
                        [dict setObject:[updateobj objectForKey:@"x_title"] forKey:@"title"];
                    [dict setObject:[updateobj objectForKey:@"x_description"] forKey:@"description"];
                    [dict setObject:[updateobj objectForKey:@"x_begin_at"] forKey:@"begin_at"];
                    [dict setObject:[updateobj objectForKey:@"time"] forKey:@"updated_at"];
                    
                    [dict setObject:[updateobj objectForKey:@"x_time_type"] forKey:@"time_type"];
                    
                    [dict setObject:[[updateobj objectForKey:@"x_host_identity"] objectForKey:@"id"] forKey:@"host_id"];

                    [dict setObject:[[updateobj objectForKey:@"x_place"] objectForKey:@"line1"] forKey:@"place_line1"];
                    [dict setObject:[[updateobj objectForKey:@"x_place"] objectForKey:@"line2"] forKey:@"place_line2"];
                    [dict setObject:[[updateobj objectForKey:@"x_place"] objectForKey:@"provider"] forKey:@"place_provider"];
                    [dict setObject:[[updateobj objectForKey:@"x_place"] objectForKey:@"external_id"] forKey:@"place_external_id"];
                    [dict setObject:[[updateobj objectForKey:@"x_place"] objectForKey:@"lng"] forKey:@"place_lng"];
                    [dict setObject:[[updateobj objectForKey:@"x_place"] objectForKey:@"lat"] forKey:@"place_lat"];
                    [dict setObject:[updateobj objectForKey:@"x_background"] forKey:@"background"];

                    
                    [dict setObject:[NSNumber numberWithInt:1] forKey:@"state"];
                    [dbu updateEventobjWithid:[[updateobj objectForKey:@"x_id"] intValue] event:dict isnew:YES];
                    if(isSelf==NO)
                        [dbu updateActivityWithobj:dict action:[updateobj objectForKey:@"action"] cross_id:[[updateobj objectForKey:@"x_id"] intValue]];
                    [dict release];
                    vaildobjnum=vaildobjnum+1;
                }
                NSDate *update_datetime = [dateFormat dateFromString:[updateobj objectForKey:@"time"]]; 
                lastUpdateTime_datetime=[update_datetime laterDate:lastUpdateTime_datetime];
            }
        }
        lastUpdateTime = [dateFormat stringFromDate:lastUpdateTime_datetime]; 
        [dateFormat release];
        [[NSUserDefaults standardUserDefaults] setObject:lastUpdateTime  forKey:@"lastupdatetime"];
        NSNumber *num=[[NSUserDefaults standardUserDefaults] objectForKey:@"notification_number"];
        if(vaildobjnum>0)
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[num intValue]+vaildobjnum]  forKey:@"notification_number"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        if([updateCrossIDList count] > 0) 
        {
            [updateCrossIDList setArray:[[NSSet setWithArray:updateCrossIDList] allObjects]];
            APIHandler *api=[[APIHandler alloc]init];
             NSString *responseString = [api getCrossesByIdList: [updateCrossIDList componentsJoinedByString:@","]];
            [api release];
            id jsonobj=[responseString JSONValue];
            [responseString release];
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
                        [dbu updateEventobjWithid:[[updateobj objectForKey:@"id"] integerValue] event:updateobj isnew:YES];
                        [dbu updateInvitationobjWithid:[[updateobj objectForKey:@"id"] integerValue] event:[updateobj objectForKey:@"invitations"]];
                        [dbu updateUserobjWithid:[[[updateobj objectForKey:@"host"] objectForKey:@"id"] integerValue] user:[updateobj objectForKey:@"host"]];
                    }
                }   
            }
        }
        
        [updateCrossIDList release];        
    }
//    mapp.networkActivityIndicatorVisible = NO;
    [self LoadUserEventsFromDB];
}
- (void)setNotificationButton:(BOOL)status
{
    if(status==true)
    {
        if(notificationHint==false || uiInit==true)
        {
        NSString *notificationimgpath = [[NSBundle mainBundle] pathForResource:@"notification_hl" ofType:@"png"];
        UIImage *notificationbtnimg = [UIImage imageWithContentsOfFile:notificationimgpath];
        [activeButton setImage:notificationbtnimg forState:UIControlStateNormal];
        if(uiInit==true)
            activeButton.frame = CGRectMake(0, 0, notificationbtnimg.size.width, notificationbtnimg.size.height);
        notificationHint=true;
        }
    }
    else
    {
        if(notificationHint==true || uiInit==true)
        {
        NSString *notificationimgpath = [[NSBundle mainBundle] pathForResource:@"notification" ofType:@"png"];
        UIImage *notificationbtnimg = [UIImage imageWithContentsOfFile:notificationimgpath];
        [activeButton setImage:notificationbtnimg forState:UIControlStateNormal];
        if(uiInit==true)
            activeButton.frame = CGRectMake(0, 0, notificationbtnimg.size.width, notificationbtnimg.size.height);
        notificationHint=false;
        }
    }
    [activeButton setNeedsDisplay];
    
}
- (void)defaultChanged:(NSNotification *)notif
{
    id object=[notif object];
    if([object isKindOfClass:[NSUserDefaults class]])
    {
        NSNumber *num=[(NSUserDefaults*)object objectForKey:@"notification_number"];
        if([num intValue]==0)
            [self setNotificationButton:false];
        else
            [self setNotificationButton:true];
    }
    
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
    exfeAppDelegate* app=(exfeAppDelegate*)[[UIApplication sharedApplication] delegate];
    
//    UIApplication* mapp = [UIApplication sharedApplication];
//    mapp.networkActivityIndicatorVisible = YES;
    if(app.api_key==nil)
        return;
    APIHandler *api=[[APIHandler alloc]init];
    NSString *responseString=[api getUserEvents];
    [api release];
    id jsonobj=[responseString JSONValue];
    id code=[[jsonobj objectForKey:@"meta"] objectForKey:@"code"];
    [responseString release];

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
//        NSLog(@"error: %@",[[jsonobj objectForKey:@"meta"] objectForKey:@"error"]);
        
    }
//    mapp.networkActivityIndicatorVisible = NO;
    [self LoadUserEventsFromDB];
    NSString *lastUpdateTime=[[NSUserDefaults standardUserDefaults] stringForKey:@"lastupdatetime"]; 

    if(isnew==NO && lastUpdateTime == nil)
    {
        DBUtil *dbu=[DBUtil sharedManager];
        lastUpdateTime=[dbu getLastEventUpdateTime];
        [[NSUserDefaults standardUserDefaults] setObject:lastUpdateTime  forKey:@"lastupdatetime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
- (void)UpdateDBWithEventDicts:(NSArray*)_events isnew:(BOOL)isnew
{

    DBUtil *dbu=[DBUtil sharedManager];
    for(int i=0;i<[_events count];i++)
    {
        NSMutableDictionary* eventdict=[[_events objectAtIndex:i] mutableCopy];
        id place=[eventdict objectForKey:@"place"];
        if(place !=nil && [place isKindOfClass:[NSDictionary class]])
        {
            [eventdict setObject:[((NSDictionary*)place) objectForKey:@"line1"] forKey:@"place_line1"];
            [eventdict setObject:[((NSDictionary*)place) objectForKey:@"line2"] forKey:@"place_line2"];   
            [eventdict setObject:[((NSDictionary*)place) objectForKey:@"external_id"] forKey:@"place_external_id"];   
            [eventdict setObject:[((NSDictionary*)place) objectForKey:@"provider"] forKey:@"place_provider"];   
            [eventdict setObject:[((NSDictionary*)place) objectForKey:@"lng"] forKey:@"place_lng"];   
            [eventdict setObject:[((NSDictionary*)place) objectForKey:@"lat"] forKey:@"place_lat"];   
        }
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
        return 49;

    return 61;
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
    NSString *begin_at=[event.begin_at stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *arr = [begin_at componentsSeparatedByString:@" "];

    NSString *date=[arr objectAtIndex:0];
    NSString *time=[arr objectAtIndex:1];
    
    if([place isEqualToString:@""] &&([date isEqualToString:@"0000-00-00"] && [time isEqualToString:@"00:00:00"] && [event.time_type isEqualToString:@""]))        
        [cell setCellModel:1];
    else
        [cell setCellModel:2];

    [cell setLabelText: [event.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    
    if([begin_at isEqualToString:@"0000-00-00 00:00:00"])
        [cell setLabelTime:@""];
    else
    {   
        NSString *x_str=[Util getLongLocalTimeStrWithTimetype:event.time_type time:begin_at];
        [cell setLabelTime:x_str];
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
            NSString* imgName = user.avatar_file_name;
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
    Cross *event=[events objectAtIndex:indexPath.row];
    EventViewController *detailViewController=[[EventViewController alloc]initWithNibName:@"EventViewController" bundle:nil] ;
    
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
        
        NSNumber *num=[[NSUserDefaults standardUserDefaults] objectForKey:@"notification_number"];
        if([num intValue]>0)
        {
            int newcross=0;
            for(int i=0;i<[events count];i++)
            {
                Cross *cross=[events objectAtIndex:i];
                if(cross.flag==1)
                    newcross=newcross+1;
            }
            if(newcross==0)
            {
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0]  forKey:@"notification_number"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }

        }
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
- (void)ShowActiveView
{
   ActivityViewController *activeview=[[ActivityViewController alloc] initWithNibName:@"ActivityViewController" bundle:nil];
    DBUtil *dbu=[DBUtil sharedManager];
    NSMutableArray *activityList=[dbu getRecentActivityFromLogid:0 start:0 num:200];
    activeview.activityList = activityList;
    [self.navigationController pushViewController:activeview animated:YES];
    [self cleanAllCrossStatus];
    
 }
- (void)cleanAllCrossStatus
{
    BOOL redraw=NO;
    for(int i=0;i<[events count];i++)
        if(((Cross*)[events objectAtIndex:i]).flag==1)
        {
            ((Cross*)[events objectAtIndex:i]).flag=0;
            redraw=YES;
        }
    if(redraw==YES)
        [tableview reloadData];
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
//        NSLog(@"cross_id:%u",event.id);
        if(event.id==cross_id)
            return event;
    }
    return nil;
    
}

- (void)dealloc
{
    [super dealloc];
}


@end

