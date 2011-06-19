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
    NSString* username;
    NSString* provider;
    NSString* state;
    
}
@property NSInteger id;
@property NSInteger eventid;
@property (retain,nonatomic) NSString* username;
@property (retain,nonatomic) NSString* provider;
@property (retain,nonatomic) NSString* state;

+ (Invitation*)initWithDict:(NSDictionary*)dict EventID:(NSInteger)eid;

@end
