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
@synthesize external_id;

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
    self.external_id=app.external_id;
    //NSLog(@"username globe:%@",app.username);

    return self;
}

+ (NSString*)URL_API_ROOT {
//	return @"http://exfeapi.dlol.us/v1";    
	return @"https://www.exfe.com/v1";        
//    return @"http://api.local.exfe.com/v1";        
}

+ (NSString*)URL_API_DOMAIN {
//	return @"http://exfeapi.dlol.us";    
    return @"https://www.exfe.com";
//    return @"http://api.local.exfe.com";    
}

- (NSString*)sentRSVPWith:(int)eventid rsvp:(NSString*)rsvp
{
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/x/%u/%@?token=%@",[APIHandler URL_API_ROOT],eventid,rsvp,api_key]]];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];

    [request setHTTPShouldHandleCookies:NO];
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    return responseString;    
}
- (NSString*)checkUserLoginByUsername:(NSString*)email withPassword:(NSString*)passwd
{
    NSString *post =[[NSString alloc] initWithFormat:@"user=%@&password=%@",email,passwd];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    [post release];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",[APIHandler URL_API_ROOT],@"users/login"]]];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];

    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];

    [request setHTTPShouldHandleCookies:NO];

    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    return responseString;
}

- (NSString*)getProfile
{
    exfeAppDelegate* app=(exfeAppDelegate*)[[UIApplication sharedApplication] delegate];

    NSString *url=[NSString stringWithFormat:@"%@/users/%i/getprofile?token=%@",[APIHandler URL_API_ROOT],app.userid,api_key];
//    NSLog(@"%@",url);
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [request setHTTPShouldHandleCookies:NO];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    return responseString;    

}

- (NSString*)getPostsWith:(int)crossid
{
    NSString *identity_id=[[NSUserDefaults standardUserDefaults] stringForKey:@"device_identity_id"]; 
    DBUtil *dbu=[DBUtil sharedManager];
    NSString *lastUpdateTime=[dbu getLastCommentUpdateTimeWith:crossid];

    NSError *error = nil;
    NSString *apiurl=nil;
    if(lastUpdateTime==nil)
        apiurl=[NSString stringWithFormat:@"%@/x/%i/posts?token=%@",[APIHandler URL_API_ROOT],crossid,api_key];
    else{

        CFStringRef dateurlString = CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)lastUpdateTime,NULL,(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",kCFStringEncodingUTF8 );        
        NSString *datestr = [NSString stringWithString: (NSString *)dateurlString];
        apiurl=[NSString stringWithFormat:@"%@/x/%i/posts?updated_since=%@&token=%@&ddid=%@",[APIHandler URL_API_ROOT],crossid,datestr,api_key,identity_id];
        CFRelease(dateurlString);
    }
    
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiurl]];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];

    [request setHTTPShouldHandleCookies:NO];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (error)
    {
//        NSLog(@"%@",error);
    }
    NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    return responseString;       
}

- (NSString*)getUserEvents
{
//    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    exfeAppDelegate* app=(exfeAppDelegate*)[[UIApplication sharedApplication] delegate];

    NSString *lastUpdateTime=[[NSUserDefaults standardUserDefaults] stringForKey:@"lastupdatetime"]; 
    NSError *error = nil;
    NSString *apiurl=nil;
    if(lastUpdateTime==nil)
        apiurl=[NSString stringWithFormat:@"%@/users/%i/x?token=%@",[APIHandler URL_API_ROOT],app.userid,api_key];
    else {
        CFStringRef dateurlString = CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)lastUpdateTime,NULL,(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",kCFStringEncodingUTF8 );
        NSString *datestr = [NSString stringWithString: (NSString *)dateurlString];
        apiurl=[NSString stringWithFormat:@"%@/users/%i/x?updated_since=%@&token=%@",[APIHandler URL_API_ROOT],app.userid,datestr,api_key];
        CFRelease(dateurlString);
    }
//    NSLog(@"api:%@",apiurl);
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiurl]];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];

    [request setHTTPShouldHandleCookies:NO];
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    return responseString;
}

