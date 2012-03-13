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
@synthesize code;
@synthesize begin_at;
@synthesize end_at;
@synthesize duration;
@synthesize place_line1;
@synthesize place_line2;
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
   [code release];
   [begin_at release];
   [end_at release];
   [place_line1 release];
   [place_line2 release];
   [created_at release];
   [updated_at release];
    [time_type release];
   [super dealloc];
}
@end
