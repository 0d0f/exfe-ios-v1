//
//  DBUtil.m
//  exfe
//
//  Created by huoju on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DBUtil.h"
#import "Event.h"
#import "Comment.h"

@implementation DBUtil
static id sharedManager = nil;

+ (id)sharedManager {
    @synchronized(self)    
    {
    if (sharedManager == nil) {
        sharedManager = [[self alloc] init];
        NSString *dbpath=[DBUtil DBPath];
        sqlite3_open([dbpath UTF8String], &database);  
    }
    }
    return sharedManager;
}
- (void) emptyDBCache
{
	NSString *dbpath=[DBUtil DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:dbpath];
	[fileManager release];
//	int count=0;
	if(!success)
	{
		return 0;
	} 
    sqlite3_stmt *stm=nil;
    const char *sql = "delete from eventobject;";
    if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
    {
//        sqlite3_bind_int(stm, 1, eventid);  
//        sqlite3_bind_text(stm,2, [eventjson UTF8String], -1, SQLITE_TRANSIENT);
        if(sqlite3_step(stm)== SQLITE_DONE)
        {
            //				rowid = sqlite3_last_insert_rowid(database);
            //				//NSLog(@"rowid:%d",rowid);
        }
        else 
        {
            NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
        }
    }
    sqlite3_finalize(stm);    
}


+ (NSString*) DBPath
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

    NSString *dbpath=[DBUtil DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:dbpath];
	[fileManager release];
	if(!success)
	{
		return 0;
	} 
	sqlite3_stmt *stm=nil;

		if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
		{
			//			sqlite3_bind_int(stm, 1, 1);  
			while(sqlite3_step(stm)== SQLITE_ROW)
			{
				
				NSString *eventjson=[NSString stringWithUTF8String:sqlite3_column_text(stm, 0)];
                id eventobj=[eventjson JSONValue];
                if (eventobj !=nil)
                    [eventlist addObject:eventobj];
			}
		}
		sqlite3_finalize(stm);
    return eventlist;
}
- (NSArray*) getRecentEventObj
{
    const char *sql="SELECT id,title,description,code,begin_at,end_at,duration,venue,creator_id,created_at,updated_at,state from events order by updated_at desc limit 20;";
    NSMutableArray *eventlist=[[NSMutableArray alloc] initWithCapacity:50];
    
    NSString *dbpath=[DBUtil DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:dbpath];
	[fileManager release];
	if(!success)
	{
		return 0;
	} 
	sqlite3_stmt *stm=nil;
    
    if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
    {
        //			sqlite3_bind_int(stm, 1, 1);  
        while(sqlite3_step(stm)== SQLITE_ROW)
        {   Event *eventobj=[[Event alloc]init];
            eventobj.id=sqlite3_column_int(stm, 0);
            eventobj.title=[NSString stringWithUTF8String:sqlite3_column_text(stm, 1)];
            eventobj.description=[NSString stringWithUTF8String:sqlite3_column_text(stm, 2)];
            eventobj.code=[NSString stringWithUTF8String:sqlite3_column_text(stm, 3)];
            eventobj.begin_at=[NSString stringWithUTF8String:sqlite3_column_text(stm, 4)];
            eventobj.end_at=[NSString stringWithUTF8String:sqlite3_column_text(stm, 5)];
            eventobj.duration=sqlite3_column_int(stm, 6);
            eventobj.venue=[NSString stringWithUTF8String:sqlite3_column_text(stm, 7)];
            eventobj.creator_id=sqlite3_column_int(stm, 8);
            eventobj.created_at=[NSString stringWithUTF8String:sqlite3_column_text(stm, 9)];
            eventobj.updated_at=[NSString stringWithUTF8String:sqlite3_column_text(stm, 10)];
            eventobj.state=[NSString stringWithUTF8String:sqlite3_column_text(stm, 11)];
            [eventlist addObject:eventobj];
        }
    }
    sqlite3_finalize(stm);
    return eventlist;   
}
- (NSString*) getEventWithid:(int)eventid
{
    const char *sql="SELECT eventjson from eventobject where eventid=?;";

	NSString *dbpath=[DBUtil DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:dbpath];
	[fileManager release];
	int count=0;
	if(!success)
	{
		return 0;
	} 
	sqlite3_stmt *stm=nil;
	NSString *eventjson=nil;
    
		if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
		{
			sqlite3_bind_int(stm, 1, eventid);  
			while(sqlite3_step(stm)== SQLITE_ROW)
			{
				
				 eventjson=[NSString stringWithUTF8String:sqlite3_column_text(stm, 0)];
			}
		}
		sqlite3_finalize(stm);
	return eventjson;    
}
- (void) updateEventWithid:(int)eventid event:(NSString*)eventjson
{
	NSString *dbpath=[DBUtil DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:dbpath];
	[fileManager release];
	int count=0;
	if(!success)
	{
		return 0;
	} 
        sqlite3_stmt *stm=nil;
		const char *sql = "insert or replace into eventobject (eventid,eventjson) values(?,?)";
		if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
		{
            sqlite3_bind_int(stm, 1, eventid);  
			sqlite3_bind_text(stm,2, [eventjson UTF8String], -1, SQLITE_TRANSIENT);
			if(sqlite3_step(stm)== SQLITE_DONE)
			{
//				rowid = sqlite3_last_insert_rowid(database);
//				//NSLog(@"rowid:%d",rowid);
			}
			else 
            {
				NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
			}
		}
		sqlite3_finalize(stm);
}