- (BOOL) regDeviceToken:(NSString*) token
{
//    NSLog(@"token:%@",token);
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    exfeAppDelegate* app=(exfeAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    
    CFStringRef devicenameString = CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)[[UIDevice currentDevice] name],NULL,(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",kCFStringEncodingUTF8 );        

    NSString *devicenamestr = [NSString stringWithString: (NSString *)devicenameString];
    NSString *post =[[NSString alloc] initWithFormat:@"devicetoken=%@&provider=iOSAPN&devicename=%@",token,devicenamestr];
    CFRelease(devicenameString);
    
//    NSLog(@"%@",post);
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/users/%i/regdevicetoken?token=%@",[APIHandler URL_API_ROOT],app.userid,api_key]]];
//    NSLog(@"%@",request);
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];

    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setHTTPShouldHandleCookies:NO];
    [post release];

    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *responseString = [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] autorelease];
    id jsonobj=[responseString JSONValue];
    
    id code=[[jsonobj objectForKey:@"meta"] objectForKey:@"code"];
    if([code isKindOfClass:[NSNumber class]] && [code intValue]==200)
    {
        if([[jsonobj objectForKey:@"response"] isKindOfClass:[NSDictionary class]])
        {
            
            if ([[[jsonobj objectForKey:@"response"] objectForKey:@"device_token"] isEqualToString:token])
            {
                NSString *identity_id=[[jsonobj objectForKey:@"response"] objectForKey:@"identity_id"];
                [[NSUserDefaults standardUserDefaults] setObject:identity_id  forKey:@"device_identity_id"];
                [pool drain];
                return YES;     
            }
        }
    }
    [pool drain];
    return NO;
}

- (NSString*)getUpdate:(BOOL)ignore_time
{
    exfeAppDelegate* app=(exfeAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *lastUpdateTime=[[NSUserDefaults standardUserDefaults] stringForKey:@"lastupdatetime"]; 

    NSString *identity_id=[[NSUserDefaults standardUserDefaults] stringForKey:@"device_identity_id"]; 

    if(lastUpdateTime==nil)
        lastUpdateTime=@"0000-00-00 00:00:00";

    if(ignore_time==YES)
        lastUpdateTime=@"0000-00-00 00:00:00";
    //TOFIX:temp test hack
    
//    lastUpdateTime=@"2012-03-29 07:44:15";
    CFStringRef dateurlString = CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)lastUpdateTime,NULL,(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",kCFStringEncodingUTF8 );        
    
    NSString *datestr = [NSString stringWithString: (NSString *)dateurlString];
    NSString *url=[NSString stringWithFormat:@"%@/users/%i/getupdate?updated_since=%@&token=%@&ddid=%@",[APIHandler URL_API_ROOT],app.userid,datestr,api_key,identity_id];
//    NSLog(@"url:%@",url);
    CFRelease(dateurlString);
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];

    [request setHTTPShouldHandleCookies:NO];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    return responseString;    
}
- (NSString*)getEventById:(int)eventid
{
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/crosses/%i.json?api_key=%@",[APIHandler URL_API_ROOT],eventid,api_key]]];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];

    [request setHTTPShouldHandleCookies:NO];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    return responseString;    
}
- (NSString*)AddCommentById:(int)eventid comment:(NSString*)commenttext external_identity:(NSString*)external_identity
{
    NSString *post =[[NSString alloc] initWithFormat:@"external_identity=%@&content=%@&via=iOS",external_identity,commenttext];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    [post release];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/x/%i/posts?token=%@",[APIHandler URL_API_ROOT],eventid,api_key]]];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];

    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [request setHTTPShouldHandleCookies:NO];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
//    NSLog(@"%@",responseString);
    return responseString;    
}
- (NSString*) getCrossesByIdList:(NSString*)idlist
{
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/x/list?ids=%@&token=%@",[APIHandler URL_API_ROOT],idlist,api_key]]];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];

    [request setHTTPShouldHandleCookies:NO];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    return responseString;    
    
}
- (NSString*)disconnectDeviceToken:(NSString*)device_token
{
    exfeAppDelegate* app=(exfeAppDelegate*)[[UIApplication sharedApplication] delegate];

    NSString *post =[[NSString alloc] initWithFormat:@"device_token=%@",device_token];
//    NSLog(@"%@",post);
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    [post release];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    NSString *url=[NSString stringWithFormat:@"%@/users/%i/logout?token=%@",[APIHandler URL_API_ROOT],app.userid,api_key];
//    NSLog(@"%@",url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [request setHTTPShouldHandleCookies:NO];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    return responseString;    
}
- (void)dealloc
{
    [username release];
    [password release];
    [api_key release];
    [super dealloc];
}

@end
