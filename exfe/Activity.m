//
//  Activity.m
//  EXFE
//
//  Created by ju huo on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Activity.h"
#import "Identity.h"
#import "exfeAppDelegate.h"
#import "NSObject+SBJson.h"


@implementation Activity
@synthesize log_id;
@synthesize by_id;
@synthesize to_id;
@synthesize cross_id;
@synthesize time;
@synthesize action;
@synthesize data;
@synthesize title;
@synthesize begin_at;
@synthesize place_line1;
@synthesize time_type;
@synthesize by_name;
@synthesize by_avatar;
@synthesize to_name;
@synthesize to_avatar;
@synthesize to_identities;
@synthesize invitationmsg;
@synthesize withmsg;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (Activity*)initWithDict:(NSDictionary*)dict action:(NSString*)action cross_id:(int)cross_id
{
    exfeAppDelegate* app=(exfeAppDelegate*)[[UIApplication sharedApplication] delegate];

    Activity* activity= [[[self alloc] init] autorelease];
    activity.action=action;
    activity.log_id = [[dict objectForKey:@"log_id"] integerValue];
    activity.withmsg=@"";
    activity.invitationmsg=@"";
    if([[dict objectForKey:@"by_identity"] isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *by_identity=[dict objectForKey:@"by_identity"];
        activity.by_id = [[by_identity objectForKey:@"id"] integerValue];
        activity.by_name = [by_identity objectForKey:@"name"];
    }
    id to_identity=[dict objectForKey:@"to_identities"];
    if([to_identity isKindOfClass:[NSDictionary class]])
    {
        activity.to_id = [[to_identity objectForKey:@"id"] integerValue];
        activity.to_name = [to_identity objectForKey:@"name"];
    } else if([to_identity isKindOfClass:[NSArray class]]){
            activity.to_identities=to_identity;
    }
    else if([to_identity isKindOfClass:[NSString class]]) {
        activity.to_identities=[to_identity JSONValue];
    }
    activity.cross_id = cross_id;
    if([dict objectForKey:@"data"]!=nil)
        activity.data = [dict objectForKey:@"data"];
    
    if([dict objectForKey:@"time"]!=nil)
        activity.time = [dict objectForKey:@"time"];
    else
        activity.time = @"";
    

    if([dict objectForKey:@"place_line1"]!=nil)
        activity.place_line1 = [dict objectForKey:@"place_line1"];
    else
        activity.place_line1 = @"";

    activity.time_type=[dict objectForKey:@"x_time_type"];

    activity.action = action;
    
    if([action isEqualToString:@"conversation"])
    {
        if([dict objectForKey:@"message"]!=[NSNull null])
            activity.data = [dict objectForKey:@"message"];
        else
            activity.data = @"";
    } 
    else if([action isEqualToString:@"confirmed"]|| [action isEqualToString:@"interested"]|| [action isEqualToString:@"declined"]){
        id to_identities=[[dict objectForKey:@"to_identities"] JSONValue];
        activity.to_identities=to_identities;
    }
    else if([action isEqualToString:@"addexfee"] || [action isEqualToString:@"delexfee"]){
        id to_identities=[[dict objectForKey:@"to_identities"] JSONValue];
        if([to_identities isKindOfClass:[NSArray class]]) {
            NSMutableArray *exfees=to_identities ;
            BOOL gather=NO; // if your id in the exfee list, it's should be display as gather and with msg, if not, show the invitation msg
            for (int i=0;i<[exfees count];i++) {
                NSDictionary *exfee=(NSDictionary*)[exfees objectAtIndex:i];
                if(![exfee isEqual:[NSNull null]])
                    if([[exfee objectForKey:@"user_id"] intValue]!=0 && app.userid==[[exfee objectForKey:@"user_id"] intValue]) {
                    [exfees removeObjectAtIndex:i];
                    gather=YES;
                    activity.action=@"gather";
                }
            }
            
            if(gather==YES) {
                NSString *withmsg=@"";
                activity.invitationmsg=[NSString stringWithFormat:@"Invitation from %@",activity.by_name];
                activity.to_identities=exfees;
                for (int i=0;i<[exfees count];i++) {
                    NSDictionary *exfee=(NSDictionary*)[exfees objectAtIndex:i];
                    NSString *to_name=[exfee objectForKey:@"name"];
                    if(app.userid!=[[exfee objectForKey:@"user_id"] intValue])
                    {
                        withmsg = [withmsg stringByAppendingFormat:@"%@ ",to_name];
                    }
                }
                activity.withmsg = withmsg;
                NSString *begin_at=@"";
                if([dict objectForKey:@"x_begin_at"]!=nil)
                    begin_at = [dict objectForKey:@"x_begin_at"];
                else
                    begin_at = @"";
                activity.begin_at=begin_at;
                activity.action=@"gather";
            }
        }
    } else {
    
    }
    
    if([dict objectForKey:@"title"]!=nil)
        activity.title = [dict objectForKey:@"title"];
    else
        activity.title = @"";

    if([dict objectForKey:@"to_name"]!=nil)
        activity.to_name = [dict objectForKey:@"to_name"];
    else
        activity.to_name = @"";

    if(activity.by_id == activity.to_id || activity.to_id==0)
    {
        if([dict objectForKey:@"by_identity"]!=nil)
        {
            Identity* useridentity=[Identity initWithDict:[dict objectForKey:@"by_identity"]];
            activity.by_avatar = useridentity.avatar_file_name;
            activity.by_name = useridentity.name;
        }
        
    }
    else
    {
        if([dict objectForKey:@"by_identity"]!=nil)
        {
            Identity* useridentity=[Identity initWithDict:[dict objectForKey:@"by_identity"]];
            activity.to_avatar = useridentity.avatar_file_name;
            activity.to_name = useridentity.name;
        }
        if([dict objectForKey:@"by_name"]!=nil)
                activity.by_name = [dict objectForKey:@"by_name"];
            else
                activity.by_name = @"";
    }
    
    
    return activity;    
}

- (void)dealloc
{
    [by_name release];
    [by_avatar release];
    
    [to_name release];
    [to_avatar release];
    [to_identities release];
    
    [time release];
    [action release];
    [data release];
    [title release];
    [time_type release];
    [begin_at release];
    [place_line1 release];
    [invitationmsg release];
    [withmsg release];
    [super dealloc];
}

@end
