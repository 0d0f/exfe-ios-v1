//
//  User.m
//  exfe
//
//  Created by 霍 炬 on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "User.h"

@implementation User
@synthesize id;
@synthesize name;
@synthesize avatar_file_name;
@synthesize email;
@synthesize bio;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}
+ (User*)initWithDict:(NSDictionary*)dict
{
    User* user= [[self alloc] init];
    user.id = [[dict objectForKey:@"id"] integerValue];
    
    if([dict objectForKey:@"name"]!=[NSNull null])
        user.name = [dict objectForKey:@"name"];
    else
        user.name = @"";
    
    if([dict objectForKey:@"avatar_file_name"]!=[NSNull null])
        user.avatar_file_name = [dict objectForKey:@"avatar_file_name"];
    else
        user.avatar_file_name = @"";
    
    if([dict objectForKey:@"email"]!=[NSNull null])
        user.email = [dict objectForKey:@"email"];
    else
        user.email = @"";

    if([dict objectForKey:@"bio"]!=[NSNull null])
        user.bio = [dict objectForKey:@"bio"];
    else
        user.bio = @"";
    
    return user;
    
}

- (void)dealloc
{
   [name release];
   [avatar_file_name release]; 
   [email release];
   [bio release];    
}
@end
