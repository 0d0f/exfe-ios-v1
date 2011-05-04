//
//  DBUtil.m
//  exfe
//
//  Created by huoju on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DBUtil.h"
#import <sqlite3.h>


@implementation DBUtil

- (NSString*) DBPath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString *documentsDirectory = [paths objectAtIndex:0]; 
	NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"exfe.db"];
    
	NSString *olddbpath=[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"exfe.db"];
    
	if (![[NSFileManager defaultManager] isReadableFileAtPath:writableDBPath]) {
		
		if ([[NSFileManager defaultManager] copyItemAtPath:olddbpath toPath:writableDBPath error:NULL] != YES)
			
			NSAssert2(0, @"Fail to copy database from %@ to %@", olddbpath, writableDBPath);
		
	}
	
	return writableDBPath;
}
- (NSArray*) getRecentEvent
{
    const char *sql="SELECT eventjson from eventobject order by eventid desc limit 50;";
    NSMutableArray *eventlist=[[NSMutableArray alloc] initWithCapacity:50];

    NSString *dbpath=[self DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:dbpath];
	[fileManager release];
	int count=0;
	if(!success)
	{
		return 0;
	} 
	sqlite3 *database=nil;
	sqlite3_stmt *stm=nil;
	if(sqlite3_open([dbpath UTF8String], &database)==SQLITE_OK)
	{
		if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
		{
			//			sqlite3_bind_int(stm, 1, 1);  
			while(sqlite3_step(stm)== SQLITE_ROW)
			{
				
				NSString *eventjson=[NSString stringWithUTF8String:sqlite3_column_text(stm, 0)];
                
                [eventlist addObject:[eventjson JSONValue]];
			}
		}
		sqlite3_finalize(stm);
	}
	sqlite3_close(database);    
    return eventlist;
}

- (NSString*) getEventWithid:(int)eventid
{
    const char *sql="SELECT eventjson from eventobject where eventid=?;";

	NSString *dbpath=[self DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:dbpath];
	[fileManager release];
	int count=0;
	if(!success)
	{
		return 0;
	} 
	sqlite3 *database=nil;
	sqlite3_stmt *stm=nil;
	NSString *eventjson=nil;
    
	if(sqlite3_open([dbpath UTF8String], &database)==SQLITE_OK)
	{
		if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
		{
			sqlite3_bind_int(stm, 1, eventid);  
			while(sqlite3_step(stm)== SQLITE_ROW)
			{
				
				 eventjson=[NSString stringWithUTF8String:sqlite3_column_text(stm, 0)];
			}
		}
		sqlite3_finalize(stm);
	}
	sqlite3_close(database);	
	return eventjson;    
}
- (void) updateEventWithid:(int)eventid event:(NSString*)eventjson
{
	NSString *dbpath=[self DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:dbpath];
	[fileManager release];
	int count=0;
	if(!success)
	{
		return 0;
	} 
	sqlite3 *database=nil;
	sqlite3_stmt *stm=nil;
	if(sqlite3_open([dbpath UTF8String], &database)==SQLITE_OK)
	{
		const char *sql = "insert or replace into eventobject (eventid,eventjson) values(?,?)";
		if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
		{
//			sqlite3_bind_text(stm, 1, [zh UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(stm, 1, eventid);  
			sqlite3_bind_text(stm,2, [eventjson UTF8String], -1, SQLITE_TRANSIENT);
			if(sqlite3_step(stm)!= SQLITE_DONE)
//			{
//				rowid = sqlite3_last_insert_rowid(database);
//				//NSLog(@"rowid:%d",rowid);
//			}
//			else 
            {
				NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
			}
		}
		sqlite3_finalize(stm);
	}
	sqlite3_close(database);    
}

- (void)dealloc
{
    [super dealloc];
}

@end
