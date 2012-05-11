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
    
    UIImage *backbtnimg =[UIImage imageNamed:@"backx.png"];
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
        return 91;
    else
        return 73;
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
            [((NotificationCrossCellView *)cell).cellInvitationMsg setText:[NSString stringWithFormat:@"Invitation from %@",activity.by_name]];

            [((NotificationCrossCellView *)cell).cellInvitationMsg setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12] range:NSMakeRange([@"Invitation from " length], [activity.by_name length])];
            
            [self setWithMsg:activity Label:((NotificationCrossCellView *)cell).cellwithMsg];
            
            NSString *x_str=[Util getLongLocalTimeStrWithTimetype:activity.time_type time:activity.begin_at];
            if (![activity.place_line1 isEqualToString:@""])
                x_str=[NSString stringWithFormat:@"%@ at %@",x_str,activity.place_line1];
//                x_str=[x_str stringByAppendingFormat:@"%@ at %@",x_str,activity.place_line1];
            
            if([x_str isEqualToString:@""] && [activity.place_line1 isEqualToString:@""])
                x_str=@"Time and Place to be decided.";
            
            [(NotificationCrossCellView *)cell setCrossDetail:x_str];
            [(NotificationCrossCellView *)cell setLabelTime:[Util formattedDateRelativeToNow:activity.time]];
        }
    }
    else if([activity.action isEqualToString:@"addexfee"] || [activity.action isEqualToString:@"delexfee"]) {//crosses view
        static NSString *MyIdentifier = @"tblActivityViewaddanddel";
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
            CGSize expectedLabelSize = [[self setMsgWithActivity:activity Label:nil] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeCharacterWrap];
            [(ActivityCellView *)cell setModel:0 height:expectedLabelSize.height];
            [(ActivityCellView *)cell setLabelCrossTitle:activity.title];
            
            [self setMsgWithActivity:activity Label:((ActivityCellView *)cell).cellActionMsg];
            [(ActivityCellView *)cell setLabelTime:[Util formattedDateRelativeToNow:activity.time]];
            if(activity.by_id>0)
                [(ActivityCellView *)cell setByTitle:[NSString stringWithFormat:@"by %@", activity.by_name]];
        }
    } else if([activity.action isEqualToString:@"conversation"]){
        static NSString *MyIdentifier = @"tblConversationView";
        cell = (NotificationConversationCellView *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        if(cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"NotificationConversationCellView" owner:nil options:nil];
            for (id currentObject in topLevelObjects){
                if([currentObject isKindOfClass:[UITableViewCell class]]){
                    cell = (UITableViewCell *) currentObject;
                    break;
                }
            }
        }
        [self setMsgWithActivity:activity Label:((NotificationConversationCellView *)cell).cellCrossDetail];
        [(NotificationConversationCellView *)cell setLabelTime:[Util formattedDateRelativeToNow:activity.time]];
        
        [(NotificationConversationCellView *)cell setLabelCrossTitle:activity.title];
        CGSize maximumLabelSize = CGSizeMake(225,50);
        CGSize expectedLabelSize = [[self setMsgWithActivity:activity Label:nil] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeCharacterWrap];

//        if(expectedLabelSize.height>36)
//            [(NotificationConversationCellView *)cell setHeight:36];
        [(NotificationConversationCellView *)cell setHeight:expectedLabelSize.height];


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
        [self setMsgWithActivity:activity Label:((ActivityCellView *)cell).cellActionMsg];
        [(ActivityCellView *)cell setLabelTime:[Util formattedDateRelativeToNow:activity.time]];
        [(ActivityCellView *)cell setLabelCrossTitle:activity.title];
        BOOL ismyaction=NO;
        if([activity.to_identities isKindOfClass:[NSArray class]]) {
            for (int i=0;i<[activity.to_identities count];i++) {
                NSDictionary *exfee=(NSDictionary*)[activity.to_identities objectAtIndex:i];
                if(![exfee isEqual:[NSNull null]])
                {
                    NSString *user_id=[exfee objectForKey:@"user_id"];
                    if([user_id intValue]==activity.by_id)
                        ismyaction=YES;
                }
            }
        }
        
        if(ismyaction==NO)
        {
            [((ActivityCellView *)cell).cellByTitle setText:[@"updated by " stringByAppendingString:activity.by_name]];
            
            [((ActivityCellView *)cell).cellByTitle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12] range:NSMakeRange([@"updated by " length],[activity.by_name length])];
            
        }
        else
            [(ActivityCellView *)cell setByTitle:@""];
    }
    dispatch_queue_t imgQueue = dispatch_queue_create("fetchurl thread", NULL);
    dispatch_async(imgQueue, ^{
        NSString* imgName = avatar;
        NSString *imgurl = [ImgCache getImgUrl:imgName];
        UIImage *image = [[ImgCache sharedManager] getImgFrom:imgurl];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(image!=nil && ![image isEqual:[NSNull null]]) {
                if([cell isKindOfClass:[UITableViewCell class]])
                        [(UITableViewCell*)cell setAvartar:image];
            }
        });
    });
    
    dispatch_release(imgQueue);
    return cell;
}

