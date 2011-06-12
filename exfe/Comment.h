//
//  Comment.h
//  exfe
//
//  Created by 霍 炬 on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject {
    NSInteger id;
    NSInteger eventid;    
    NSInteger user_id;    
    NSString* comment;
    NSString* userjson;
    NSString* created_at;
    NSString* updated_at;
    
}
@property NSInteger id;
@property NSInteger eventid;
@property NSInteger user_id;
@property (retain,nonatomic) NSString* comment;
@property (retain,nonatomic) NSString* userjson;
@property (retain,nonatomic) NSString* created_at;
@property (retain,nonatomic) NSString* updated_at;
+ (Comment*)initWithDict:(NSDictionary*)dict EventID:(NSInteger)eid;
@end
