//
//  Event.h
//  exfe
//
//  Created by 霍 炬 on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cross:NSObject{
    NSInteger id;
    NSString* title;
    NSString* description;
    NSString* code;
    NSString* begin_at;
    NSString* end_at;
    NSInteger duration;
    NSString* place_line1;
    NSString* place_line2;
    NSInteger creator_id;
    NSString* created_at;
    NSString* updated_at;
    NSInteger state;
    NSInteger flag;
}

@property NSInteger id;
@property (retain,nonatomic) NSString* title;
@property (retain,nonatomic) NSString* description;
@property (retain,nonatomic) NSString* code;
@property (retain,nonatomic) NSString* begin_at;
@property (retain,nonatomic) NSString* end_at;
@property NSInteger duration;
@property (retain,nonatomic) NSString* place_line1;
@property (retain,nonatomic) NSString* place_line2;
@property NSInteger creator_id;
@property (retain,nonatomic) NSString* created_at;
@property (retain,nonatomic) NSString* updated_at;
@property NSInteger state;
@property NSInteger flag;

+ (Cross*)initWithDict:(NSDictionary*)dict;
@end
