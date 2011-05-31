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
- (void) updateEventWithid:(int)eventid event:(NSString*)eventjson;
- (NSString*) getEventWithid:(int)eventid;
- (NSArray*) getRecentEvent;
- (void) updateEventicalWithid:(int)eventid  identifier:(NSString*) eventIdentifier;
- (NSString*)getIdentifierWithid:(int)eventid;
//- (NSMutableArray*)getTitleList;
//- (int) addnewzhstr:(NSString*)zh enstr:(NSString*)en;
//- (void) updaterowid:(int)rowid withzhstr:(NSString*)zh enstr:(NSString*)en;
//- (BOOL) deleterowid:(int)rowid;
//- (NSDictionary*)getContentWithID:(int)rowid;

@end
