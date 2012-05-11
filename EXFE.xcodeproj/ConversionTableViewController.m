//
//  ConversionTableViewController.m
//  exfe
//
//  Created by 霍 炬 on 7/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ConversionTableViewController.h"
#import "ImgCache.h"
#import "APIHandler.h"
#import "DBUtil.h"
#import "NSObject+SBJson.h"

#define COMMENT_FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f
#define CELL_IMAGE_WIDTH 40.0f
#define CELL_IMAGE_HEIGHT 40.0f
#define COMMENT_LABEL_HEIGHT 18
#define COMMENT_LABEL_WIDTH 255


@implementation ConversionTableViewController
@synthesize eventid;
@synthesize comments;
@synthesize placeholder;
@synthesize inputToolbar;

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
    [self refreshAndHideKeyboard];
    //[self refreshAndHideKeyboard:nil placeholder:nil];
}

//- (void)refreshAndHideKeyboard:(UIInputToolbar*)inputToolbar placeholder:(UITextField*) placeholder
- (void)refreshAndHideKeyboard
{
    dispatch_queue_t refreshQueue = dispatch_queue_create("refreshconversation thread", NULL);
    dispatch_async(refreshQueue, ^{
        BOOL reload=FALSE;
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
                    [self UpdateCommentObjects:commentobj];
                }
            }
            if([arr count]>0)
                reload=TRUE;
        }
        [api release];
        [pool drain];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(reload)
            {
                [(UITableView*)self.view reloadData];
            }
            
            [self stopLoading];
            if(inputToolbar!=nil)
            {
                if(placeholder!=nil)
                    [placeholder resignFirstResponder];
                [inputToolbar setInputEnabled:YES];
                [inputToolbar hidekeyboard];
            }
        });
    });
    
    dispatch_release(refreshQueue);      
}
- (BOOL)postComment:(NSString*)inputtext
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    APIHandler *api=[[APIHandler alloc]init];
    NSString *uname=[[NSUserDefaults standardUserDefaults] stringForKey:@"username"]; 
    NSString *external_id=[[NSUserDefaults standardUserDefaults] stringForKey:@"external_id"]; 
    if(external_id==nil)
        external_id=uname;
    NSString *commentjson=[api AddCommentById:eventid comment:inputtext external_identity:external_id];
    BOOL success=FALSE;
    if([[[commentjson JSONValue] objectForKey:@"response"] objectForKey:@"conversation"]!=nil)
    {
        success=TRUE;
    }
    [commentjson release];
    [api release]; 
    [pool drain];
    //[NSThread detachNewThreadSelector:@selector(refresh) toTarget:self withObject:nil];
    return success;
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
    Comment *comment=[comments objectAtIndex:indexPath.row];
    CGSize maximumLabelSize = CGSizeMake(COMMENT_LABEL_WIDTH,9999);    
    CGSize expectedLabelSize = [comment.comment sizeWithFont:[UIFont fontWithName:@"Helvetica" size:COMMENT_FONT_SIZE] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap]; 
    if(expectedLabelSize.height>COMMENT_LABEL_HEIGHT)
        return 35-COMMENT_LABEL_HEIGHT+expectedLabelSize.height;
    return 35;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"tblConversationCellView";
    ConversationCellView *cell = (ConversationCellView *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if(cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"ConversationCellView" owner:self options:nil];
        cell = tblCell;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    Comment *comment=[comments objectAtIndex:indexPath.row];
    User *user=[User initWithDict:[comment.userjson JSONValue]];
    [cell setLabelText:comment.comment];
    [cell setLabelTime:[Util formattedDateRelativeToNow:comment.updated_at]];
    CGSize maximumLabelSize = CGSizeMake(COMMENT_LABEL_WIDTH,9999);
    
    CGSize expectedLabelSize = [comment.comment sizeWithFont:[UIFont fontWithName:@"Helvetica" size:COMMENT_FONT_SIZE] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap]; 
    [cell setCellHeightWithCommentHeight:expectedLabelSize.height];

    dispatch_queue_t imgQueue = dispatch_queue_create("fetchurl thread", NULL);
        dispatch_async(imgQueue, ^{
            NSString* imgName =user.avatar_file_name;
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
- (void)UpdateCommentObjects:(Comment*) comment
{
    for (int i=0;i<[comments count];i++)
    {
        Comment *_comment=[comments objectAtIndex:i];
        if(_comment.id==comment.id)
        {
            [comments replaceObjectAtIndex:i withObject:comment];
            return;
        }

    }

    [comments insertObject:comment atIndex:0];
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
    if(placeholder!=nil)
        [placeholder resignFirstResponder];
    [inputToolbar setInputEnabled:YES];
    [inputToolbar hidekeyboard];
    
}


@end
