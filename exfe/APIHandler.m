//
//  APIHandler.m
//  exfe
//
//  Created by huoju on 4/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "APIHandler.h"
#import "exfeAppDelegate.h"
#import "DBUtil.h"

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
}
- (NSString*)sentRSVPWith:(int)eventid rsvp:(NSString*)rsvp
{
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/crosses/%u/%@?api_key=%@",[APIHandler URL_API_ROOT],eventid,rsvp,api_key]]];
    [request setHTTPShouldHandleCookies:NO];
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *responseString = [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] autorelease];
    return responseString;    
}
- (NSString*)checkUserLoginByUsername:(NSString*)email withPassword:(NSString*)passwd
{

    NSString *post =[[NSString alloc] initWithFormat:@"email=%@&password=%@",email,passwd];
    
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
- (NSString*)getPostsWith:(int)crossid
{
    exfeAppDelegate* app=(exfeAppDelegate*)[[UIApplication sharedApplication] delegate];
    DBUtil *dbu=[DBUtil sharedManager];
    NSString *lastUpdateTime=[dbu getLastCommentUpdateTimeWith:crossid];

    NSError *error = nil;
    NSString *apiurl=nil;
    if(lastUpdateTime==nil)
        apiurl=[NSString stringWithFormat:@"%@/crosses/%i/posts.json?api_key=%@",[APIHandler URL_API_ROOT],crossid,api_key];
    else
        apiurl=[NSString stringWithFormat:@"%@/crosses/%i/posts.json?updated_since=%@&api_key=%@",[APIHandler URL_API_ROOT],crossid,lastUpdateTime,api_key];
    
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiurl]];
    NSLog(@"api: %@",apiurl);
    [request setHTTPShouldHandleCookies:NO];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (error)
    {
        NSLog(@"%@",error);
    }
    NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    return responseString;       
}

- (NSString*)getUserEvents
//- (id)getUserEvents
{
    exfeAppDelegate* app=(exfeAppDelegate*)[[UIApplication sharedApplication] delegate];

    DBUtil *dbu=[DBUtil sharedManager];
    NSString *lastUpdateTime=[dbu getLastEventUpdateTime];
    NSError *error = nil;
    NSString *apiurl=nil;
    if(lastUpdateTime==nil)
        apiurl=[NSString stringWithFormat:@"%@/users/%i/crosses.json?api_key=%@",[APIHandler URL_API_ROOT],app.userid,api_key];
    else
        apiurl=[NSString stringWithFormat:@"%@/users/%i/crosses.json?updated_since=%@&api_key=%@",[APIHandler URL_API_ROOT],app.userid,lastUpdateTime,api_key];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiurl]];
    NSLog(@"api: %@",apiurl);
    [request setHTTPShouldHandleCookies:NO];
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (error)
    {
        NSLog(@"%@",error);
    }
    NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
  //  id jsonobj= [responseString JSONValue];
//    [responseString release];
//    [pool release];
//    return jsonobj;
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
    NSString *responseString = [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] autorelease];
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
- (NSString*)getEventById:(int)eventid
{
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/crosses/%i.json?api_key=%@",[APIHandler URL_API_ROOT],eventid,api_key]]];
    NSLog(@"url:%@",[NSURL URLWithString:[NSString stringWithFormat:@"%@/crosses/%i.json?api_key=%@",[APIHandler URL_API_ROOT],eventid,api_key]]);
    [request setHTTPShouldHandleCookies:NO];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    return responseString;    
}
- (NSString*)AddCommentById:(int)eventid comment:(NSString*)commenttext
{
    NSString *post =[[NSString alloc] initWithFormat:@"content=%@",commenttext];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/crosses/%i/posts.json?api_key=%@",[APIHandler URL_API_ROOT],eventid,api_key]]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [request setHTTPShouldHandleCookies:NO];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    return responseString;    
//    curl -d "comment=bbbb" http://api.exfe.com/v1/events/18/comments.json?api_key=kUWeTGQwBKpTyuCERkHd
//    return @"";
}
- (void)dealloc
{
    [username release];
    [password release];
    [api_key release];
    [super dealloc];
}

@end
