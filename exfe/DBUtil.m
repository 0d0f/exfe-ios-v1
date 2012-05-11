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
//    sqlite3_finalize(stm);     
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
    sql = "delete from activity;";
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
            NSAssert1(0, @"Error while empty data. '%s'", sqlite3_errmsg(database));
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
//        NSLog(@"dbpath:%@",dbpath);

    }
    }
	return dbpath;
}

- (NSDate*) updateCrossWithCrossId:(int)cross_id change:(NSDictionary*)changes lastupdatetime:(NSDate*)lastUpdateTime_datetime
{
    @synchronized(self) {
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
    }
    return lastUpdateTime_datetime;
}

- (void) updateInvitationobjWithid:(int)eventid event:(NSArray*)invitationdict
{
    @synchronized(self) {
	NSString *dbpath=[DBUtil DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:dbpath];
	[fileManager release];
	if(!success)
	{
		return;
	} 
    sqlite3_stmt *stm=nil;
    const char *sql = "insert or replace into invitations (id,cross_id,username,provider,state,avatar_file_name,identity_id,user_id,updated_at,withnum,ishost) values(?,?,?,?,?,?,?,?,?,?,?)";
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
            sqlite3_bind_int(stm,10,invitationobj.withnum);
            sqlite3_bind_int(stm,11,invitationobj.ishost);
            
            if(sqlite3_step(stm)== SQLITE_DONE) {
            }
            else {
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
            }            
        }
        else {
            NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
        }
    }
    sqlite3_finalize(stm);   
    }
}

- (void) updateInvitationobjWithCrossid:(int)cross_id identity_id:(NSArray*)to_identities rsvp:(NSString*)rsvp{
    
    @synchronized(self) {
        NSString *dbpath=[DBUtil DBPath];
        NSFileManager *fileManager=[NSFileManager defaultManager];
        BOOL success=[fileManager fileExistsAtPath:dbpath];
        [fileManager release];
        if(!success) {
            return;
        } 
        sqlite3_stmt *stm=nil;
        const char *sql = "update invitations set state=? where cross_id=? and identity_id=?;";
        for(int i=0;i<[to_identities count];i++)
        {
            NSDictionary *to_identity=[to_identities objectAtIndex:i];
            if(![to_identity isEqual:[NSNull null]])
            {
                if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
                {
                
                    if([rsvp isEqualToString:@"confirmed"] )
                        sqlite3_bind_int(stm, 1,1); 
                    else if([rsvp isEqualToString:@"declined"] )
                        sqlite3_bind_int(stm, 1,2); 
                    else if([rsvp isEqualToString:@"interested"] )
                        sqlite3_bind_int(stm, 1,3); 
                
                    sqlite3_bind_int(stm, 2, cross_id); 
                    sqlite3_bind_int(stm, 3, [[to_identity objectForKey:@"id"] intValue]); 
                
                    if(sqlite3_step(stm)== SQLITE_DONE) {
                    }
                    else {
                        NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
                    }            
                }
                else {
                    NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
                }            
            }
        }
        sqlite3_finalize(stm);   
    }    
}


- (NSMutableArray*) getCommentWithEventid:(int)eventid
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
        {   Comment *commentobj=[[[Comment alloc]init] autorelease];
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
- (NSMutableArray*) getRecentEventObj
{
    const char *sql="SELECT id,title,description,code,begin_at,end_at,duration,place_line1,place_line2,creator_id,created_at,updated_at,state,flag,time_type,place_provider,place_external_id,place_lng,place_lat,background from crosses order by updated_at desc limit 20;";
    NSMutableArray *eventlist=[[NSMutableArray alloc] initWithCapacity:50] ;
    
    NSString *dbpath=[DBUtil DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:dbpath];
	[fileManager release];
	if(!success){
		return 0;
	} 
	sqlite3_stmt *stm=nil;
    
    if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
    {
        while(sqlite3_step(stm)== SQLITE_ROW)
        {   Cross *eventobj=[[[Cross alloc]init] autorelease];
            eventobj.id=sqlite3_column_int(stm, 0);
            if((char*)sqlite3_column_text(stm, 1)!=nil)
                eventobj.title=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 1)];
            if((char*)sqlite3_column_text(stm, 2)!=nil)
                eventobj.description=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 2)];
            if((char*)sqlite3_column_text(stm, 3)!=nil)
                eventobj.code=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 3)];
            eventobj.begin_at=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 4)];
            if((char*)sqlite3_column_text(stm, 5)!=nil)
                eventobj.end_at=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 5)];
            eventobj.duration=sqlite3_column_int(stm, 6);
            if((char*)sqlite3_column_text(stm, 7)!=nil)
                eventobj.place_line1=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 7)];
            if((char*)sqlite3_column_text(stm, 8)!=nil)
                eventobj.place_line2=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 8)];
            
            eventobj.creator_id=sqlite3_column_int(stm, 9);
            if((char*)sqlite3_column_text(stm, 10)!=nil)
                eventobj.created_at=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 10)];
            eventobj.updated_at=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 11)];
            eventobj.state=sqlite3_column_int(stm, 12);
            eventobj.flag = sqlite3_column_int(stm, 13);
            if((char*)sqlite3_column_text(stm, 14)!=nil)
                eventobj.time_type = [NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 14)];
            
            if((char*)sqlite3_column_text(stm, 15)!=nil)
                eventobj.place_provider=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 15)];

            if((char*)sqlite3_column_text(stm, 16)!=nil)
                eventobj.place_external_id=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 16)];
            if((char*)sqlite3_column_text(stm, 17)!=nil)
                eventobj.place_lng = [NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 17)];
            if((char*)sqlite3_column_text(stm, 18)!=nil)
                eventobj.place_lat = [NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 18)];

            if((char*)sqlite3_column_text(stm, 19)!=nil)
                eventobj.background = [NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 19)];

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

