//
//  User.h
//  exfe
//
//  Created by 霍 炬 on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject{
    NSInteger id;
    NSString* name;
    NSString* avatar_file_name;
    NSString* email;
    NSString* bio;
}

@property NSInteger id;
@property (retain,nonatomic) NSString* name;
@property (retain,nonatomic) NSString* avatar_file_name;
@property (retain,nonatomic) NSString* email;
@property (retain,nonatomic) NSString* bio;


+ (User*)initWithDict:(NSDictionary*)dict;

@end
