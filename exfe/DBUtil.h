//
//  DBUtil.h
//  exfe
//
//  Created by huoju on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DBUtil : NSObject {
    
}
- (NSString*) DBPath;
- (void) updateEventWithid:(int)eventid event:(NSString*)eventjson;
- (NSString*) getEventWithid:(int)eventid;
- (NSArray*) getRecentEvent;
//- (NSMutableArray*)getTitleList;
//- (int) addnewzhstr:(NSString*)zh enstr:(NSString*)en;
//- (void) updaterowid:(int)rowid withzhstr:(NSString*)zh enstr:(NSString*)en;
//- (BOOL) deleterowid:(int)rowid;
//- (NSDictionary*)getContentWithID:(int)rowid;

@end
