//
//  Activity.h
//  EXFE
//
//  Created by ju huo on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Activity : NSObject{
    NSInteger log_id;
    NSInteger by_id;
    NSString *by_name;
    NSString *by_avatar;

    NSInteger to_id;
    NSString *to_name;
    NSString *to_avatar;

    NSInteger cross_id;
    NSString *time;
    NSString *action;
    NSString *data;
    NSString *title;    
    
}
@property NSInteger log_id;
@property NSInteger by_id;
@property NSInteger to_id;
@property NSInteger cross_id;

@property (retain,nonatomic) NSString* time;
@property (retain,nonatomic) NSString* action;
@property (retain,nonatomic) NSString* data;
@property (retain,nonatomic) NSString* title;

@property (retain,nonatomic) NSString* by_name;
@property (retain,nonatomic) NSString* by_avatar;
@property (retain,nonatomic) NSString* to_name;
@property (retain,nonatomic) NSString* to_avatar;

+ (Activity*)initWithDict:(NSDictionary*)dict action:(NSString*)action cross_id:(int)cross_id;

@end
