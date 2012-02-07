//
//  DBUtil.m
//  exfe
//
//  Created by huoju on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DBUtil.h"
#import "Cross.h"
#import "Comment.h"
#import "Invitation.h"
#import "User.h"
#import "Activity.h"
#import "NSObject+SBJson.h"

@implementation DBUtil
static id sharedManager = nil;
static NSString *dbpath;
static sqlite3 *database;



+ (id)sharedManager {
    @synchronized(self)    
    {
    if (sharedManager == nil) {
        database=nil;
        sharedManager = [[self alloc] init];
        NSString *dbpath=[DBUtil DBPath];
        NSLog(@"dbpath:%@",dbpath);
        sqlite3_open([dbpath UTF8String], &database);  
    }
    }
    return sharedManager;
}

+ (void) upgradeDB
{
	NSString *dbpath=[DBUtil DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:dbpath];
	if(!success)
	{
		return;
	} 
    sqlite3_stmt *stm=nil;
    const char *sql = "select time_type from crosses where id=1;";
    int result=sqlite3_prepare_v2(database, sql, -1, &stm, NULL);
    if(result==SQLITE_OK)
    {
    }
    else
    {
        const char *upgradesql = "ALTER TABLE  `crosses` ADD  `time_type` INT NOT NULL DEFAULT  '0';";
        if(sqlite3_prepare_v2(database, upgradesql, -1, &stm, NULL)==SQLITE_OK)
        {
            if(sqlite3_step(stm)== SQLITE_DONE)
            {
                
            }
            else 
            {
                NSAssert1(0, @"Error while upgrade db. '%s'", sqlite3_errmsg(database));
            }
        }

    }
    sqlite3_finalize(stm);     
}
- (void) emptyDBData
{
	NSString *dbpath=[DBUtil DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:dbpath];
	if(!success)
	{
		return;
	} 
    sqlite3_stmt *stm=nil;
    const char *sql = "delete from comments;";
    if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
    {
        sqlite3_step(stm);
    }
    sql = "delete from cross_changed;";
    if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
    {
        sqlite3_step(stm);
    }
    sql = "delete from crosses;";
    if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
    {
        sqlite3_step(stm);
    }
    sql = "delete from eventical;";
    if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
    {
        sqlite3_step(stm);
    }
    sql = "delete from invitations;";
    if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
    {
        sqlite3_step(stm);
    }
    sql = "delete from users;";
    if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
    {
        sqlite3_step(stm);
    }
    sqlite3_finalize(stm);       
}
- (void) emptyDBCache
{
	NSString *dbpath=[DBUtil DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:dbpath];
	if(!success)
	{
		return;
	} 
    sqlite3_stmt *stm=nil;
    const char *sql = "delete from eventobject;";
    if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
    {
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


+ (NSString*) DBPath
{
    @synchronized(self)    
    {

    if(dbpath==nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
        NSString *documentsDirectory = [paths objectAtIndex:0]; 
        NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"exfe.db"];
    
        NSString *olddbpath=[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"exfe.db"];
    
        if (![[NSFileManager defaultManager] isReadableFileAtPath:writableDBPath]) {
		
            if ([[NSFileManager defaultManager] copyItemAtPath:olddbpath toPath:writableDBPath error:NULL] != YES)
			
			NSAssert2(0, @"Fail to copy database from %@ to %@", olddbpath, writableDBPath);
		
	}
	dbpath=[writableDBPath copy];
    }
    }
	return dbpath;
}
- (void) updateInvitationWithCrossId:(int)cross_id invitation:(NSDictionary*)invitationdict
{
	NSString *dbpath=[DBUtil DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:dbpath];
	[fileManager release];
	if(!success)
	{
		return;
	} 
    Invitation *invitationobj=[Invitation initWithDict:invitationdict EventID:cross_id];

    sqlite3_stmt *stm=nil;
    const char *selectsql = "select id from invitations where id=? and updated_at>?;";
    if(sqlite3_prepare_v2(database, selectsql, -1, &stm, NULL)==SQLITE_OK)
    {
        sqlite3_bind_int(stm, 1, invitationobj.id);  
        sqlite3_bind_text(stm,2,[invitationobj.updated_at UTF8String], -1, SQLITE_TRANSIENT);
        
        if(sqlite3_step(stm) != SQLITE_ROW)
        {
            const char *sql = "insert or replace into invitations (id,eventid,username,provider,state,avatar_file_name,user_id,identity_id,updated_at) values(?,?,?,?,?,?,?,?,?)";
            if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
            {
                sqlite3_bind_int(stm, 1,invitationobj.id ); 
                sqlite3_bind_int(stm, 2, cross_id); 
                sqlite3_bind_text(stm,3,[invitationobj.username UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(stm,4,[invitationobj.provider UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_int(stm,5,invitationobj.state);
                sqlite3_bind_text(stm,6,[invitationobj.avatar UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_int(stm, 7,invitationobj.user_id ); 
                sqlite3_bind_int(stm, 8,invitationobj.identity_id ); 
                sqlite3_bind_text(stm,9,[invitationobj.updated_at UTF8String], -1, SQLITE_TRANSIENT);
                
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
    }
    sqlite3_finalize(stm);     
//    [self setCrossStatusWithCrossId:cross_id status:1];
 
}
- (NSDate*) updateCrossWithCrossId:(int)cross_id change:(NSDictionary*)changes lastupdatetime:(NSDate*)lastUpdateTime_datetime
{
	NSString *dbpath=[DBUtil DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:dbpath];
	[fileManager release];
	if(!success)
	{
		return 0;
	} 
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSArray *keys=[(NSDictionary*)changes allKeys];
    sqlite3_stmt *stm=nil;
    const char *selectsql = "select * from cross_changed where cross_id_field_key=? and updated_at>?;";

    if(sqlite3_prepare_v2(database, selectsql, -1, &stm, NULL)==SQLITE_OK)
    {
        for (int idx=0;idx<[keys count];idx++)
        {
            NSString *key=[keys objectAtIndex:idx];

            id changeobj=[(NSDictionary*)changes objectForKey:key];
            NSString *time=[changeobj objectForKey:@"time"];
            
            sqlite3_bind_text(stm,1,[[NSString stringWithFormat:@"%i_%@",cross_id,key] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(stm,2,[time UTF8String], -1, SQLITE_TRANSIENT);

            if(sqlite3_step(stm) != SQLITE_ROW)
            {
                const char *sql = "insert or replace into cross_changed (cross_id_field_key,updated_at) values(?,?);";
                if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
                {
                    sqlite3_bind_text(stm,1,[[NSString stringWithFormat:@"%i_%@",cross_id,key] UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(stm,2,[time UTF8String], -1, SQLITE_TRANSIENT);
                    
                    if(sqlite3_step(stm)== SQLITE_DONE)
                    {
                        const char *updatesql =[[NSString stringWithFormat:@"update crosses set %@=? where id=?",key] UTF8String];
                        if(sqlite3_prepare_v2(database, updatesql, -1, &stm, NULL)==SQLITE_OK)
                        {
                            NSString *newvalue=[changeobj objectForKey:@"new_value"];

                            sqlite3_bind_text(stm,1,[newvalue UTF8String], -1, SQLITE_TRANSIENT);
                            sqlite3_bind_int(stm, 2, cross_id); 
                            if(sqlite3_step(stm)== SQLITE_DONE)
                            {
                                NSDate *update_datetime = [dateFormat dateFromString:time]; 
                                lastUpdateTime_datetime=[update_datetime laterDate:lastUpdateTime_datetime];
                            }
                            else 
                            {
                                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
                            }            

                        }

                        
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
            
        }
    }
    [dateFormat release];
    sqlite3_finalize(stm);     
//    [self setCrossStatusWithCrossId:cross_id status:1];

    return lastUpdateTime_datetime;
}

- (void) updateInvitationobjWithid:(int)eventid event:(NSArray*)invitationdict
{
	NSString *dbpath=[DBUtil DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:dbpath];
	[fileManager release];
	if(!success)
	{
		return;
	} 
    sqlite3_stmt *stm=nil;
    const char *sql = "insert or replace into invitations (id,eventid,username,provider,state,avatar_file_name,identity_id,user_id,updated_at) values(?,?,?,?,?,?,?,?,?)";
    for(int i=0;i<[invitationdict count];i++)
    {
        
        if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
        {
            Invitation *invitationobj=[Invitation initWithDict:[invitationdict objectAtIndex:i] EventID:eventid];
            sqlite3_bind_int(stm, 1,invitationobj.id ); 
            sqlite3_bind_int(stm, 2, eventid); 
            sqlite3_bind_text(stm,3,[invitationobj.username UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(stm,4,[invitationobj.provider UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(stm,5,invitationobj.state);
            sqlite3_bind_text(stm,6,[invitationobj.avatar UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(stm, 7,invitationobj.identity_id ); 
            sqlite3_bind_int(stm, 8,invitationobj.user_id ); 
            sqlite3_bind_text(stm,9,[invitationobj.updated_at UTF8String], -1, SQLITE_TRANSIENT);
            
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
- (NSArray*) getCommentWithEventid:(int)eventid
{
    
    const char *sql="SELECT `id` ,`eventid`,`comment`,`user_id`,`userjson`,`created_at`,`updated_at` from comments where eventid=? order by id desc limit 20;";
    NSMutableArray *commentlist=[[NSMutableArray alloc] initWithCapacity:50];
    
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
        sqlite3_bind_int(stm, 1, eventid);  

        while(sqlite3_step(stm)== SQLITE_ROW)
        {   Comment *commentobj=[[Comment alloc]init];
            commentobj.id=sqlite3_column_int(stm, 0);
            commentobj.eventid=sqlite3_column_int(stm, 1);
            commentobj.comment =
            [[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 2)] stringByTrimmingCharactersInSet:
             [NSCharacterSet whitespaceAndNewlineCharacterSet]];            
            commentobj.user_id=sqlite3_column_int(stm, 3);
            char* userjson=(char*)sqlite3_column_text(stm, 4);
            if(userjson!=nil)
                commentobj.userjson=[NSString stringWithUTF8String:userjson];
            commentobj.created_at=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 5)];
            commentobj.updated_at=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 6)];
            if(commentobj.comment!=nil && ![commentobj.comment isEqualToString:@""])
            [commentlist addObject:commentobj];
        }
    }
    sqlite3_finalize(stm);
    return commentlist;    
}
//- (NSArray*) getRecentEvent
//{
//    const char *sql="SELECT eventjson from eventobject order by eventid desc limit 50;";
//    NSMutableArray *eventlist=[[NSMutableArray alloc] initWithCapacity:50];
//
//    NSString *dbpath=[DBUtil DBPath];
//	NSFileManager *fileManager=[NSFileManager defaultManager];
//	BOOL success=[fileManager fileExistsAtPath:dbpath];
//	[fileManager release];
//	if(!success)
//	{
//		return 0;
//	} 
//	sqlite3_stmt *stm=nil;
//
//		if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
//		{
//			//			sqlite3_bind_int(stm, 1, 1);  
//			while(sqlite3_step(stm)== SQLITE_ROW)
//			{
//				
//				NSString *eventjson=[NSString stringWithUTF8String:（sqlite3_column_text(stm, 0)];
//                id eventobj=[eventjson JSONValue];
//                if (eventobj !=nil)
//                    [eventlist addObject:eventobj];
//			}
//		}
//		sqlite3_finalize(stm);
//    return eventlist;
//}
- (NSMutableArray*) getRecentEventObj
{
    const char *sql="SELECT id,title,description,code,begin_at,end_at,duration,place_line1,place_line2,creator_id,created_at,updated_at,state,flag,time_type from crosses order by updated_at desc limit 20;";
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
        {   Cross *eventobj=[[[Cross alloc]init] autorelease];
            eventobj.id=sqlite3_column_int(stm, 0);
            eventobj.title=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 1)];
            eventobj.description=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 2)];
            eventobj.code=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 3)];
            eventobj.begin_at=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 4)];
            eventobj.end_at=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 5)];
            eventobj.duration=sqlite3_column_int(stm, 6);
            if((char*)sqlite3_column_text(stm, 7)!=nil)
                eventobj.place_line1=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 7)];
            if((char*)sqlite3_column_text(stm, 8)!=nil)
                eventobj.place_line2=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 8)];
            eventobj.creator_id=sqlite3_column_int(stm, 9);
            eventobj.created_at=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 10)];
            eventobj.updated_at=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 11)];
            eventobj.state=sqlite3_column_int(stm, 12);
            eventobj.flag = sqlite3_column_int(stm, 13);
            eventobj.time_type = sqlite3_column_int(stm, 14);
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
				
				 eventjson=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 0)];
			}
		}
		sqlite3_finalize(stm);
	return eventjson;    
}
- (void) updateEventWithid:(int)eventid event:(NSString*)eventjson
{
	NSString *_dbpath=[DBUtil DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:_dbpath];
	[fileManager release];
	if(!success)
	{
		return ;
	} 
        sqlite3_stmt *stm=nil;
		const char *sql = "insert or replace into eventobject (eventid,eventjson) values(?,?)";
		if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
		{
            sqlite3_bind_int(stm, 1, eventid);  
			sqlite3_bind_text(stm,2, [eventjson UTF8String], -1, SQLITE_TRANSIENT);
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

- (NSArray*) getInvitationWithEventid:(int)eventid
{
    const char *sql="SELECT `id` ,`username`,`provider`,`state`,`avatar_file_name`,`identity_id`,`user_id` from invitations where eventid=? order by id ;";
    NSMutableArray *invitationlist=[[NSMutableArray alloc] initWithCapacity:50];
    
    NSString *sqldbpath=[DBUtil DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:sqldbpath];
	[fileManager release];
	if(!success)
	{
		return 0;
	} 
	sqlite3_stmt *stm=nil;
    if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
    {
        sqlite3_bind_int(stm, 1, eventid);  
        
        while(sqlite3_step(stm)== SQLITE_ROW)
        {   
            Invitation *invitationobj=[[Invitation alloc]init];
            invitationobj.id=sqlite3_column_int(stm, 0);
            if((char*)sqlite3_column_text(stm, 1)!=nil)
                invitationobj.username=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 1)];
            if((char*)sqlite3_column_text(stm, 2)!=nil)
                invitationobj.provider=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 2)];
            invitationobj.state=sqlite3_column_int(stm, 3);
            invitationobj.avatar=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 4)];
            invitationobj.identity_id=sqlite3_column_int(stm, 5);
            invitationobj.user_id=sqlite3_column_int(stm, 6);
            [invitationlist addObject:invitationobj];
        }
    }
    else 
    {
        NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
    }            
    
    sqlite3_finalize(stm);
    return invitationlist;      
}
- (void) setCrossStatusWithCrossId:(int)cross_id status:(int)status
{
	NSString *dbpath=[DBUtil DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:dbpath];
	[fileManager release];
	if(!success)
	{
		return;
	} 
    sqlite3_stmt *stm=nil;
    const char *sql = "update crosses set flag=? where id=?";
    if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
    {
        sqlite3_bind_int(stm, 1,status ); 
        sqlite3_bind_int(stm, 2,cross_id ); 
        if(sqlite3_step(stm)== SQLITE_DONE)
        {
            
        }
        else 
        {
            NSAssert1(0, @"Error while set cross status. '%s'", sqlite3_errmsg(database));
        }            

    }
    
    
}
- (void) updateCommentobjWithid:(int)eventid event:(NSArray*)commentdict
{
	NSString *dbpath=[DBUtil DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:dbpath];
	[fileManager release];
	if(!success)
	{
		return;
	} 
    sqlite3_stmt *stm=nil;
    const char *sql = "insert or replace into comments (id,eventid,comment,user_id,userjson,created_at,updated_at) values(?,?,?,?,?,?,?)";
    for(int i=0;i<[commentdict count];i++)
    {
    Comment *commentobj=[Comment initWithDict:[commentdict objectAtIndex:i] EventID:eventid];
    if(![commentobj.comment isEqualToString:@""])
    if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
    {
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
//    [self setCrossStatusWithCrossId:eventid status:1];
}

- (void) updateEventobjWithid:(int)eventid event:(NSDictionary*)eventobj isnew:(BOOL)newflag
{
    
    Cross *evento=[Cross initWithDict:eventobj];
    if( !evento.state == 1)
        return;
	NSString *dbpath=[DBUtil DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:dbpath];
	[fileManager release];
	if(!success)
	{
		return;
	} 
    sqlite3_stmt *stm=nil;
    const char *sql = "insert or replace into crosses (id,title,description,code,begin_at,end_at,duration,place_line1,place_line2,creator_id,created_at,updated_at,state,flag,time_type) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    

    if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
    {
        sqlite3_bind_int(stm, 1, eventid); 
        sqlite3_bind_text(stm,2,[evento.title UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stm,3, [evento.description UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stm,4, [evento.code UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stm,5, [evento.begin_at UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stm,6, [evento.end_at UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(stm,7, evento.duration);
        sqlite3_bind_text(stm,8, [evento.place_line1 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stm,9, [evento.place_line2 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(stm,10, evento.creator_id);
        sqlite3_bind_text(stm,11, [evento.created_at UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stm,12, [evento.updated_at UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(stm,13, evento.state );
        if(newflag==YES)
            sqlite3_bind_int(stm,14, 1);
        else
            sqlite3_bind_int(stm,14, 0);
        sqlite3_bind_int(stm,15, evento.time_type);
        
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
	if(!success)
	{
		return;
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
- (void) updateActivityWithobj:(NSDictionary*)dict action:(NSString*)action  cross_id:(int)cross_id
//- (void) updateActivityWithAction:(NSString*)action data:(NSString*)data time:(NSString*)time by_id:(int)by_id to_id:(int)to_id cross_id:(int)cross_id log_id:(int)log_id
{
    Activity *activity=[Activity initWithDict:dict action:action cross_id:cross_id];
	NSString *dbpath=[DBUtil DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:dbpath];
	[fileManager release];
	if(!success)
	{
		return;
	} 
    sqlite3_stmt *stm=nil;
    
    const char *sql = "insert or replace into activity (log_id, by_id, to_id, cross_id,by_name,by_avatar,to_name,to_avatar, time, action, data) values(?,?,?,?,?,?,?,?,?,?,?)";
    if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
    {
        sqlite3_bind_int(stm, 1, activity.log_id);  
        sqlite3_bind_int(stm, 2, activity.by_id);  
        sqlite3_bind_int(stm, 3, activity.to_id);  
        sqlite3_bind_int(stm, 4, activity.cross_id);  
        sqlite3_bind_text(stm,5, [activity.by_name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stm,6, [activity.by_avatar UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stm,7, [activity.to_name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stm,8, [activity.to_avatar UTF8String], -1, SQLITE_TRANSIENT);
        
        sqlite3_bind_text(stm,9, [activity.time UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stm,10, [activity.action UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stm,11, [activity.data UTF8String], -1, SQLITE_TRANSIENT);

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

- (NSMutableArray*) getRecentActivityFromLogid:(int)log_id start:(int)start num:(int)num
{
    const char *sql="select log_id, by_id, to_id, cross_id, time, action, data, by_name, by_avatar, to_name, to_avatar,title from activity a, crosses c where a.cross_id=c.id and log_id>=? order by time desc limit ?,?;";
    NSMutableArray *activitylist=[[NSMutableArray alloc] initWithCapacity:num];
    
    NSString *sqldbpath=[DBUtil DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:sqldbpath];
	[fileManager release];
	if(!success)
	{
		return 0;
	} 
	sqlite3_stmt *stm=nil;
    if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
    {
        sqlite3_bind_int(stm, 1, log_id);  
        sqlite3_bind_int(stm, 2, start);  
        sqlite3_bind_int(stm, 3, num );  
        
        while(sqlite3_step(stm)== SQLITE_ROW)
        {   
            Activity *activity=[Activity alloc];

            int log_id=sqlite3_column_int(stm, 0);
            int by_id=sqlite3_column_int(stm, 1);
            int to_id=sqlite3_column_int(stm, 2);
            int cross_id=sqlite3_column_int(stm, 3);
            NSString *time=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 4)];

            char *action=(char*)sqlite3_column_text(stm, 5);
            if(action != nil)
                activity.action=[NSString stringWithUTF8String:action];

            char *data=(char*)sqlite3_column_text(stm, 6);
            if(data != nil)
                activity.data=[NSString stringWithUTF8String:data];
            char *by_name=(char*)sqlite3_column_text(stm, 7);
            if(by_name != nil)
                activity.by_name=[NSString stringWithUTF8String:by_name];
            
            char *by_avatar=(char*)sqlite3_column_text(stm, 8);
            if(by_avatar!=nil)
                activity.by_avatar=[NSString stringWithUTF8String:by_avatar];

            char *to_name=(char*)sqlite3_column_text(stm, 9);
            if(to_name!=nil)
                activity.to_name=[NSString stringWithUTF8String:to_name];

            char *to_avatar=(char*)sqlite3_column_text(stm, 10);
            if(to_avatar!=nil)
                activity.to_avatar=[NSString stringWithUTF8String:to_avatar];

            char *title=(char*)sqlite3_column_text(stm, 11);
            if(title!=nil)
                activity.title=[NSString stringWithUTF8String:title];

            activity.log_id=log_id;
            activity.by_id=by_id;
            activity.to_id=to_id;
            activity.cross_id=cross_id;
            activity.time=time;

            [activitylist addObject:activity];
        }
    }
    else 
    {
        NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
    }            
    
    sqlite3_finalize(stm);
    for (int i=0 ; i<[activitylist count] ; i++)
    {
        Activity *activity=[activitylist objectAtIndex:i];
        if (activity.by_name == nil )
        {
            NSLog(@"by_id:%u",activity.by_id);
            User *user=[self getUserWithid:activity.by_id];
            if (user !=nil && user.name != nil)
            {
                activity.by_name=user.name;
                activity.by_avatar=user.avatar_file_name;
            }
            
        }
    }
    return activitylist;
}
- (void) updateUserobjWithid:(int)uid user:(NSDictionary*)userobj
{
	NSString *dbpath=[DBUtil DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:dbpath];
	[fileManager release];
	if(!success)
	{
		return;
	} 
    sqlite3_stmt *stm=nil;
    const char *sql = "insert or replace into users (id,name,avatar_file_name,email,bio) values(?,?,?,?,?)";
        
        if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
        {
            
            User *user=[User initWithDict:userobj];
            sqlite3_bind_int(stm, 1,uid ); 
            sqlite3_bind_text(stm,2,[user.name UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(stm,3,[user.avatar_file_name UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(stm,4,[user.email UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(stm,5,[user.bio UTF8String], -1, SQLITE_TRANSIENT);
            
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
    
    sqlite3_finalize(stm);     
}

- (User*) getUserWithid:(int)userid
{
    const char *sql="SELECT name,avatar_file_name,email,bio from users where id=?";
    NSString *_dbpath=[DBUtil DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:_dbpath];
	[fileManager release];
	if(!success)
	{
		return nil;
	} 
	sqlite3_stmt *stm=nil;
    User *user=[[User alloc]init];
    if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
    {
        sqlite3_bind_int(stm, 1, userid);  
        while(sqlite3_step(stm)== SQLITE_ROW)
        {
            user.id=userid;
            char *name=(char*)sqlite3_column_text(stm, 0);
            if(name!=NULL)
                user.name=[NSString stringWithUTF8String:name];
            char *avatar_file_name=(char*)sqlite3_column_text(stm, 1);
            if(avatar_file_name!=NULL)
                user.avatar_file_name=[NSString stringWithUTF8String:avatar_file_name];

            char *email=(char*)sqlite3_column_text(stm, 2);
            if(email!=NULL)
                user.email=[NSString stringWithUTF8String:email];
            char *bio=(char*)sqlite3_column_text(stm, 3);
            if(bio!=NULL)
                user.bio=[NSString stringWithUTF8String:bio];
        }
    }
    sqlite3_finalize(stm);
    return user;    
}
- (NSString*)getIdentifierWithid:(int)eventid
{
    const char *sql="SELECT identifier from eventical where eventid=?;";
    
	NSString *_dbpath=[DBUtil DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:_dbpath];
	[fileManager release];
	if(!success)
	{
		return nil;
	} 
	sqlite3_stmt *stm=nil;
	NSString *identifier=nil;
    
    if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
    {
        sqlite3_bind_int(stm, 1, eventid);  
        while(sqlite3_step(stm)== SQLITE_ROW)
        {
            
            identifier=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 0)];
        }
    }
    sqlite3_finalize(stm);
	return identifier;     
}
- (NSString*) getLastEventUpdateTime
{
    const char *sql="select max(updated_at) from crosses;";
    
	NSString *_dbpath=[DBUtil DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:_dbpath];
	if(!success)
	{
		return nil;
	} 
	sqlite3_stmt *stm=nil;
	NSString *LastUpdateTime=nil;
    
    if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
    {
        int flag=sqlite3_step(stm);
        if(flag== SQLITE_ROW)
        {
            char* last=(char*)sqlite3_column_text(stm, 0);
            if(last !=NULL)
            {
                LastUpdateTime=[[NSString alloc] initWithUTF8String:(char*)last];
            }
        }
    }
    else 
    {
        NSAssert1(0, @"Error while select data. '%s'", sqlite3_errmsg(database));
    }

    sqlite3_finalize(stm);
	return LastUpdateTime;     
}

- (NSString*) getLastCommentUpdateTimeWith:(int)eventid;
{
    const char *sql="select max(updated_at) from comments where eventid=?;";
    
	NSString *_dbpath=[DBUtil DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:_dbpath];
	[fileManager release];
	if(!success)
	{
		return nil;
	} 
	sqlite3_stmt *stm=nil;
	NSString *LastUpdateTime=nil;
    
    if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
    {
        sqlite3_bind_int(stm, 1, eventid);  
        int flag=sqlite3_step(stm);
        if(flag== SQLITE_ROW)
        {
            char* last=(char*)sqlite3_column_text(stm, 0);
            if(last !=NULL)
                LastUpdateTime=[NSString stringWithUTF8String:last];
        }
    }
    sqlite3_finalize(stm);
	return LastUpdateTime;      
}
- (Cross*)getCrossById:(int)cross_id {
    const char *sql="SELECT id,title,description,code,begin_at,end_at,duration,place_line1,place_line2,creator_id,created_at,updated_at,state,flag,time_type from crosses where id=?";

    NSString *dbpath=[DBUtil DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:dbpath];
	[fileManager release];
	if(!success)
	{
		return 0;
	} 
	sqlite3_stmt *stm=nil;
    Cross *cross;
    if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
    {
        sqlite3_bind_int(stm, 1, cross_id);  
        while(sqlite3_step(stm)== SQLITE_ROW)
        {
            cross=[[[Cross alloc]init] autorelease];
            cross.id=sqlite3_column_int(stm, 0);
            cross.title=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 1)];
            cross.description=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 2)];
            cross.code=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 3)];
            cross.begin_at=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 4)];
            cross.end_at=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 5)];
            cross.duration=sqlite3_column_int(stm, 6);
            if((char*)sqlite3_column_text(stm, 7)!=nil)
                cross.place_line1=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 7)];
            if((char*)sqlite3_column_text(stm, 8)!=nil)
                cross.place_line2=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 8)];
            cross.creator_id=sqlite3_column_int(stm, 9);
            cross.created_at=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 10)];
            cross.updated_at=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 11)];
            cross.state=sqlite3_column_int(stm, 12);
            cross.flag = sqlite3_column_int(stm, 13);
            cross.time_type = sqlite3_column_int(stm, 14);
        }
    }
    sqlite3_finalize(stm);
    return cross;
}
- (void)dealloc
{
    sqlite3_close(database); 
    [super dealloc];
}

@end
