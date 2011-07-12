//
//  Comment.m
//  exfe
//
//  Created by 霍 炬 on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Comment.h"
//#import "JSON/JSON.h"
#import "JSON/SBJson.h"

@implementation Comment

@synthesize id;
@synthesize eventid;  
@synthesize user_id;  
@synthesize comment;
@synthesize userjson;
@synthesize created_at;
@synthesize updated_at;
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (Comment*)initWithDict:(NSDictionary*)dict EventID:(NSInteger)eid
{
    Comment* comment= [[[self alloc] init] autorelease];
    comment.id = [[dict objectForKey:@"id"] integerValue];
    comment.eventid=eid;

    if([dict objectForKey:@"content"]!=[NSNull null])
        comment.comment = [dict objectForKey:@"content"];
    else
        comment.comment = @"";

    if([dict objectForKey:@"created_at"]!=[NSNull null])
        comment.created_at = [dict objectForKey:@"created_at"];
    else
        comment.created_at = @"";

    if([dict objectForKey:@"updated_at"]!=[NSNull null])
        comment.updated_at = [dict objectForKey:@"updated_at"];
    else
        comment.updated_at = @"";
    if([dict objectForKey:@"user"]!=[NSNull null])
            comment.userjson=[[dict objectForKey:@"identity"] JSONRepresentation];
    else
        comment.userjson=@"";

    return comment;
    
}
- (void)dealloc
{
    [comment release];
    [userjson release];
    [created_at release];
    [updated_at release];
    [super dealloc];
    
}
@end
