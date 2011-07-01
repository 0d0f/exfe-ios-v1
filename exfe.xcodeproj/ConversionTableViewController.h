//
//  ConversionTableViewController.h
//  exfe
//
//  Created by 霍 炬 on 7/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshTableViewController.h"

@interface ConversionTableViewController : PullRefreshTableViewController 
{

    NSMutableArray *comments;
}
@property (retain,nonatomic) NSMutableArray* comments;
@end
