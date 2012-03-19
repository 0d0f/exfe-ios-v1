//
//  Event.m
//  exfe
//
//  Created by 霍 炬 on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Cross.h"


@implementation Cross

@synthesize id;
@synthesize title;
@synthesize description;
@synthesize background;
@synthesize code;
@synthesize begin_at;
@synthesize end_at;
@synthesize duration;
@synthesize place_line1;
@synthesize place_line2;
@synthesize place_provider;
@synthesize place_external_id;
@synthesize place_lng;
@synthesize place_lat;

@synthesize creator_id;
@synthesize created_at;
@synthesize updated_at;
@synthesize state;
@synthesize flag;
@synthesize time_type;

+ (Cross*)initWithDict:(NSDictionary*)dict
{
    Cross* event= [[[self alloc] init] autorelease];
    event.id = [[dict objectForKey:@"id"] integerValue];
    
    if([dict objectForKey:@"title"]!=[NSNull null])
        event.title = [dict objectForKey:@"title"];
    else
        event.title = @"";

    if([dict objectForKey:@"description"]!=[NSNull null])
        event.description = [dict objectForKey:@"description"];
    else
        event.description = @"";

    if([dict objectForKey:@"background"]!=[NSNull null])
        event.background = [dict objectForKey:@"background"];
    else
        event.background = @"";

    if([dict objectForKey:@"code"]!=[NSNull null])
        event.code = [dict objectForKey:@"code"];
    else
        event.code = @"";
    
    if([dict objectForKey:@"begin_at"]!=[NSNull null])
        event.begin_at = [dict objectForKey:@"begin_at"];
    else
        event.begin_at = @"";
    
    if([dict objectForKey:@"end_at"]!=[NSNull null])
        event.end_at = [dict objectForKey:@"end_at"];
    else
        event.end_at = @"";
    
    if([dict objectForKey:@"duration"]!=[NSNull null])
        event.duration = [[dict objectForKey:@"duration"] integerValue];
    else
        event.duration = 0;
    
    if([dict objectForKey:@"place_line1"]!=[NSNull null])
        event.place_line1 = [dict objectForKey:@"place_line1"];
    else
        event.place_line1 = @"";

    if([dict objectForKey:@"place_line2"]!=[NSNull null])
        event.place_line2 = [dict objectForKey:@"place_line2"];
    else
        event.place_line2 = @"";

    if([dict objectForKey:@"place_provider"]!=nil)
        event.place_provider = [dict objectForKey:@"place_provider"];
    else
        event.place_provider = @"";
    
    if([dict objectForKey:@"place_external_id"]!=nil)
        event.place_external_id = [dict objectForKey:@"place_external_id"];
    else
        event.place_external_id = @"";

    if([dict objectForKey:@"place_lng"]!=nil)
        event.place_lng = [dict objectForKey:@"place_lng"];
    else
        event.place_lng = @"0.0";
    
    if([dict objectForKey:@"place_lat"]!=nil)
        event.place_lat = [dict objectForKey:@"place_lat"];
    else
        event.place_lat = @"0.0";
    
    event.creator_id = [[dict objectForKey:@"host_id"] integerValue];

    if([dict objectForKey:@"created_at"]!=[NSNull null])
        event.created_at = [dict objectForKey:@"created_at"];
    else
        event.created_at = @"";

    if([dict objectForKey:@"updated_at"]!=[NSNull null])
        event.updated_at = [dict objectForKey:@"updated_at"];
    else
        event.updated_at = @"";

    if([dict objectForKey:@"state"]!=[NSNull null])
        event.state = [[dict objectForKey:@"state"] integerValue];
    else
        event.state = 0;

    if([dict objectForKey:@"flag"]!=[NSNull null])
        event.flag = [[dict objectForKey:@"flag"] integerValue];
    else
        event.flag = 0;

    if([dict objectForKey:@"time_type"]!=nil)
        event.time_type = [dict objectForKey:@"time_type"] ;
    else
        event.time_type = @"";
    return event;
}
- (void)dealloc
{
    [title release];
    [description release];
    [background release];
    [code release];
    [begin_at release];
    [end_at release];
    [place_line1 release];
    [place_line2 release];
    [place_provider release];
    [place_external_id release];
    [place_lng release];
    [place_lat release];
    [created_at release];
    [updated_at release];
    [time_type release];
    [super dealloc];
}
@end
