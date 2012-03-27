//
//  Invitation.h
//  exfe
//
//  Created by 霍 炬 on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Invitation : NSObject
{
    NSInteger id;
    NSInteger eventid;    
    NSInteger identity_id;    
    NSInteger user_id;    
    NSString* username;
    NSString* provider;
    NSInteger state;
    NSString* avatar;
    NSString* updated_at;

    NSInteger withnum;
    NSInteger ishost;
    
}
@property NSInteger id;
@property NSInteger eventid;
@property NSInteger identity_id;
@property NSInteger user_id;
@property (retain,nonatomic) NSString* username;
@property (retain,nonatomic) NSString* provider;
@property NSInteger state;
@property (retain,nonatomic) NSString* avatar;
@property (retain,nonatomic) NSString* updated_at;
@property NSInteger withnum;
@property NSInteger ishost;

+ (Invitation*)initWithDict:(NSDictionary*)dict EventID:(NSInteger)eid;

@end
