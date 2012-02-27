//
//  Activity.h
//  EXFE
//
//  Created by ju huo on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"

@interface Activity : NSObject{
    NSInteger log_id;
    NSInteger by_id;
    NSString *by_name;
    NSString *by_avatar;

    NSInteger to_id;
    NSString *to_name;
    NSString *to_avatar;
    NSArray *to_identities;

    NSInteger cross_id;
    NSString *time;
    NSString *action;
    NSString *data;
    NSString *title;
    NSInteger time_type;
    NSString *begin_at;
    NSString *place_line1;
    NSString *invitationmsg;
    NSString *withmsg;
    
}
@property NSInteger log_id;
@property NSInteger by_id;
@property NSInteger to_id;
@property NSInteger time_type;
@property (retain,nonatomic) NSString* by_name;
@property (retain,nonatomic) NSString* by_avatar;
@property (retain,nonatomic) NSString* to_name;
@property (retain,nonatomic) NSString* to_avatar;
@property (retain,nonatomic) NSArray *to_identities;

@property NSInteger cross_id;
@property (retain,nonatomic) NSString* time;
@property (retain,nonatomic) NSString* action;
@property (retain,nonatomic) NSString* data;
@property (retain,nonatomic) NSString* title;
@property (retain,nonatomic) NSString* begin_at;
@property (retain,nonatomic) NSString* place_line1;

@property (retain,nonatomic) NSString* invitationmsg;
@property (retain,nonatomic) NSString* withmsg;


+ (Activity*)initWithDict:(NSDictionary*)dict action:(NSString*)action cross_id:(int)cross_id;

@end
