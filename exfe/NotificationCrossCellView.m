//
//  NotificationCrossViewCell.m
//  EXFE
//
//  Created by ju huo on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NotificationCrossCellView.h"

@implementation NotificationCrossCellView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)setLabelCrossTitle:(NSString *)_text {
    cellCrossTitle.text=_text;
}

- (void)setCrossDetail:(NSString *)_text {
    cellCrossDetail.text=_text;
}

- (void)setWithMsg:(NSString *)_text {
    cellwithMsg.text=_text;
}
- (void)setInvitationMsg:(NSString *)_text{
    cellInvitationMsg.text=_text;
}

- (void)setExfee:(NSString *)_text {
    cellexfee.text=_text;
}

- (void)setLabelTime:(NSString *)_text {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *time_datetime = [dateFormat dateFromString:_text]; 
    [dateFormat setDateFormat:@"HH:mm MM-dd"];
    cellTime.text=[dateFormat stringFromDate:time_datetime]; 
    [dateFormat release];
}


@end
