//
//  CustomUINavigationBar.m
//  exfe
//
//  Created by ju huo on 12/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomUINavigationBar.h"

@implementation CustomUINavigationBar
- (void)drawRect:(CGRect)rect {
    UIImage *img = [UIImage imageNamed:@"navbar_bg.jpg"];
    [img drawInRect:rect];
    
    
    CGRect frame = CGRectMake(0, 0,self.frame.size.width , 44);
    UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1];
    label.text = self.topItem.title;
    
    self.topItem.titleView = label;
}
@end
