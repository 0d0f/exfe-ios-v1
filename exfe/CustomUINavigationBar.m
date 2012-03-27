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
    
    UIImage *image = [UIImage imageNamed:@"navbar_bg.png"];
	[image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];    
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0,self.frame.size.width , self.frame.size.height)] autorelease];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1];
    label.text = self.topItem.title;
    
    self.topItem.titleView = label;
}
@end
