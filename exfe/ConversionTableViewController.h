//
//  ConversionTableViewController.h
//  exfe
//
//  Created by 霍 炬 on 7/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshTableViewController.h"
#import "ConversationCellView.h"
#import "UIInputToolbar.h"
#import "Comment.h"
#import "User.h"

@interface ConversionTableViewController : PullRefreshTableViewController 
{
    int eventid;
    NSMutableArray *comments;
    UIInputToolbar *inputToolbar;
    UITextField* placeholder;

    IBOutlet ConversationCellView *tblCell;
}
@property int eventid;
@property (retain,nonatomic) NSMutableArray* comments;
@property (retain,nonatomic) UIInputToolbar* inputToolbar;
@property (retain,nonatomic) UITextField* placeholder;

- (BOOL)postComment:(NSString*)inputtext;
- (void)refreshAndHideKeyboard;//:(UIInputToolbar*)inputToolbar placeholder:(UITextField*) placeholder;
- (void)UpdateCommentObjects:(Comment*) comment;
@end