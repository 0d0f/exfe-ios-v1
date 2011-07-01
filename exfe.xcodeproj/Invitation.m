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
@synthesize username;
@synthesize provider;
@synthesize state;
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
    invitation.id = [[dict objectForKey:@"id"] integerValue];
    invitation.eventid=eid;
    invitation.state=[dict objectForKey:@"state"];
    if([dict objectForKey:@"invited_identity"]!=[NSNull null])
    {
        NSDictionary* iden=[dict objectForKey:@"invited_identity"];
        invitation.username=[iden objectForKey:@"username"];
        invitation.provider=[iden objectForKey:@"provider"];
    }
    return invitation;
}
@end
