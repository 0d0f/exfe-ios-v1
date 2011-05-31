//
//  CommentViewController.h
//  exfe
//
//  Created by huoju on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CommentViewController : UIViewController {
    UITextView *textView;
    id delegate;
    int eventid;
}
@property int eventid;
@property (nonatomic, assign) id delegate;

+ (void)present:(UIViewController*)parentViewController event:(int)eventid delegate:(id)adelegate;

@end
