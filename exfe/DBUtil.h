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


@interface DBUtil : NSObject {

}
+ (id)sharedManager;
+ (NSString*) DBPath;
- (void) emptyDBCache;
- (void) updateEventWithid:(int)eventid event:(NSString*)eventjson;
- (NSString*) getEventWithid:(int)eventid;
- (void) updateEventicalWithid:(int)eventid  identifier:(NSString*) eventIdentifier;
- (NSString*)getIdentifierWithid:(int)eventid;

- (void) updateEventobjWithid:(int)eventid event:(NSDictionary*)eventobj;
- (void) updateCommentobjWithid:(int)eventid event:(NSArray*)commentdict;
- (void) updateInvitationobjWithid:(int)eventid event:(NSArray*)invitationdict;
- (void) updateUserobjWithid:(int)uid user:(NSDictionary*)userobj;
- (void) updateInvitationWithCrossId:(int)cross_id invitation:(NSDictionary*)invitationdict;
- (void) updateCrossWithCrossId:(int)cross_id change:(NSDictionary*)changes;

- (NSArray*) getCommentWithEventid:(int)eventid;
- (NSArray*) getRecentEventObj;
- (NSArray*) getInvitationWithEventid:(int)eventid;
- (User*) getUserWithid:(int)userid;
- (NSString*) getLastEventUpdateTime;
- (NSString*) getLastCommentUpdateTimeWith:(int)eventid;

@end
