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
+ (NSString*) getLongLocalTimeStrWithTimetype:(NSString*)time_type time:(NSString*)utc_timestr{
    NSArray *arr = [utc_timestr componentsSeparatedByString:@" "];
    NSString *date=[arr objectAtIndex:0];
    NSString *time=[arr objectAtIndex:1];
    if([date isEqualToString:@"0000-00-00"] && [time isEqualToString:@"00:00:00"] && [time_type isEqualToString:@""]){
        return @"";
    }
    else if([time isEqualToString:@"00:00:00"])
    {
        NSDateFormatter *dateFormat_date = [[NSDateFormatter alloc] init];
        [dateFormat_date setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [dateFormat_date setDateFormat:@"yyyy-MM-dd"];
        NSDate *time_datetime = [dateFormat_date dateFromString:date]; 

        
        [dateFormat_date setTimeZone:[NSTimeZone localTimeZone]];
        [dateFormat_date setDateFormat:@"ccc, MMM d"];
        NSString *date_formatstr=[dateFormat_date stringFromDate:time_datetime];
        [dateFormat_date release];
        

        return [@"Anytime" stringByAppendingFormat:@" %@",date_formatstr];
    }
     
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *time_datetime = [dateFormat dateFromString:utc_timestr]; 
    
    [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormat setDateFormat:@"mm"];
    NSString *mm=[dateFormat stringFromDate:time_datetime];
    if( [mm isEqualToString:@"00"]) {
        [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
        [dateFormat setDateFormat:@"ha ccc, MMM d"];
    }
    else{
        [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
        [dateFormat setDateFormat:@"h:mma ccc, MMM d"];
    }
    
    NSString *local_formatstr=[dateFormat stringFromDate:time_datetime];
    [dateFormat release];

    return local_formatstr;
}

+ (UIColor*) getHighlightColor{
    return [UIColor colorWithRed:17/255.0f green:117/255.0f blue:165/255.0f alpha:1];
}

@end
