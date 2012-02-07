//
//  Activity.m
//  EXFE
//
//  Created by ju huo on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Activity.h"
#import "Identity.h"

@implementation Activity
@synthesize log_id;
@synthesize by_id;
@synthesize to_id;
@synthesize cross_id;
@synthesize time;
@synthesize action;
@synthesize data;
@synthesize title;
@synthesize by_name;
@synthesize by_avatar;
@synthesize to_name;
@synthesize to_avatar;

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
    Activity* activity= [[[self alloc] init] autorelease];
    activity.action=action;
    activity.log_id = [[dict objectForKey:@"log_id"] integerValue];
    activity.by_id = [[dict objectForKey:@"by_id"] integerValue];
    activity.to_id = [[dict objectForKey:@"to_id"] integerValue];
    activity.cross_id = cross_id;
    
    if([dict objectForKey:@"time"]!=[NSNull null])
        activity.time = [dict objectForKey:@"time"];
    else
        activity.time = @"";
    
    activity.action = action;
    
    if([action isEqualToString:@"conversation"])
    {
        if([dict objectForKey:@"message"]!=[NSNull null])
            activity.data = [dict objectForKey:@"message"];
        else
            activity.data = @"";
    } else {
    if([dict objectForKey:@"data"]!=[NSNull null])
        activity.data = [dict objectForKey:@"data"];
    else
        activity.data = @"";
    }
    
    if([dict objectForKey:@"title"]!=[NSNull null])
        activity.title = [dict objectForKey:@"title"];
    else
        activity.title = @"";

//    if([dict objectForKey:@"by_name"]!=nil)
//        activity.by_name = [dict objectForKey:@"by_name"];
//    else
//        activity.by_name = @"";
    
    if([dict objectForKey:@"to_name"]!=nil)
        activity.to_name = [dict objectForKey:@"to_name"];
    else
        activity.to_name = @"";

    if(activity.by_id == activity.to_id || activity.to_id==0)
    {
        if([dict objectForKey:@"identity"]!=nil)
        {
            Identity* useridentity=[Identity initWithDict:[dict objectForKey:@"identity"]];
            activity.by_avatar = useridentity.avatar_file_name;
            activity.by_name = useridentity.name;
        }
        
    }
    else
    {
        if([dict objectForKey:@"identity"]!=nil)
        {
            Identity* useridentity=[Identity initWithDict:[dict objectForKey:@"identity"]];
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
@end
