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
#import "NSObject+SBJson.h"

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
    
    NSString *backbtnimgpath = [[NSBundle mainBundle] pathForResource:@"backx" ofType:@"png"];
    UIImage *backbtnimg = [UIImage imageWithContentsOfFile:backbtnimgpath];
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setBackgroundImage:backbtnimg forState:UIControlStateNormal];

    button.titleLabel.font  = [UIFont boldSystemFontOfSize:12.0f];
    [button setTitleColor:[UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1] forState:UIControlStateNormal];
    
    button.frame = CGRectMake(0, 0, backbtnimg.size.width, backbtnimg.size.height);
    
	[button addTarget:self action:@selector(pushback) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
	self.navigationItem.leftBarButtonItem = customBarItem;
    [customBarItem release];    
    
    
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0]  forKey:@"notification_number"];
    [[NSUserDefaults standardUserDefaults] synchronize];

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
    if([activity.action isEqualToString:@"gather"])
        return 81;
    CGSize maximumLabelSize = CGSizeMake(255,9999);
    CGSize expectedLabelSize = [[self getMsgWithActivity:activity] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeCharacterWrap];
    if([activity.action isEqualToString:@"conversation"])
        return 5+18+18+expectedLabelSize.height+4;
    else
        return 5+18+18+expectedLabelSize.height+4;
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
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   
    Activity *activity=[activityList objectAtIndex:indexPath.row];
    NSString *avatar=activity.by_avatar;

    UITableViewCell *cell =nil;
    if([activity.action isEqualToString:@"gather"]){
        static NSString *MyIdentifier = @"tblNotificationCrossCellView";
        cell = (NotificationCrossCellView *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        if(cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"NotificationCrossCellView" owner:nil options:nil];
            for (id currentObject in topLevelObjects){
                if([currentObject isKindOfClass:[UITableViewCell class]]){
                    cell = (UITableViewCell *) currentObject;
                    break;
                }
            }            
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            [(NotificationCrossCellView *)cell setLabelCrossTitle:activity.title];
            [(NotificationCrossCellView *)cell setCrossDetail:activity.data];
            [(NotificationCrossCellView *)cell setInvitationMsg:[NSString stringWithFormat:@"Invitation from %@",activity.by_name]];
            [(NotificationCrossCellView *)cell setWithMsg:[self getWithMsg:activity]];
            NSString *x_str=activity.begin_at;
            if (![activity.place_line1 isEqualToString:@""])
                x_str=[x_str stringByAppendingFormat:@"%@ at %@",activity.begin_at,activity.place_line1];
            [(NotificationCrossCellView *)cell setCrossDetail:x_str];
            [(NotificationCrossCellView *)cell setLabelTime:[self formattedDateRelativeToNow:activity.time]];

        }
        
    }
    else if([activity.action isEqualToString:@"addexfee"] || [activity.action isEqualToString:@"delexfee"]) {//crosses view
        static NSString *MyIdentifier = @"tblActivityView";
        cell = (ActivityCellView *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        if(cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ActivityCellView" owner:nil options:nil];
            for (id currentObject in topLevelObjects){
                if([currentObject isKindOfClass:[UITableViewCell class]]){
                    cell = (UITableViewCell *) currentObject;
                    break;
                }
            }            
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            CGSize maximumLabelSize = CGSizeMake(255,9999);
            CGSize expectedLabelSize = [[self getMsgWithActivity:activity] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeCharacterWrap];
            [(ActivityCellView *)cell setModel:0 height:expectedLabelSize.height];
            
            [(ActivityCellView *)cell setLabelCrossTitle:activity.title];
            [(ActivityCellView *)cell setActionMsg:[self getMsgWithActivity:activity]];
            [(ActivityCellView *)cell setLabelTime:[self formattedDateRelativeToNow:activity.time]];
            if(activity.by_id>0)
                [(ActivityCellView *)cell setByTitle:[NSString stringWithFormat:@"by %@", activity.by_name]];
        }
    } else {
        static NSString *MyIdentifier = @"tblActivityView";
        cell = (ActivityCellView *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        if(cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ActivityCellView" owner:nil options:nil];
            for (id currentObject in topLevelObjects){
                if([currentObject isKindOfClass:[UITableViewCell class]]){
                    cell = (UITableViewCell *) currentObject;
                    break;
                }
            }
        }
        [(ActivityCellView *)cell setActionMsg:[self getMsgWithActivity:activity]];
        [(ActivityCellView *)cell setLabelTime:[self formattedDateRelativeToNow:activity.time]];

        [(ActivityCellView *)cell setLabelCrossTitle:activity.title];
        BOOL ismyaction=NO;

        if([activity.to_identities isKindOfClass:[NSArray class]]) {
            for (int i=0;i<[activity.to_identities count];i++) {
                NSDictionary *exfee=(NSDictionary*)[activity.to_identities objectAtIndex:i];
                NSString *user_id=[exfee objectForKey:@"user_id"];
                if([user_id intValue]==activity.by_id)
                    ismyaction=YES;
            }
        }
        
        if(ismyaction==NO)
            [(ActivityCellView *)cell setByTitle:[@"by " stringByAppendingString:activity.by_name]];
        else
            [(ActivityCellView *)cell setByTitle:@""];
        CGSize maximumLabelSize = CGSizeMake(255,9999);
        CGSize expectedLabelSize = [[self getMsgWithActivity:activity] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeCharacterWrap];
        [(ActivityCellView *)cell setModel:0 height:expectedLabelSize.height];

        if([activity.action isEqualToString:@"conversation"]) //hidden by line
            [(ActivityCellView *)cell hiddenBylineWithMsgHeight:expectedLabelSize.height]; 
        else if([activity.action isEqualToString:@"title"] || [activity.action isEqualToString:@"begin_at"]|| [activity.action isEqualToString:@"place"]|| [activity.action isEqualToString:@"description"])
            [(ActivityCellView *)cell showBylineWithMsgHeight:expectedLabelSize.height];
    }
    dispatch_queue_t imgQueue = dispatch_queue_create("fetchurl thread", NULL);
    dispatch_async(imgQueue, ^{
        NSString* imgName = avatar;//[avatar stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *imgurl = [ImgCache getImgUrl:imgName];
        UIImage *image = [[ImgCache sharedManager] getImgFrom:imgurl];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(image!=nil && ![image isEqual:[NSNull null]])
            {
                if([cell isKindOfClass:[ActivityCellView class]])
                    [(ActivityCellView*)cell setAvartar:image];
                else if([cell isKindOfClass:[NotificationCrossCellView class]])
                    [(NotificationCrossCellView*)cell setAvartar:image];
            }
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
    {
        NSArray *exfees=activity.to_identities ;
        if([exfees count]>0) {
            for (int i=0;i<[exfees count];i++) {
                NSDictionary *exfee=(NSDictionary*)[exfees objectAtIndex:i];
                NSString *to_name=[exfee objectForKey:@"name"];
                if(i==0)
                    msg = [msg stringByAppendingFormat:@"%@ ",to_name];
                else
                    msg = [msg stringByAppendingFormat:@",%@ ",to_name];
            }
            if([exfees count]==1)
                msg = [msg stringByAppendingFormat:@"is %@",activity.action];
            else if([exfees count]>1)
                msg = [msg stringByAppendingFormat:@"are %@",activity.action];
        }
    }
    else if([activity.action isEqualToString:@"addexfee"]) {
        NSArray *exfees=activity.to_identities ;
        if([exfees count]>0) {
            for (int i=0;i<[exfees count];i++) {
                NSDictionary *exfee=(NSDictionary*)[exfees objectAtIndex:i];
                NSString *to_name=[exfee objectForKey:@"name"];
                if(i==0)
                    msg = [msg stringByAppendingFormat:@"%@ ",to_name];
                else
                    msg = [msg stringByAppendingFormat:@",%@ ",to_name];
            }
            if([exfees count]==1)
                msg = [msg stringByAppendingFormat:@"is invited"];
            else if([exfees count]>1)
                msg = [msg stringByAppendingFormat:@"are invited"];
        }
    }
    else if([activity.action isEqualToString:@"delexfee"])
    {
        NSArray *exfees=activity.to_identities ;
        if([exfees count]>0) {
            for (int i=0;i<[exfees count];i++) {
                NSDictionary *exfee=(NSDictionary*)[exfees objectAtIndex:i];
                NSString *to_name=[exfee objectForKey:@"name"];
                if(i==0)
                    msg = [msg stringByAppendingFormat:@"%@ ",to_name];
                else
                    msg = [msg stringByAppendingFormat:@",%@ ",to_name];
            }
            if([exfees count]==1)
                msg = [msg stringByAppendingFormat:@"is deleted"];
            else if([exfees count]>1)
                msg = [msg stringByAppendingFormat:@"are deleted"];
        }
    }
    else if([activity.action isEqualToString:@"title"] || [activity.action isEqualToString:@"begin_at"]|| [activity.action isEqualToString:@"place"]|| [activity.action isEqualToString:@"description"])
    {
        if([activity.action isEqualToString:@"place"])
        {
            NSDictionary *placeobj=[activity.data JSONValue];
            NSString *line1=@"";
            NSString *line2=@"";
            if([placeobj objectForKey:@"line1"]!=nil && ![[placeobj objectForKey:@"line1"] isEqualToString:@""])
                line1=[placeobj objectForKey:@"line1"];
            if([placeobj objectForKey:@"line2"]!=nil && ![[placeobj objectForKey:@"line2"] isEqualToString:@""])
                line2=[placeobj objectForKey:@"line2"];
                
            msg=[NSString stringWithFormat:@"new place %@(%@)",line1,line2]; 
        }
        else
            msg=[NSString stringWithFormat:@"new %@: %@",activity.action,activity.data]; 
    }
    return msg;
}
- (NSString*)getWithMsg:(Activity*)activity{
    NSString *msg=@"";
    exfeAppDelegate* app=(exfeAppDelegate*)[[UIApplication sharedApplication] delegate];

    NSArray *exfees=activity.to_identities ;
    int count=0;
    for (int i=0;i<[exfees count];i++) {
        NSDictionary *exfee=(NSDictionary*)[exfees objectAtIndex:i];
        NSString *to_name=[exfee objectForKey:@"name"];
        if(app.userid!=[[exfee objectForKey:@"user_id"] intValue])
        {
            if(count==0)
                msg = [msg stringByAppendingFormat:@"%@ ",to_name];
            else
                msg = [msg stringByAppendingFormat:@",%@ ",to_name];
            count++;
        }
        if(count>=2)
            break;
    }
    if([exfees count]-count>=1)
        msg = [msg stringByAppendingFormat:@"and %d others ",[exfees count]-count];
    if(![msg isEqualToString:@""])
        msg = [NSString stringWithFormat:@"with %@",msg];
    return msg;
}

- (void)pushback
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *) formattedDateRelativeToNow:(NSString*)datestr
{
    const int SECOND = 1;
    const int MINUTE = 60 * SECOND;
    const int HOUR = 60 * MINUTE;
    const int DAY = 24 * HOUR;
    const int MONTH = 30 * DAY;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormat dateFromString:datestr]; 
    [dateFormat release];
    
    NSDate *now = [NSDate date];
    NSTimeInterval delta = [date timeIntervalSinceDate:now] * -1.0;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger units = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit);
    NSDateComponents *components = [calendar components:units fromDate:date toDate:now options:0];
    
    NSString *relativeString;
    
    if (delta < 0) {
        relativeString = @"!n the future!";
        
    } else if (delta < 1 * MINUTE) {
//        relativeString = (components.second == 1) ? @"One second ago" : [NSString stringWithFormat:@"%d seconds ago",components.second];
        relativeString =[NSString stringWithFormat:@"%ds",components.second];
        
    } else if (delta < 2 * MINUTE) {
//        relativeString =  @"a minute ago";
        relativeString =  @"1m";
        
    } else if (delta < 45 * MINUTE) {
        relativeString = [NSString stringWithFormat:@"%dm",components.minute];
        
    } else if (delta < 90 * MINUTE) {
//        relativeString = @"an hour ago";
        relativeString = @"1h";
        
    } else if (delta < 24 * HOUR) {
        relativeString = [NSString stringWithFormat:@"%dh",components.hour];
        
    } else if (delta < 48 * HOUR) {
//        relativeString = @"yesterday";
        relativeString = @"1d";
        
    } else if (delta < 30 * DAY) {
//        relativeString = [NSString stringWithFormat:@"%d days ago",components.day];
        relativeString = [NSString stringWithFormat:@"%dd",components.day];
        
    } else if (delta < 12 * MONTH) {
//        relativeString = (components.month <= 1) ? @"one month ago" : [NSString stringWithFormat:@"%d months ago",components.month];
        relativeString = [NSString stringWithFormat:@"%dm",components.month];
        
    } else {
//        relativeString = (components.year <= 1) ? @"one year ago" : [NSString stringWithFormat:@"%d years ago",components.year];
        relativeString = [NSString stringWithFormat:@"%dy",components.year];
    }
    return relativeString;  
}

@end
