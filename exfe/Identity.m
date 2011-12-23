//
//  Identity.m
//  EXFE
//
//  Created by ju huo on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Identity.h"

@implementation Identity
@synthesize id;
@synthesize name;
@synthesize avatar_file_name;
@synthesize bio;
@synthesize created_at;
@synthesize provider;
@synthesize external_identity;
@synthesize external_username;
@synthesize status;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (Identity*)initWithDict:(NSDictionary*)dict
{
    Identity* useridentity= [[[self alloc] init] autorelease];

    useridentity.id = [[dict objectForKey:@"id"] integerValue];

    if([dict objectForKey:@"name"]!=[NSNull null])
        useridentity.name = [dict objectForKey:@"name"];
    else
        useridentity.name = @"";
    
    if([dict objectForKey:@"avatar_file_name"]!=[NSNull null])
        useridentity.avatar_file_name = [dict objectForKey:@"avatar_file_name"];
    else
        useridentity.avatar_file_name = @"";
    
    
    if([dict objectForKey:@"bio"]!=[NSNull null])
        useridentity.bio = [dict objectForKey:@"bio"];
    else
        useridentity.bio = @"";
    
    useridentity.status = [[dict objectForKey:@"status"] integerValue];

    if([dict objectForKey:@"provider"]!=[NSNull null])
        useridentity.provider = [dict objectForKey:@"provider"];
    else
        useridentity.provider = @"";

    if([dict objectForKey:@"external_identity"]!=[NSNull null])
        useridentity.external_identity = [dict objectForKey:@"external_identity"];
    else
        useridentity.external_identity = @"";
    
    if([dict objectForKey:@"external_username"]!=[NSNull null])
        useridentity.external_username = [dict objectForKey:@"external_username"];
    else
        useridentity.external_username = @"";

    useridentity.created_at = [dict objectForKey:@"created_at"];
    
    return useridentity;
    
}

- (void)dealloc
{
    [name release];
    [avatar_file_name release]; 
    [bio release];    
}
@end