- (NSArray*) getInvitationWithEventid:(int)eventid
{
    const char *sql="SELECT `id` ,`username`,`provider`,`state`,`avatar_file_name`,`identity_id`,`user_id`,`withnum`,`ishost` from invitations where cross_id=? order by id ;";
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
            Invitation *invitationobj=[[[Invitation alloc]init] autorelease];
            invitationobj.id=sqlite3_column_int(stm, 0);
            if((char*)sqlite3_column_text(stm, 1)!=nil)
                invitationobj.username=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 1)];
            if((char*)sqlite3_column_text(stm, 2)!=nil)
                invitationobj.provider=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 2)];
            invitationobj.state=sqlite3_column_int(stm, 3);
            invitationobj.avatar=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 4)];
            invitationobj.identity_id=sqlite3_column_int(stm, 5);
            invitationobj.user_id=sqlite3_column_int(stm, 6);
            invitationobj.withnum=sqlite3_column_int(stm, 7);
            invitationobj.ishost= sqlite3_column_int(stm, 8);
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
    @synchronized(self) {
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
}
- (void) clearAllCrossStatus
{
    @synchronized(self) {
        NSString *dbpath=[DBUtil DBPath];
        NSFileManager *fileManager=[NSFileManager defaultManager];
        BOOL success=[fileManager fileExistsAtPath:dbpath];
        [fileManager release];
        if(!success)
        {
            return;
        } 
        sqlite3_stmt *stm=nil;
        const char *sql = "update crosses set flag=0;";
        if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
        {
            if(sqlite3_step(stm)== SQLITE_DONE)
            {
                
            }
            else 
            {
                NSAssert1(0, @"Error while set cross status. '%s'", sqlite3_errmsg(database));
            }            
            
        }
    }
    
}
- (void) updateConversationWithid:(int)cross_id cross:(NSDictionary*)conversationobj
{
    @synchronized(self) {
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
        Comment *commentobj=[Comment initWithDict:conversationobj EventID:cross_id];
        if(![commentobj.comment isEqualToString:@""])
        if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
        {

            sqlite3_bind_int(stm, 1,commentobj.id ); 
            sqlite3_bind_int(stm, 2, cross_id); 
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
        else {
                    NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
        }
        sqlite3_finalize(stm); 
    }    
}
- (void) updateCommentobjWithid:(int)eventid event:(NSArray*)commentdict
{
    @synchronized(self) {
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
    }
}

- (void) updateEventobjWithid:(int)eventid event:(NSDictionary*)eventobj isnew:(BOOL)newflag
{
    @synchronized(self) {
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
    const char *sql = "insert or replace into crosses (id,title,description,code,begin_at,end_at,duration,place_line1,place_line2,creator_id,created_at,updated_at,state,flag,time_type,place_provider,place_external_id,place_lng,place_lat,background ) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    

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
        sqlite3_bind_text(stm,15, [evento.time_type UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stm,16, [evento.place_provider UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stm,17, [evento.place_external_id UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stm,18, [evento.place_lng UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stm,19, [evento.place_lat UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stm,20, [evento.background UTF8String], -1, SQLITE_TRANSIENT);
        
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
}
- (void) updateEventicalWithid:(int)eventid  identifier:(NSString*) eventIdentifier
{
    @synchronized(self) {
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
}
- (void) updateActivityWithobj:(NSDictionary*)dict action:(NSString*)action  cross_id:(int)cross_id
{
    @synchronized(self) {
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
    
    const char *sql = "insert or replace into activity (log_id, by_id, to_id, cross_id,by_name,by_avatar,to_name,to_avatar, time, action, withmsg,invitationmsg,data,to_identities,title) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
    {
        if(activity.data==nil)
            activity.data=@"";
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
        sqlite3_bind_text(stm,11, [activity.withmsg UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stm,12, [activity.invitationmsg UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stm,13, [activity.data UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stm,14, [[activity.to_identities JSONRepresentation] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stm,15, [activity.title UTF8String], -1, SQLITE_TRANSIENT);

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
}

- (NSMutableArray*) getRecentActivityFromLogid:(int)log_id start:(int)start num:(int)num
{
    const char *sql="select log_id, by_id, to_id, cross_id, `time`, action, data, by_name, by_avatar, to_name, to_avatar,a.title,withmsg,invitationmsg,c.begin_at,c.place_line1,c.time_type,c.place_line2,to_identities from activity a, crosses c where a.cross_id=c.id and log_id>=? order by time desc limit ?,100;";
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

            char *time=(char*)sqlite3_column_text(stm, 4);
            if(time!=nil)
                activity.time=[NSString stringWithUTF8String:time];

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

            char *withmsg=(char*)sqlite3_column_text(stm, 12);
            if(withmsg!=nil)
                activity.withmsg=[NSString stringWithUTF8String:withmsg];

            char *invitationmsg=(char*)sqlite3_column_text(stm, 13);
            if(invitationmsg!=nil)
                activity.invitationmsg=[NSString stringWithUTF8String:invitationmsg];

            char *begin_at=(char*)sqlite3_column_text(stm, 14);
            if(begin_at!=nil)
                activity.begin_at =[NSString stringWithUTF8String:begin_at];
            
            char *place_line1=(char*)sqlite3_column_text(stm, 15);
            if(place_line1!=nil)
                activity.place_line1 =[NSString stringWithUTF8String:place_line1];
            
            char *time_type=(char*)sqlite3_column_text(stm, 16);
            if(time_type!=nil)
                activity.time_type =[NSString stringWithUTF8String:time_type];
            
            char *place_line2=(char*)sqlite3_column_text(stm, 17);
            if(place_line2!=nil)
            {
                NSString *place_line2_str =[NSString stringWithUTF8String:place_line2];
                if(![place_line2_str isEqualToString:@""])
                    activity.place_line1=[NSString stringWithFormat:@"%@ (%@)",activity.place_line1,place_line2_str];
            }
            char *to_identities=(char*)sqlite3_column_text(stm, 18);
            if(to_identities!=nil)
            {
                activity.to_identities=[[NSString stringWithUTF8String:to_identities] JSONValue];
            }
            activity.log_id=log_id;
            activity.by_id=by_id;
            activity.to_id=to_id;
            activity.cross_id=cross_id;
            
//            activity.begin_at=[Util getTimeStr:time_type time:activity.begin_at];
            
//            activity.time_type=time_type;
            [activitylist addObject:activity];
        }
    }
    else 
    {
        NSAssert1(0, @"Error while select data. '%s'", sqlite3_errmsg(database));
    }            
    
    sqlite3_finalize(stm);
    for (int i=0 ; i<[activitylist count] ; i++)
    {
        Activity *activity=[activitylist objectAtIndex:i];
        if (activity.by_name == nil )
        {
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
    @synchronized(self) {
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
    User *user=[[[User alloc]init] autorelease];
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
            if((char*)sqlite3_column_text(stm, 3)!=nil)
                cross.code=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 3)];
            
            if((char*)sqlite3_column_text(stm, 4)!=nil)
                cross.begin_at=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 4)];
            if((char*)sqlite3_column_text(stm, 5)!=nil) 
                cross.end_at=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 5)];
            cross.duration=sqlite3_column_int(stm, 6);
            if((char*)sqlite3_column_text(stm, 7)!=nil)
                cross.place_line1=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 7)];
            if((char*)sqlite3_column_text(stm, 8)!=nil)
                cross.place_line2=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 8)];
            cross.creator_id=sqlite3_column_int(stm, 9);
            if((char*)sqlite3_column_text(stm, 10)!=nil)    
                cross.created_at=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 10)];
            if((char*)sqlite3_column_text(stm, 11)!=nil)
                cross.updated_at=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 11)];
            cross.state=sqlite3_column_int(stm, 12);
            cross.flag = sqlite3_column_int(stm, 13);
            if((char*)sqlite3_column_text(stm, 14)!=nil)
                cross.time_type=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stm, 14)];
        }
    }
    sqlite3_finalize(stm);
    return cross;
}

- (int)getConfirmNumByCrossId:(int)cross_id
{
    const char *sql="SELECT count(id) from invitations where cross_id=? and state=1;";
    
    NSString *dbpath=[DBUtil DBPath];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL success=[fileManager fileExistsAtPath:dbpath];
	[fileManager release];
	if(!success)
	{
		return 0;
	} 
	sqlite3_stmt *stm=nil;
    int confirmed_num;
    if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)==SQLITE_OK)
    {
        sqlite3_bind_int(stm, 1, cross_id);  
        while(sqlite3_step(stm)== SQLITE_ROW)
        {
            confirmed_num=sqlite3_column_int(stm, 0);

        }
    }
    sqlite3_finalize(stm);
    return confirmed_num;    
}
- (void)dealloc
{
    sqlite3_close(database); 
    [super dealloc];
}

@end
