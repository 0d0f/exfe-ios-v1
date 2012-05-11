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
    NSString *external_id;
}

@property (retain,nonatomic) NSString *api_key;
@property (retain,nonatomic) NSString *username;
@property (retain,nonatomic) NSString *password;
@property (retain,nonatomic) NSString *external_id;
+ (NSString*)URL_API_ROOT;
+ (NSString*)URL_API_DOMAIN;
- (NSString*)checkUserLoginByUsername:(NSString*)email withPassword:(NSString*)passwd;
- (NSString*)disconnectDeviceToken:(NSString*)device_token;
- (NSString*)getProfile;
- (NSString*)getUserEvents;
- (NSString*)getUpdate:(BOOL)ignore_time;
- (NSString*)getEventById:(int)eventid;
- (NSString*) getCrossesByIdList:(NSString*)idlist;
- (NSString*)AddCommentById:(int)eventid comment:(NSString*)commenttext external_identity:(NSString*)external_identity;
- (NSString*)getPostsWith:(int)crossid;

- (NSString*)sentRSVPWith:(int)eventid rsvp:(NSString*)rsvp;
- (BOOL) regDeviceToken:(NSString*) token;
@end
