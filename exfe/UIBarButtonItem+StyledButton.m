//
//  UIBarButtonItem+StyledButton.m
//  EXFE
//
//  Created by ju huo on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UIBarButtonItem+StyledButton.h"
#import "UIButton+StyledButton.h"

@implementation UIBarButtonItem (StyledButton)
+ (UIBarButtonItem *)styledBackBarButtonItemWithTarget:(id)target selector:(SEL)selector
{
    NSString *backbtnimgpath = [[NSBundle mainBundle] pathForResource:@"backbtn" ofType:@"png"];
    UIImage *backbtnimg = [UIImage imageWithContentsOfFile:backbtnimgpath];
    
    NSString *title = NSLocalizedString(@"Back", nil);
    UIFont *font = [UIFont boldSystemFontOfSize:12.0f];
    
    UIButton *button = [UIButton styledButtonWithBackgroundImage:backbtnimg font:font title:title target:target selector:selector];
    button.titleLabel.textColor = [UIColor blackColor];
    
    CGSize textSize = [title sizeWithFont:font];
    CGFloat margin = (button.frame.size.height - textSize.height) / 2;
    CGFloat marginRight = 7.0f;
    CGFloat marginLeft = button.frame.size.width - textSize.width - marginRight;
    [button setTitleEdgeInsets:UIEdgeInsetsMake(margin, marginLeft, margin, marginRight)]; 
    [button setTitleColor:[UIColor colorWithRed:53.0f/255.0f green:77.0f/255.0f blue:99.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];   
    
    return [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];    
}

+ (UIBarButtonItem *)styledBackXButtonItemWithTarget:(id)target selector:(SEL)selector
{
    NSString *backbtnimgpath = [[NSBundle mainBundle] pathForResource:@"backx" ofType:@"png"];
    UIImage *backbtnimg = [UIImage imageWithContentsOfFile:backbtnimgpath];
    
    NSString *title = NSLocalizedString(@"Back", nil);
    UIFont *font = [UIFont boldSystemFontOfSize:12.0f];
    
    UIButton *button = [UIButton styledButtonWithBackgroundImage:backbtnimg font:font title:title target:target selector:selector];
    button.titleLabel.textColor = [UIColor blackColor];
    
    CGSize textSize = [title sizeWithFont:font];
    CGFloat margin = (button.frame.size.height - textSize.height) / 2;
    CGFloat marginRight = 7.0f;
    CGFloat marginLeft = button.frame.size.width - textSize.width - marginRight;
    [button setTitleEdgeInsets:UIEdgeInsetsMake(margin, marginLeft, margin, marginRight)]; 
    [button setTitleColor:[UIColor colorWithRed:53.0f/255.0f green:77.0f/255.0f blue:99.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];   
    
    return [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];    
}
@end
