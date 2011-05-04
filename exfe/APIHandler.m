//
//  APIHandler.m
//  exfe
//
//  Created by huoju on 4/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "APIHandler.h"
#import "exfeAppDelegate.h"

@implementation APIHandler
@synthesize username;
@synthesize password;
@synthesize api_key;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    exfeAppDelegate* app=(exfeAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    self.username=app.username;
//    self.password=app.password;
    self.api_key=app.api_key;// @"YsXM_E26Sq8rznxf_CeO";
    //NSLog(@"username globe:%@",app.username);

    return self;
}

+ (NSString*)URL_API_ROOT {
	return @"http://api.exfe.com/v1";    
//	return @"http://api.exfe.local:3000/v1";
}
- (NSString*)sentRSVPWith:(int)eventid rsvp:(NSString*)rsvp
{
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/events/%u/%@?api_key=%@",[APIHandler URL_API_ROOT],eventid,rsvp,api_key]]];
    [request setHTTPShouldHandleCookies:NO];
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    return responseString;    
}
- (NSString*)checkUserLoginByUsername:(NSString*)email withPassword:(NSString*)passwd
{

    NSLog(@"check user login by username:%@",email);
    NSString *post =[[NSString alloc] initWithFormat:@"login=%@&password=%@",email,passwd];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",[APIHandler URL_API_ROOT],@"users/login.json"]]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];

    [request setHTTPShouldHandleCookies:NO];

    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    return responseString;
}

- (NSString*)getMeInfo
{
    exfeAppDelegate* app=(exfeAppDelegate*)[[UIApplication sharedApplication] delegate];

    NSLog(@"getMeInfo:%@",app.username);
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?api_key=%@",[APIHandler URL_API_ROOT],@"users/self.json",api_key]]];
    [request setHTTPShouldHandleCookies:NO];

    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"me json:%@",responseString);
    return responseString;
}

- (NSString*)getUserEvents
{
    exfeAppDelegate* app=(exfeAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSLog(@"get User EventInfo:%@",app.username);
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/users/%i/events.json?api_key=%@",[APIHandler URL_API_ROOT],app.userid,api_key]]];
    [request setHTTPShouldHandleCookies:NO];

    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    return responseString;    
}
- (NSString*)getUserNews
{
    exfeAppDelegate* app=(exfeAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSLog(@"get User News:%@",app.username);
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/users/%i/news.json?api_key=%@",[APIHandler URL_API_ROOT],app.userid,api_key]]];
    [request setHTTPShouldHandleCookies:NO];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",responseString);
    return responseString;     
}
- (BOOL) regDeviceToken:(NSString*) token
{
    exfeAppDelegate* app=(exfeAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSLog(@"set user token:%@",app.username);
    
    
    NSString *post =[[NSString alloc] initWithFormat:@"token=%@&provider=iOSAPN",token];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/users/%i/identities.json?api_key=%@",[APIHandler URL_API_ROOT],app.userid,api_key]]];

    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setHTTPShouldHandleCookies:NO];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",responseString);
    id jsonobj=[responseString JSONValue];
    if([jsonobj isKindOfClass:[NSDictionary class]]   )
    {
        if([jsonobj objectForKey:@"error"]!=nil)
            return NO;
        if ([[jsonobj objectForKey:@"auth_token"] isEqualToString:token])
            return YES;     
    }
    return NO;

}
- (void)dealloc
{
    [username release];
    [password release];
    [api_key release];
    [super dealloc];
}

@end
