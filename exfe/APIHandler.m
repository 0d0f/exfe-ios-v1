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
#import "NSObject+SBJson.h"
#import "NSData+Base64.h"

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
//	return @"http://exfeapi.dlol.us/v1";    
	return @"http://api.exfe.com/v1";        
}
+ (NSString*)URL_API_DOMAIN {
//	return @"http://exfeapi.dlol.us";    
    return @"http://api.exfe.com";
}

- (NSString*)sentRSVPWith:(int)eventid rsvp:(NSString*)rsvp
{
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/x/%u/%@?token=%@",[APIHandler URL_API_ROOT],eventid,rsvp,api_key]]];
    [request setHTTPShouldHandleCookies:NO];
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *responseString = [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] autorelease];
    return responseString;    
}
- (NSString*)checkUserLoginByUsername:(NSString*)email withPassword:(NSString*)passwd
{

    NSString *post =[[NSString alloc] initWithFormat:@"user=%@&password=%@",email,passwd];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",[APIHandler URL_API_ROOT],@"users/login"]]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];

    [request setHTTPShouldHandleCookies:NO];

    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",responseString);
    return responseString;
}

- (NSString*)getProfile
{
    exfeAppDelegate* app=(exfeAppDelegate*)[[UIApplication sharedApplication] delegate];

    NSString *url=[NSString stringWithFormat:@"%@/users/%i/getprofile?token=%@",[APIHandler URL_API_ROOT],app.userid,api_key];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPShouldHandleCookies:NO];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",responseString);
    return responseString;    

}
- (NSString*)getPostsWith:(int)crossid
{
//    exfeAppDelegate* app=(exfeAppDelegate*)[[UIApplication sharedApplication] delegate];
    DBUtil *dbu=[DBUtil sharedManager];
    NSString *lastUpdateTime=[dbu getLastCommentUpdateTimeWith:crossid];
    
//    NSDate *theDate = nil;
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    theDate = [dateFormatter dateFromString:lastUpdateTime];  
//    [dateFormatter release];
    

    NSError *error = nil;
    NSString *apiurl=nil;
    if(lastUpdateTime==nil)
        apiurl=[NSString stringWithFormat:@"%@/x/%i/posts?token=%@",[APIHandler URL_API_ROOT],crossid,api_key];
    else{

        CFStringRef dateurlString = CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)lastUpdateTime,NULL,(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",kCFStringEncodingUTF8 );        
        
        
        apiurl=[NSString stringWithFormat:@"%@/x/%i/posts?updated_since=%@&token=%@",[APIHandler URL_API_ROOT],crossid,[(NSString *)dateurlString autorelease],api_key];
    }
    
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
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    exfeAppDelegate* app=(exfeAppDelegate*)[[UIApplication sharedApplication] delegate];

//    DBUtil *dbu=[DBUtil sharedManager];
//    NSString *lastUpdateTime=[dbu getLastEventUpdateTime];
    NSString *lastUpdateTime=[[NSUserDefaults standardUserDefaults] stringForKey:@"lastupdatetime"]; 

    NSError *error = nil;
    NSString *apiurl=nil;
    if(lastUpdateTime==nil)
        apiurl=[NSString stringWithFormat:@"%@/users/%i/x?token=%@",[APIHandler URL_API_ROOT],app.userid,api_key];
    else
    {
        CFStringRef dateurlString = CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)lastUpdateTime,NULL,(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",kCFStringEncodingUTF8 );        
        apiurl=[NSString stringWithFormat:@"%@/users/%i/x?updated_since=%@&token=%@",[APIHandler URL_API_ROOT],app.userid,[(NSString *)dateurlString autorelease] ,api_key];
    }
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiurl]];
    NSLog(@"api: %@",apiurl);
    [request setHTTPShouldHandleCookies:NO];
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (error)
    {
        NSLog(@"%@",error);
    }
    NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
//    NSString *saved_lastUpdateTime=[[NSUserDefaults standardUserDefaults] stringForKey:@"lastupdatetime"]; 
//
//    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSDate *lastUpdateTime_datetime = [dateFormat dateFromString:saved_lastUpdateTime]; 
//
//    NSDate *update_datetime = [dateFormat dateFromString:lastUpdateTime]; 
//    
//
//    lastUpdateTime_datetime=[update_datetime laterDate:lastUpdateTime_datetime];

//    [[NSUserDefaults standardUserDefaults] setObject:[dateFormat stringFromDate:lastUpdateTime_datetime]  forKey:@"lastupdatetime"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    [dateFormat release];
    [pool release];
//    [lastUpdateTime release];
    return responseString;
}

- (BOOL) regDeviceToken:(NSString*) token
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    exfeAppDelegate* app=(exfeAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSLog(@"set user token:%@",app.username);
    
    
    CFStringRef devicenameString = CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)[[UIDevice currentDevice] name],NULL,(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",kCFStringEncodingUTF8 );        

    NSString *post =[[NSString alloc] initWithFormat:@"devicetoken=%@&provider=iOSAPN&devicename=%@",token,[(NSString *)devicenameString autorelease]];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/users/%i/regdevicetoken?token=%@",[APIHandler URL_API_ROOT],app.userid,api_key]]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setHTTPShouldHandleCookies:NO];
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *responseString = [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"response %@",responseString);
    id jsonobj=[responseString JSONValue];
    
    id code=[[jsonobj objectForKey:@"meta"] objectForKey:@"code"];
    if([code isKindOfClass:[NSNumber class]] && [code intValue]==200)
    {
        if([[jsonobj objectForKey:@"response"] isKindOfClass:[NSDictionary class]])
        {
            
            if ([[[jsonobj objectForKey:@"response"] objectForKey:@"device_token"] isEqualToString:token])
            {
                [pool drain];
                return YES;     
            }
        }
    }
    [pool drain];
    return NO;
}

- (NSString*)getUpdate
{
    exfeAppDelegate* app=(exfeAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSLog(@"get User update:%@",app.username);
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *lastUpdateTime=[[NSUserDefaults standardUserDefaults] stringForKey:@"lastupdatetime"]; 


    if(lastUpdateTime==nil)
        lastUpdateTime=@"0000-00-00 00:00:00";

    CFStringRef dateurlString = CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)lastUpdateTime,NULL,(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",kCFStringEncodingUTF8 );        
    
    
    NSString *url=[NSString stringWithFormat:@"%@/users/%i/getupdate?updated_since=%@&token=%@",[APIHandler URL_API_ROOT],app.userid,[(NSString *)dateurlString autorelease],api_key];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSLog(@"%@",url);
    [request setHTTPShouldHandleCookies:NO];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",responseString);
    return responseString;    
}
- (NSString*)getEventById:(int)eventid
{
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/crosses/%i.json?api_key=%@",[APIHandler URL_API_ROOT],eventid,api_key]]];
    [request setHTTPShouldHandleCookies:NO];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    return responseString;    
}
- (NSString*)AddCommentById:(int)eventid comment:(NSString*)commenttext external_identity:(NSString*)external_identity
{
    NSString *post =[[NSString alloc] initWithFormat:@"external_identity=%@&content=%@",external_identity,commenttext];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/x/%i/posts?token=%@",[APIHandler URL_API_ROOT],eventid,api_key]]];
    
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