#pragma mark - Cell data process
//- (NSString*)getMsgWithActivity:(Activity*)activity
- (NSString*)setMsgWithActivity:(Activity*)activity Label:(NIAttributedLabel*)label
{
    NSString *msg=@"";
    if([activity.action isEqualToString:@"conversation"]) {
        msg=[NSString stringWithFormat:@"%@: %@",[activity.by_name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],activity.data];

        NSString *newstr=[self string:msg reducedToWidth:225 withFont:[UIFont fontWithName:@"Helvetica" size:12]];
        if([msg length]>[newstr length]*2)
        {
            NSString *r=[[msg substringWithRange:NSMakeRange(0, [newstr length]*2-5)] stringByAppendingString:@"..."];
            [label setText:r];
        }
        else {
            [label setText:msg];
        }
        [label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12] range:NSMakeRange(0, [[activity.by_name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length])];

    }
    else if([activity.action isEqualToString:@"confirmed"] || [activity.action isEqualToString:@"interested"] || [activity.action isEqualToString:@"declined"]) {
        NSArray *exfees=activity.to_identities ;
        NSMutableArray *rangearray=[[NSMutableArray alloc] initWithCapacity:5];

        if([exfees count]>0) {
            for (int i=0;i<[exfees count];i++) {
                NSDictionary *exfee=(NSDictionary*)[exfees objectAtIndex:i];
                if(![exfee isEqual:[NSNull null]])
                {
                    NSString *to_name=[exfee objectForKey:@"name"];
                    if(i==0)
                    {
                        [rangearray addObject:[NSValue valueWithRange:NSMakeRange([msg length], [to_name length])]];
                        msg = [msg stringByAppendingFormat:@"%@",to_name];
                    }
                    else{
                        [rangearray addObject:[NSValue valueWithRange:NSMakeRange([msg length]+1, [to_name length])]];
                        msg = [msg stringByAppendingFormat:@",%@",to_name];
                    }
                }
            }
            if([exfees count]==1)
                msg = [msg stringByAppendingFormat:@" is %@",activity.action];
            else if([exfees count]>1)
                msg = [msg stringByAppendingFormat:@" are %@",activity.action];
        }
        [label setText:msg];
        for(NSValue *range in rangearray)
            [label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12] range:[range rangeValue]];
        [rangearray release];

    }
    else if([activity.action isEqualToString:@"addexfee"] || [activity.action isEqualToString:@"delexfee"]) {
        NSMutableArray *rangearray=[[NSMutableArray alloc] initWithCapacity:5];
        NSArray *exfees=activity.to_identities ;
        if([exfees count]>0) {
            for (int i=0;i<[exfees count];i++) {
                NSDictionary *exfee=(NSDictionary*)[exfees objectAtIndex:i];
                if(![exfee isEqual:[NSNull null]])
                {
                    NSString *to_name=[exfee objectForKey:@"name"];
                    if(i==0)
                    {
                    [rangearray addObject:[NSValue valueWithRange:NSMakeRange([msg length], [to_name length])]];
                    msg = [msg stringByAppendingFormat:@"%@",to_name];
                    }
                    else
                    {
                    [rangearray addObject:[NSValue valueWithRange:NSMakeRange([msg length]+1, [to_name length])]];
                    msg = [msg stringByAppendingFormat:@",%@",to_name];
                    }
                }
            }
            if([activity.action isEqualToString:@"addexfee"])
                if([exfees count]==1)
                    msg = [msg stringByAppendingFormat:@" is invited"];
                else if([exfees count]>1)
                    msg = [msg stringByAppendingFormat:@" are invited"];
            if([activity.action isEqualToString:@"delexfee"])
                if([exfees count]==1)
                    msg = [msg stringByAppendingFormat:@" is deleted"];
                else if([exfees count]>1)
                    msg = [msg stringByAppendingFormat:@" are deleted"];
        }
        [label setText:msg];
        for(NSValue *range in rangearray)
            [label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12] range:[range rangeValue]];
        [rangearray release];
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
                
            msg=[NSString stringWithFormat:@"%@(%@)",line1,line2]; 
        }
        else if([activity.action isEqualToString:@"begin_at"]){
            NSArray *arr=[activity.data componentsSeparatedByString:@","];
            if([arr count]==2)
                msg=[NSString stringWithFormat:@"%@",[Util getLongLocalTimeStrWithTimetype:[arr objectAtIndex:1]  time:[arr objectAtIndex:0]]]; 
            
        }
        else
            msg=[NSString stringWithFormat:@"%@",activity.data]; 
        [label setText:msg];
        [label setTextColor:[Util getHighlightColor] range:NSMakeRange(0, [msg length])];
    }
    return msg;
}

- (NSString*)setWithMsg:(Activity*)activity Label:(NIAttributedLabel*)label {

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
    }
    msg = [NSString stringWithFormat:@"with other %d: %@ ",count,msg];    
    [label setText:msg];
    [label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12] range:NSMakeRange([@"with other" length],[msg length]-[@"with other" length])];
    return msg;
}

- (NSString *)string:(NSString *)sourceString reducedToWidth:(CGFloat)width withFont:(UIFont *)font {
    
    if ([sourceString sizeWithFont:font].width <= width)
        return sourceString;
    
    NSMutableString *string = [NSMutableString string];
    
    for (NSInteger i = 0; i < [sourceString length]; i++) {
        
        [string appendString:[sourceString substringWithRange:NSMakeRange(i, 1)]];
        
        if ([string sizeWithFont:font].width > width) {
            
            if ([string length] == 1)
                return nil;
            
            [string deleteCharactersInRange:NSMakeRange(i, 1)];
            
            break;
        }
    }
    
    return string;
}

- (void)pushback
{
    [self.navigationController popViewControllerAnimated:YES];
}



@end
