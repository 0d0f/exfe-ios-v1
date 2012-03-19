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
+ (NSString*) getLongLocalTimeStrWithTimetype:(NSString*)time_type time:(NSString*)utc_timestr;
+ (NSString*) getNormalLocalTimeStrWithTimetype:(NSString*)time_type time:(NSString*)utc_timestr;
+ (NSString *) formattedDateRelativeToNow:(NSString*)datestr;
+ (NSString *) formattedLongDateRelativeToNow:(NSString*)datestr;
+ (NSString *) formattedDateRelativeToNow:(NSString*)datestr withTimeType:(NSString*)time_type;
+ (UIColor*) getHighlightColor;
+ (NSString*) getBackgroundLink:(NSString*)imgname;
@end
