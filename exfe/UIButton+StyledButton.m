//
//  UIButton+StyledButton.m
//  EXFE
//
//  Created by ju huo on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UIButton+StyledButton.h"

@implementation UIButton (StyledButton)

+ (UIButton *)styledButtonWithBackgroundImage:(UIImage *)image font:(UIFont *)font title:(NSString *)title target:(id)target selector:(SEL)selector
{
//    CGSize textSize = [title sizeWithFont:font];
//    CGSize buttonSize = CGSizeMake(textSize.width + 20.0f, image.size.width);
    CGSize buttonSize =CGSizeMake(image.size.width, image.size.height);
    UIButton *button = [[[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, buttonSize.width, buttonSize.height)] autorelease];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button.titleLabel setFont:font];
    
    return button;
}
@end
