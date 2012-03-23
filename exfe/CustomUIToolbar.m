//
//  CustomUIToolbar.m
//  EXFE
//
//  Created by ju huo on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomUIToolbar.h"

@implementation CustomUIToolbar
- (void)drawRect:(CGRect)rect {
    UIImage *img = [UIImage imageNamed:@"toolbarbg.png"];
    [img drawInRect:rect];
}
@end
