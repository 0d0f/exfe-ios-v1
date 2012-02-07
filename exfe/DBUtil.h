//
//  DBUtil.h
//  exfe
//
//  Created by huoju on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "User.h"
#import "Cross.h"
#import "Activity.h"

@interface DBUtil : NSObject {

}
+ (id)sharedManager;
+ (NSString*) DBPath;
- (void) emptyDBCache;
- (void) emptyDBData;
+ (void) upgradeDB;
- (void) updateEventWithid:(int)eventid event:(NSString*)eventjson;
- (NSString*) getEventWithid:(int)eventid;
- (void) updateEventicalWithid:(int)eventid  identifier:(NSString*) eventIdentifier;
- (NSString*)getIdentifierWithid:(int)eventid;

- (void) updateEventobjWithid:(int)eventid event:(NSDictionary*)eventobj isnew:(BOOL)newflag;
- (void) updateCommentobjWithid:(int)eventid event:(NSArray*)commentdict;
- (void) updateInvitationobjWithid:(int)eventid event:(NSArray*)invitationdict;
- (void) updateUserobjWithid:(int)uid user:(NSDictionary*)userobj;
- (void) updateInvitationWithCrossId:(int)cross_id invitation:(NSDictionary*)invitationdict;
//- (void) updateActivityWithAction:(NSString*)action data:(NSString*)data time:(NSString*)time by_id:(int)by_id to_id:(int)to_id cross_id:(int)cross_id log_id:(int)log_id ;
- (void) updateActivityWithobj:(NSDictionary*)dict action:(NSString*)action cross_id:(int)cross_id;
- (NSMutableArray*) getRecentActivityFromLogid:(int)log_id start:(int)start num:(int)num;
- (NSDate*) updateCrossWithCrossId:(int)cross_id change:(NSDictionary*)changes lastupdatetime:(NSDate*)lastUpdateTime_datetime;

- (NSArray*) getCommentWithEventid:(int)eventid;
- (NSMutableArray*) getRecentEventObj;
- (NSArray*) getInvitationWithEventid:(int)eventid;
- (User*) getUserWithid:(int)userid;
- (NSString*) getLastEventUpdateTime;
- (NSString*) getLastCommentUpdateTimeWith:(int)eventid;
- (void) setCrossStatusWithCrossId:(int)cross_id status:(int)status;
- (Cross*)getCrossById:(int)cross_id;
@end
