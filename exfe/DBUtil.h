//
//  DBUtil.h
//  exfe
//
//  Created by huoju on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

static sqlite3 *database;

@interface DBUtil : NSObject {
    NSString *dbpath;
}
+ (id)sharedManager;
+ (NSString*) DBPath;
- (void) emptyDBCache;
- (void) updateEventWithid:(int)eventid event:(NSString*)eventjson;
- (NSString*) getEventWithid:(int)eventid;
- (NSArray*) getRecentEvent;
- (void) updateEventicalWithid:(int)eventid  identifier:(NSString*) eventIdentifier;
- (NSString*)getIdentifierWithid:(int)eventid;

- (void) updateEventobjWithid:(int)eventid event:(NSDictionary*)eventobj;
- (void) updateCommentobjWithid:(int)eventid event:(NSArray*)commentdict;
- (NSArray*) getRecentEventObj;
@end
