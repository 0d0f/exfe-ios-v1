//
//  Identity.h
//  EXFE
//
//  Created by ju huo on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Identity : NSObject{
    NSInteger id;
    NSString* name;
    NSString* avatar_file_name;
    NSString* bio;
    NSString* created_at;
    NSString* external_identity;
    NSString* external_username;
    NSString* provider;
    int status;
}
@property NSInteger id;
@property (retain,nonatomic) NSString* name;
@property (retain,nonatomic) NSString* avatar_file_name;
@property (retain,nonatomic) NSString* bio;
@property (retain,nonatomic) NSString* created_at;
@property (retain,nonatomic) NSString* external_identity;
@property (retain,nonatomic) NSString* external_username;
@property (retain,nonatomic) NSString* provider;
@property NSInteger status;

+ (Identity*)initWithDict:(NSDictionary*)dict;

@end