- (void) updateCommentobjWithid:(int)eventid event:(NSArray*)commentdict
{
	NSString *dbpath=[DBUtil DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:dbpath];
	[fileManager release];
	if(!success)
	{
		return 0;
	} 
    sqlite3_stmt *stm=nil;
    const char *sql = "insert or replace into comments (id,eventid,comment,user_id,userjson,created_at,updated_at) values(?,?,?,?,?,?,?)";
    for(int i=0;i<[commentdict count];i++)
    {

    if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
    {
            
            Comment *commentobj=[Comment initWithDict:[commentdict objectAtIndex:i] EventID:eventid];
            sqlite3_bind_int(stm, 1,commentobj.id ); 
            sqlite3_bind_int(stm, 2, eventid); 
            sqlite3_bind_text(stm,3,[commentobj.comment UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(stm,4, commentobj.user_id);
            sqlite3_bind_text(stm,5,[commentobj.userjson UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(stm,6,[commentobj.created_at UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(stm,7,[commentobj.updated_at UTF8String], -1, SQLITE_TRANSIENT);
            
            if(sqlite3_step(stm)== SQLITE_DONE)
            {
                
            }
            else 
            {
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
            }            


    }
    else 
    {
        NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
    }
    }

    sqlite3_finalize(stm); 
}

- (void) updateEventobjWithid:(int)eventid event:(NSDictionary*)eventobj
{
    Event *evento=[Event initWithDict:eventobj];
    if( ![evento.state isEqualToString:@"published"])
        return;
	NSString *dbpath=[DBUtil DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:dbpath];
	[fileManager release];
	if(!success)
	{
		return 0;
	} 
    sqlite3_stmt *stm=nil;
    const char *sql = "insert or replace into events (id,title,description,code,begin_at,end_at,duration,venue,creator_id,created_at,updated_at,state) values(?,?,?,?,?,?,?,?,?,?,?,?)";
    
    if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
    {
        sqlite3_bind_int(stm, 1, eventid); 
        sqlite3_bind_text(stm,2,[evento.title UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stm,3, [evento.description UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stm,4, [evento.code UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stm,5, [evento.begin_at UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stm,6, [evento.end_at UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(stm,7, evento.duration);
        sqlite3_bind_text(stm,8, [evento.venue UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(stm,9, evento.creator_id);
        sqlite3_bind_text(stm,10, [evento.created_at UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stm,11, [evento.updated_at UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stm,12, [evento.state UTF8String], -1, SQLITE_TRANSIENT);
        
        
        
        if(sqlite3_step(stm)== SQLITE_DONE)
        {
            //				rowid = sqlite3_last_insert_rowid(database);
            //				//NSLog(@"rowid:%d",rowid);
        }
        else 
        {
            NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
        }
    }
    else 
    {
        NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
    }
    sqlite3_finalize(stm);    
}
- (void) updateEventicalWithid:(int)eventid  identifier:(NSString*) eventIdentifier
{
	NSString *dbpath=[DBUtil DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:dbpath];
	[fileManager release];
	int count=0;
	if(!success)
	{
		return 0;
	} 
    sqlite3_stmt *stm=nil;
    const char *sql = "insert or replace into eventical (eventid,identifier) values(?,?)";
    if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
    {
        sqlite3_bind_int(stm, 1, eventid);  
        sqlite3_bind_text(stm,2,  [eventIdentifier UTF8String], -1, SQLITE_TRANSIENT);
        if(sqlite3_step(stm)== SQLITE_DONE)
        {
        }
        else 
        {
            NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
        }
    }
    sqlite3_finalize(stm);
}
- (NSString*)getIdentifierWithid:(int)eventid
{
    const char *sql="SELECT identifier from eventical where eventid=?;";
    
	NSString *dbpath=[DBUtil DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:dbpath];
	[fileManager release];
	int count=0;
	if(!success)
	{
		return 0;
	} 
	sqlite3_stmt *stm=nil;
	NSString *identifier=nil;
    
    if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
    {
        sqlite3_bind_int(stm, 1, eventid);  
        while(sqlite3_step(stm)== SQLITE_ROW)
        {
            
            identifier=[NSString stringWithUTF8String:sqlite3_column_text(stm, 0)];
        }
    }
    sqlite3_finalize(stm);
	return identifier;     
}
- (void)dealloc
{
    sqlite3_close(database); 
    [super dealloc];
}

@end
