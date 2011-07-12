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
    
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
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
        [self performSelector:@selector(dorefresh) withObject:nil afterDelay:0.1];
}

- (void)dorefresh
{
    NSLog(@"refreshing");

    APIHandler *api=[[APIHandler alloc]init];
    
    NSString *responseString=[api getPostsWith:eventid];

    DBUtil *dbu=[DBUtil sharedManager];
        
    NSArray *arr=[responseString JSONValue];
    [dbu updateCommentobjWithid:eventid event:arr];
    for(int i=0;i<[arr count];i++)
    {
        Comment *commentobj=[Comment initWithDict:[arr objectAtIndex:i] EventID:eventid];
        if(commentobj!=nil)
        {
            [comments insertObject:commentobj atIndex:i];
        //        
        }

    }
    if([arr count]>0)
        [(UITableView*)self.view reloadData];
    [api release];

    
    [self stopLoading];
}

- (void)postComment:(NSString*)inputtext
{
    APIHandler *api=[[APIHandler alloc]init];
    NSString *commentjson=[api AddCommentById:eventid comment:inputtext];
    NSLog(@"commentjson:%@",commentjson);
    if([[commentjson JSONValue] objectForKey:@"posts"]!=nil)
    {
        DBUtil *dbu=[DBUtil sharedManager];
        NSArray *arr=[[NSArray alloc]initWithObjects:[commentjson JSONValue], nil];
        [dbu updateCommentobjWithid:self.eventid event:arr];
        [arr release];
        Comment *comment=[Comment initWithDict:[commentjson JSONValue] EventID:self.eventid];
        //        [comments addObject:comment];
        
    }
    else
    {
        NSLog(@"comment failure");
    }
    [commentjson release];
    [api release];    
    [self dorefresh];
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
    Comment *comment=[self.comments objectAtIndex:indexPath.row];
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2 + CELL_IMAGE_WIDTH), 20000.0f);
    
    CGSize labelSize = [comment.comment sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    return MAX(labelSize.height+CELL_CONTENT_MARGIN, 60.00f);
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    Comment *comment=[comments objectAtIndex:indexPath.row];
    //initWithDict
    User *user=[User initWithDict:[comment.userjson JSONValue]];
    //    NSDictionary *user=;
    UILabel *label=nil;
    UIImageView *imageview=nil;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        [label setLineBreakMode:UILineBreakModeWordWrap];
        [label setMinimumFontSize:FONT_SIZE];
        [label setNumberOfLines:0];
        [label setFont:[UIFont systemFontOfSize:FONT_SIZE]];
        [label setTag:1];
        //        [[label layer] setBorderWidth:2.0f];
        [[cell contentView] addSubview:label];
        
        imageview=[[UIImageView alloc] initWithFrame:CGRectZero];
        [imageview setTag:2];
        [[cell contentView] addSubview:imageview];
    }
    
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2 + CELL_IMAGE_WIDTH ), 20000.0f);
    
    CGSize size = [comment.comment sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    if (!label)
        label = (UILabel*)[cell viewWithTag:1];
    
    [label setText:comment.comment];
    [label setFrame:CGRectMake(CELL_CONTENT_MARGIN+CELL_IMAGE_WIDTH, CELL_CONTENT_MARGIN, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2 + CELL_IMAGE_WIDTH), MAX(size.height, 50.0f))];
    
    if (!imageview)
        imageview = (UIImageView*)[cell viewWithTag:2];
    
    if(user.avatar_file_name!=nil && ![user.avatar_file_name isEqualToString:@""])
    {
        [imageview setFrame:CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN, CELL_IMAGE_WIDTH, CELL_IMAGE_HEIGHT)];
        NSString* imgName = [user.avatar_file_name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; 
        NSString *imgurl=[NSString stringWithFormat:@"http://api.exfe.com/system/avatars/%u/thumb/%@",user.id,imgName];
        UIImage *image = [[ImgCache sharedManager] getImgFrom:imgurl];
        if(image!=nil && ![image isEqual:[NSNull null]]) 
            imageview.image=image;
    }
    return cell;
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
