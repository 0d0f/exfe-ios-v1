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
+ (NSString*) getNormalLocalTimeStrWithTimetype:(NSString*)time_type time:(NSString*)utc_timestr{
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
        [dateFormat_date setDateFormat:@"yyyy-MM-dd"];
        NSString *date_formatstr=[dateFormat_date stringFromDate:time_datetime];
        [dateFormat_date release];
        return [@"Anytime" stringByAppendingFormat:@" %@",date_formatstr];
    }
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *time_datetime = [dateFormat dateFromString:utc_timestr]; 
    
    [dateFormat setTimeZone:[NSTimeZone localTimeZone]];

    NSString *local_formatstr=[dateFormat stringFromDate:time_datetime];
    [dateFormat release];
    
    return local_formatstr;    
}
+ (NSString *) formattedDateRelativeToNow:(NSString*)datestr withTimeType:(NSString*)time_type{
    
    NSArray *arr = [datestr componentsSeparatedByString:@" "];
    
    NSString *date=[arr objectAtIndex:0];
    NSString *time=[arr objectAtIndex:1];
    
    if([date isEqualToString:@"0000-00-00"] && [time isEqualToString:@"00:00:00"] && [time_type isEqualToString:@""])        
        return @"Time to be decided.";
    else 
        return [self formattedLongDateRelativeToNow:datestr];
}

+ (NSString *) formattedLongDateRelativeToNow:(NSString*)datestr {
    const int SECOND = 1;
    const int MINUTE = 60 * SECOND;
    const int HOUR = 60 * MINUTE;
    const int DAY = 24 * HOUR;
    const int MONTH = 30 * DAY;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSDate *date = [dateFormat dateFromString:datestr]; 
    [dateFormat release];
    
    NSDate *now = [NSDate date];
    NSTimeInterval delta = [date timeIntervalSinceDate:now] * -1.0;
    BOOL isNegative=NO;
    if (delta < 0) {
        isNegative=YES;
        delta=-delta;
    }
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger units = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit);
    NSDateComponents *components = [calendar components:units fromDate:date toDate:now options:0];
    
    NSString *relativeString;
    if (delta < 1 * MINUTE) {
        relativeString = (components.second == 1) ? @"One second" : [NSString stringWithFormat:@"%d seconds",abs(components.second)];
    } else if (delta < 2 * MINUTE) {
        relativeString =  @"a minute";
    } else if (delta < 45 * MINUTE) {
        relativeString = [NSString stringWithFormat:@"%d minutes",abs(components.minute)];
    } else if (delta < 90 * MINUTE) {
        relativeString = @"an hour";
    } else if (delta < 24 * HOUR) {
        relativeString = [NSString stringWithFormat:@"%d hours",abs(components.hour)];
    } else if (delta < 48 * HOUR) {
        if(isNegative==NO)
            relativeString = @"yesterday";
        else if(isNegative==YES)
            relativeString = @"tomorrow";
        return relativeString;
    } else if (delta < 30 * DAY) {
        relativeString = [NSString stringWithFormat:@"%d days",abs(components.day)];
    } else if (delta < 12 * MONTH) {
        relativeString = (components.month <= 1) ? @"one month" : [NSString stringWithFormat:@"%d months",abs(components.month)];
    } else {
        relativeString = (components.year <= 1) ? @"one year" : [NSString stringWithFormat:@"%d years",abs(components.year)];
    }

    if(isNegative==NO)
        relativeString = [relativeString stringByAppendingString:@" ago"];
    else if(isNegative==YES)
        relativeString = [relativeString stringByAppendingString:@" later"];

    return relativeString;      
}

+ (NSString *) formattedDateRelativeToNow:(NSString*)datestr
{
    const int SECOND = 1;
    const int MINUTE = 60 * SECOND;
    const int HOUR = 60 * MINUTE;
    const int DAY = 24 * HOUR;
    const int MONTH = 30 * DAY;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSDate *date = [dateFormat dateFromString:datestr]; 
    [dateFormat release];
    
    NSDate *now = [NSDate date];
    NSTimeInterval delta = [date timeIntervalSinceDate:now] * -1.0;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger units = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit);
    NSDateComponents *components = [calendar components:units fromDate:date toDate:now options:0];
    
    NSString *relativeString;
    
    if (delta < 0) {
        delta=-delta;
//        relativeString = @"!n the future!";
   }// else 
        
    if (delta < 1 * MINUTE) {
        //        relativeString = (components.second == 1) ? @"One second ago" : [NSString stringWithFormat:@"%d seconds ago",components.second];
        relativeString =[NSString stringWithFormat:@"%ds",components.second];
        
    } else if (delta < 2 * MINUTE) {
        //        relativeString =  @"a minute ago";
        relativeString =  @"1m";
        
    } else if (delta < 45 * MINUTE) {
        relativeString = [NSString stringWithFormat:@"%dm",components.minute];
        
    } else if (delta < 90 * MINUTE) {
        //        relativeString = @"an hour ago";
        relativeString = @"1h";
        
    } else if (delta < 24 * HOUR) {
        relativeString = [NSString stringWithFormat:@"%dh",components.hour];
        
    } else if (delta < 48 * HOUR) {
        //        relativeString = @"yesterday";
        relativeString = @"1d";
        
    } else if (delta < 30 * DAY) {
        //        relativeString = [NSString stringWithFormat:@"%d days ago",components.day];
        relativeString = [NSString stringWithFormat:@"%dd",components.day];
        
    } else if (delta < 12 * MONTH) {
        //        relativeString = (components.month <= 1) ? @"one month ago" : [NSString stringWithFormat:@"%d months ago",components.month];
        relativeString = [NSString stringWithFormat:@"%dm",components.month];
        
    } else {
        //        relativeString = (components.year <= 1) ? @"one year ago" : [NSString stringWithFormat:@"%d years ago",components.year];
        relativeString = [NSString stringWithFormat:@"%dy",components.year];
    }
    return relativeString;  
}

+ (UIColor*) getHighlightColor{
    return [UIColor colorWithRed:17/255.0f green:117/255.0f blue:165/255.0f alpha:1];
}

+ (NSString*) getBackgroundLink:(NSString*)imgname
{
    return [NSString stringWithFormat:@"http://img.exfe.com/xbgimage/%@_ios.jpg",imgname];
}

+ (NSString*) decodeFromPercentEscapeString:(NSString*)string{
    return (NSString *)
    CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                            (CFStringRef) string,
                                                            CFSTR(""),
                                                            kCFStringEncodingUTF8);
}
@end
