//
//  Event.m
//  exfe
//
//  Created by 霍 炬 on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Event.h"


@implementation Event

@synthesize id;
@synthesize title;
@synthesize description;
@synthesize code;
@synthesize begin_at;
@synthesize end_at;
@synthesize duration;
@synthesize venue;
@synthesize creator_id;
@synthesize created_at;
@synthesize updated_at;
@synthesize state;
+ (Event*)initWithDict:(NSDictionary*)dict
{
    Event* event= [[[self alloc] init] autorelease];
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
    
    if([dict objectForKey:@"venue"]!=[NSNull null])
        event.venue = [dict objectForKey:@"venue"];
    else
        event.venue = @"";

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
        event.state = [dict objectForKey:@"state"];
    else
        event.state = @"";

    return event;
}
- (void)dealloc
{
   [title release];
   [description release];
   [code release];
   [begin_at release];
   [end_at release];
   [venue release];
   [created_at release];
   [updated_at release];
   [state release];  
    [super dealloc];
}
@end
