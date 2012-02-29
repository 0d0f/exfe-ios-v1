//
//  Util.h
//  EXFE
//
//  Created by ju huo on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject{
    
}
+ (NSString*) getTimeStr:(int)time_type time:(NSString*)timestr;
+ (NSString*) getLongLocalTimeStr:(int)time_type time:(NSString*)utc_timestr;
@end
