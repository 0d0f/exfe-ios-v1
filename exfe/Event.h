//
//  Event.h
//  exfe
//
//  Created by 霍 炬 on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event:NSObject{
    NSInteger id;
    NSString* title;
    NSString* description;
    NSString* code;
    NSString* begin_at;
    NSString* end_at;
    NSInteger duration;
    NSString* venue;
    NSInteger creator_id;
    NSString* created_at;
    NSString* updated_at;
    NSString* state;
}

@property NSInteger id;
@property (retain,nonatomic) NSString* title;
@property (retain,nonatomic) NSString* description;
@property (retain,nonatomic) NSString* code;
@property (retain,nonatomic) NSString* begin_at;
@property (retain,nonatomic) NSString* end_at;
@property NSInteger duration;
@property (retain,nonatomic) NSString* venue;
@property NSInteger creator_id;
@property (retain,nonatomic) NSString* created_at;
@property (retain,nonatomic) NSString* updated_at;
@property (retain,nonatomic) NSString* state;

+ (Event*)initWithDict:(NSDictionary*)dict;
@end
