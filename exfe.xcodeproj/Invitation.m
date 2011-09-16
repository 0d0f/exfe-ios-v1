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
@synthesize username;
@synthesize provider;
@synthesize state;
@synthesize avatar;

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
    invitation.eventid=eid;
    invitation.state=[[dict objectForKey:@"state"] integerValue];
//    if([dict objectForKey:@"invited_identity"]!=[NSNull null])
//    {
//        NSDictionary* iden=[dict objectForKey:@"invited_identity"];
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
//    }
    return invitation;
}
@end
