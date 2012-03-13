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
-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInt:self.id forKey:@"id"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.avatar_file_name forKey:@"avatar_file_name"];
    [encoder encodeObject:self.bio forKey:@"bio"];
    [encoder encodeObject:self.created_at forKey:@"created_at"];
    [encoder encodeObject:self.external_identity forKey:@"external_identity"];
    [encoder encodeObject:self.external_username forKey:@"external_username"];
    [encoder encodeObject:self.provider forKey:@"provider"];
    [encoder encodeInt:self.status forKey:@"status"];
    
    

}

-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if ( self != nil )
    {
        //decode the properties
        self.id = [decoder decodeIntForKey:@"id"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.avatar_file_name = [decoder decodeObjectForKey:@"avatar_file_name"];
        self.bio = [decoder decodeObjectForKey:@"bio"];
        self.created_at = [decoder decodeObjectForKey:@"created_at"];
        self.external_identity = [decoder decodeObjectForKey:@"external_identity"];
        self.external_username = [decoder decodeObjectForKey:@"external_username"];
        self.provider = [decoder decodeObjectForKey:@"provider"];
        self.status = [decoder decodeIntForKey:@"status"];
    }
    return self;
}

- (void)dealloc
{
    [name release];
    [avatar_file_name release]; 
    [bio release];   
    [super dealloc];
}
@end
