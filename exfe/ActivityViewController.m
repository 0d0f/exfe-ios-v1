//
//  ActiveViewController.m
//  EXFE
//
//  Created by ju huo on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ActivityViewController.h"
#import "ImgCache.h"
#import "Cross.h"
#import "EventViewController.h"
#import "DBUtil.h"
#import "exfeAppDelegate.h"

#define MSG_LABEL_HEIGHT 15

@implementation ActivityViewController
@synthesize activityList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect frame = CGRectMake(0, 0,400 , 44);
    UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1];
    label.text = @"Notification";
    self.navigationItem.titleView=label;
    

//    UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//    
//    NSString *closesettingbtnimgpath = [[NSBundle mainBundle] pathForResource:@"close_settingbtn" ofType:@"png"];
//    
//    UIImage *closesettingbtnimg = [UIImage imageWithContentsOfFile:closesettingbtnimgpath];
//    
//    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [doneButton setTitle:@"Close" forState:UIControlStateNormal];
//    doneButton.titleLabel.font         = [UIFont boldSystemFontOfSize:12.0f];
//    [doneButton setTitleColor:[UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1] forState:UIControlStateNormal];
//    
//    doneButton.titleEdgeInsets         = UIEdgeInsetsMake(0, 2, 0, 2);
//    doneButton.contentStretch          = CGRectMake(0.5, 0.5, 0, 0);
//    doneButton.contentMode             = UIViewContentModeScaleToFill;
//    
//    [doneButton setBackgroundImage:closesettingbtnimg forState:UIControlStateNormal];
//    doneButton.frame = CGRectMake(0, 0, closesettingbtnimg.size.width, closesettingbtnimg.size.height);
//    [doneButton addTarget:self action:@selector(Done:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [toolbar setItems:[NSArray arrayWithObjects:flexibleSpaceLeft, [[[UIBarButtonItem alloc] initWithCustomView:doneButton] autorelease], nil]];
//    
//    [flexibleSpaceLeft release];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction) Done:(id) sender
{
    [self dismissModalViewControllerAnimated:YES];    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.activityList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Activity *activity=[activityList objectAtIndex:indexPath.row];
    NSString *msg=[self getMsgWithActivity:activity];
    CGSize maximumLabelSize = CGSizeMake(296,9999);
    
    CGSize expectedLabelSize = [msg sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12]
                                      constrainedToSize:maximumLabelSize 
                                          lineBreakMode:UILineBreakModeWordWrap]; 
    if(expectedLabelSize.height>MSG_LABEL_HEIGHT)
        return 66-21+expectedLabelSize.height;
    else 
        return 66;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBUtil *dbu=[DBUtil sharedManager];
    Activity *activity=[activityList objectAtIndex:indexPath.row];

    Cross *cross=[dbu getCrossById:activity.cross_id];
    EventViewController *detailViewController=[[EventViewController alloc]initWithNibName:@"EventViewController" bundle:nil];
    detailViewController.eventid=activity.cross_id;
    detailViewController.eventobj=cross;
    
    exfeAppDelegate* app=(exfeAppDelegate*)[[UIApplication sharedApplication] delegate];  

    [app.navigationController pushViewController:detailViewController animated:YES];
    
    [detailViewController release]; 	
//    
//    [dbu setCrossStatusWithCrossId:event.id status:0];
//    NSLog(@"cross view");
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *MyIdentifier = @"tblActivityView";
    
    ActivityCellView *cell = (ActivityCellView *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if(cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"ActivityCellView" owner:self options:nil];
        cell = tblCell;
    }
    Activity *activity=[activityList objectAtIndex:indexPath.row];
    [cell setLabelCrossTitle:activity.title];
    [cell setLabelTime:activity.time];
    NSString *msg=[self getMsgWithActivity:activity];
    CGSize maximumLabelSize = CGSizeMake(296,9999);
    
    CGSize expectedLabelSize = [msg sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12]
                               constrainedToSize:maximumLabelSize 
                                   lineBreakMode:UILineBreakModeWordWrap]; 
    if(expectedLabelSize.height>MSG_LABEL_HEIGHT)
        [cell setCellHeightWithMsgHeight:expectedLabelSize.height];
    [cell setActionMsg:msg];

    NSString *avatar=activity.by_avatar;
    if([activity.action isEqualToString:@"conversation"])
    {
        avatar=activity.by_avatar;
    }
    else if([activity.action isEqualToString:@"confirmed"] || [activity.action isEqualToString:@"interested"] || [activity.action isEqualToString:@"declined"])
    {
        if(activity.to_id==activity.by_id)
            avatar=activity.by_avatar;
        else
            avatar=activity.to_avatar;
    }
    
    if(activity.to_id==activity.by_id)
        [cell setByTitle:@""];
    else if(activity.by_name!=nil && ![activity.by_name isEqualToString:@""])
        [cell setByTitle:[@"by " stringByAppendingString:activity.by_name]];
    else
        [cell setByTitle:@""];
    
    dispatch_queue_t imgQueue = dispatch_queue_create("fetchurl thread", NULL);
    dispatch_async(imgQueue, ^{
        NSString* imgName = avatar;//[avatar stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; 
        NSString *imgurl = [ImgCache getImgUrl:imgName];
        UIImage *image = [[ImgCache sharedManager] getImgFrom:imgurl];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(image!=nil && ![image isEqual:[NSNull null]]) 
                [cell setAvartar:image];
        });
    });
    
    dispatch_release(imgQueue);        
    return cell;
    
}
- (NSString*)getMsgWithActivity:(Activity*)activity
{
    NSString *msg=@"";
    if([activity.action isEqualToString:@"conversation"])
        msg=[NSString stringWithFormat:@"%@: %@",[activity.by_name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],activity.data];
    else if([activity.action isEqualToString:@"confirmed"] || [activity.action isEqualToString:@"interested"] || [activity.action isEqualToString:@"declined"])
        msg=[NSString stringWithFormat:@"%@: %@",activity.to_name,activity.action];
    return msg;
}

@end
