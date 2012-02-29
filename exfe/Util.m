//
//  Util.m
//  EXFE
//
//  Created by ju huo on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Util.h"

@implementation Util
+ (NSString*) getTimeStr:(int)time_type time:(NSString*)timestr
{
//    int time_type=[[dict objectForKey:@"x_time_type"] intValue];
    
    NSString *begin_at=@"";
    
        
    NSString *result_timestr=begin_at;
    if(time_type==1)
        result_timestr=@"Allday";
    else if(time_type==2)
        result_timestr=@"Anytime";
    else
    {
        if([timestr isEqualToString:@""])
            return @"";
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *time_datetime = [dateFormat dateFromString:timestr]; 
        [dateFormat setDateFormat:@"HH:mm MM-dd"];
        result_timestr=[dateFormat stringFromDate:time_datetime]; 
        [dateFormat release];
    }
    return result_timestr;
}
+ (NSString*) getLongLocalTimeStr:(int)time_type time:(NSString*)utc_timestr{
    return @"";
}
@end
