//
//  APIHandler.h
//  exfe
//
//  Created by huoju on 4/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIHandler : NSObject {
    //NSMutableData *responseData;
    NSString *api_key;
    NSString *username;
    NSString *password;    
}

@property (retain,nonatomic) NSString *api_key;
@property (retain,nonatomic) NSString *username;
@property (retain,nonatomic) NSString *password;
+ (NSString*)URL_API_ROOT;
- (NSString*)checkUserLoginByUsername:(NSString*)email withPassword:(NSString*)passwd;
- (NSString*)getMeInfo;
- (NSString*)getUserEvents;
//- (id)getUserEvents;
- (NSString*)getUserNews;
- (NSString*)getEventById:(int)eventid;
- (NSString*)AddCommentById:(int)eventid comment:(NSString*)commenttext;
- (NSString*)getPostsWith:(int)crossid;



- (NSString*)sentRSVPWith:(int)eventid rsvp:(NSString*)rsvp;
- (BOOL) regDeviceToken:(NSString*) token;
@end
