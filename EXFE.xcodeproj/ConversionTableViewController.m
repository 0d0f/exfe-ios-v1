//
//  ConversionTableViewController.m
//  exfe
//
//  Created by 霍 炬 on 7/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ConversionTableViewController.h"
#import "Comment.h"
#import "User.h"
#import "ImgCache.h"
#import "APIHandler.h"
#import "DBUtil.h"
#import "NSObject+SBJson.h"

#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f
#define CELL_IMAGE_WIDTH 40.0f
#define CELL_IMAGE_HEIGHT 40.0f


@implementation ConversionTableViewController
@synthesize eventid;
@synthesize comments;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)refresh
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    APIHandler *api=[[APIHandler alloc]init];
    NSString *responseString=[api getPostsWith:eventid];
    
    DBUtil *dbu=[DBUtil sharedManager];
    
    id code=[[[responseString JSONValue] objectForKey:@"meta"] objectForKey:@"code"];
    if([code isKindOfClass:[NSNumber class]] && [code intValue]==200)
    {
        NSArray *arr=[[[responseString JSONValue] objectForKey:@"response"] objectForKey:@"conversations"];
        
        [dbu updateCommentobjWithid:eventid event:arr];
        for(int i=0;i<[arr count];i++)
        {
            Comment *commentobj=[Comment initWithDict:[arr objectAtIndex:i] EventID:eventid];
            if(commentobj!=nil)
            {
                [comments insertObject:commentobj atIndex:i];
            }
            
        }
        if([arr count]>0)
            [(UITableView*)self.view reloadData];
    }
    [api release];
    [self stopLoading];
    [pool drain];
}


- (void)postComment:(NSString*)inputtext
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    APIHandler *api=[[APIHandler alloc]init];
    NSString *uname=[[NSUserDefaults standardUserDefaults] stringForKey:@"username"]; 
    NSString *commentjson=[api AddCommentById:eventid comment:inputtext external_identity:uname];
    if([[[commentjson JSONValue] objectForKey:@"response"] objectForKey:@"conversation"]!=nil)
    {
        //TODO
//        DBUtil *dbu=[DBUtil sharedManager];
//        NSArray *arr=[[NSArray alloc]initWithObjects:[commentjson JSONValue], nil];
//        [dbu updateCommentobjWithid:self.eventid event:arr];
//        [arr release];
        Comment *comment=[Comment initWithDict:[[[commentjson JSONValue] objectForKey:@"response"] objectForKey:@"conversation"] EventID:self.eventid];
        [NSThread detachNewThreadSelector:@selector(refresh) toTarget:self withObject:nil];

        //[comments addObject:comment];
//        [comments insertObject:comment atIndex:0];        
//        [(UITableView*)self.view reloadData];
    }
    else
    {
        NSLog(@"comment failure");
    }
    [commentjson release];
    [api release]; 
    [pool drain];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.comments count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
//    Comment *comment=[self.comments objectAtIndex:indexPath.row];
//    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2 + CELL_IMAGE_WIDTH), 20000.0f);
//    
//    CGSize labelSize = [comment.comment sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
//    
//    return MAX(labelSize.height+CELL_CONTENT_MARGIN, 60.00f);
//    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    tblConversationCellView
    static NSString *MyIdentifier = @"tblCrossCellView";

    ConversationCellView *cell = (ConversationCellView *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if(cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"ConversationCellView" owner:self options:nil];
        cell = tblCell;
    }
    Comment *comment=[comments objectAtIndex:indexPath.row];
    User *user=[User initWithDict:[comment.userjson JSONValue]];

    [cell setLabelText:comment.comment];
    [cell setLabelTime:comment.created_at];
    dispatch_queue_t imgQueue = dispatch_queue_create("fetchurl thread", NULL);
        dispatch_async(imgQueue, ^{
            NSString* imgName = [user.avatar_file_name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; 
            NSString *imgurl = [ImgCache getImgUrl:imgName];
            UIImage *image = [[ImgCache sharedManager] getImgFrom:imgurl];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(image!=nil && ![image isEqual:[NSNull null]]) 
                    [cell setAvartar:image];
            });
        });
        
    dispatch_release(imgQueue);        
    return cell;


//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        label = [[UILabel alloc] initWithFrame:CGRectZero];
//        [label setLineBreakMode:UILineBreakModeWordWrap];
//        [label setMinimumFontSize:FONT_SIZE];
//        [label setNumberOfLines:0];
//        [label setFont:[UIFont systemFontOfSize:FONT_SIZE]];
//        [label setTag:1];
//        [[cell contentView] addSubview:label];
//        
//        imageview=[[UIImageView alloc] initWithFrame:CGRectZero];
//        [imageview setTag:2];
//        [[cell contentView] addSubview:imageview];

//    }
//    Cross *event=[events objectAtIndex:indexPath.row];
//    [cell setLabelText:event.title];
//    [cell setLabelTime:[event.begin_at substringToIndex:10]];
//    
// 
//    if (cell == nil) {
//    }
//    
//    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2 + CELL_IMAGE_WIDTH ), 20000.0f);
//    
//    CGSize size = [comment.comment sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
//    
//    if (!label)
//        label = (UILabel*)[cell viewWithTag:1];
//    
//    [label setText:comment.comment];
//    [label setFrame:CGRectMake(CELL_CONTENT_MARGIN+CELL_IMAGE_WIDTH, CELL_CONTENT_MARGIN, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2 + CELL_IMAGE_WIDTH), MAX(size.height, 50.0f))];
//    
//    if (!imageview)
//        imageview = (UIImageView*)[cell viewWithTag:2];
//    
//    if(user.avatar_file_name!=nil && ![user.avatar_file_name isEqualToString:@""])
//    {
//        [imageview setFrame:CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN, CELL_IMAGE_WIDTH, CELL_IMAGE_HEIGHT)];
//        
//            
//    }
//    [pool drain];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}


@end
