//
//  Invitation.m
//  exfe
//
//  Created by 霍 炬 on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Invitation.h"

@implementation Invitation
@synthesize id;
@synthesize eventid;   
@synthesize identity_id;
@synthesize user_id;
@synthesize username;
@synthesize provider;
@synthesize state;
@synthesize avatar;
@synthesize updated_at;
@synthesize withnum;
@synthesize ishost;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}
+ (Invitation*)initWithDict:(NSDictionary*)dict EventID:(NSInteger)eid
{
    Invitation* invitation= [[[self alloc] init] autorelease];
    invitation.id = [[dict objectForKey:@"invitation_id"] integerValue];
    invitation.user_id = [[dict objectForKey:@"user_id"] integerValue];
    invitation.eventid=eid;
    invitation.state=[[dict objectForKey:@"state"] integerValue];
        if([dict objectForKey:@"name"]!=[NSNull null])
            invitation.username=[dict objectForKey:@"name"];
        else
            invitation.username=@"";
        
        if([dict objectForKey:@"avatar_file_name"]!=[NSNull null])
            invitation.avatar=[dict objectForKey:@"avatar_file_name"];
        else
            invitation.avatar=@"";
        
    invitation.provider=[dict objectForKey:@"provider"];
    invitation.identity_id=[[dict objectForKey:@"identity_id"] integerValue];
    invitation.updated_at=[dict objectForKey:@"updated_at"];
    invitation.withnum=[[dict objectForKey:@"withnum"] integerValue];
    invitation.ishost=[[dict objectForKey:@"ishost"] integerValue];
    return invitation;
}

- (void)dealloc
{
    [username release];
    [provider release]; 
    [avatar release];
    [updated_at release];  
    [super dealloc];
}
@end
