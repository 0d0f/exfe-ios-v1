//
//  NewsViewController.m
//  exfe
//
//  Created by huoju on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NewsViewController.h"
#import "APIHandler.h"

@implementation NewsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)LoadUserNews
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSString *html=[NSString stringWithFormat:@"<ul>"];

    APIHandler *api=[[APIHandler alloc]init];
    NSString *responseString=[api getUserNews];
    
    [api release];
    NSDictionary *statusStr=[[NSDictionary alloc] initWithObjectsAndKeys:@"决定参加",@"yes",@"决定不参加",@"no",@"有可能参加",@"maybe", nil];
    
    NSArray *userdict = [responseString JSONValue];
    for(int i=0;i<[userdict count];i++)
    {
        NSDictionary *news=[userdict objectAtIndex:i];
        NSLog(@"%@",news);
        NSDictionary *userobj=[news objectForKey:@"user"];
        NSDictionary *item=[news objectForKey:@"item"];
        if(![item isEqual:[NSNull null]] && ![[item objectForKey:@"type"]isEqual:[NSNull null]])
        if([[item objectForKey:@"type"] isEqualToString:@"Invitation"])
        {
            NSString *action=[statusStr objectForKey:[item objectForKey:@"state"]];
            html=[html stringByAppendingFormat:@"<li>%@%@<a href='http://local_%@/'>%@</a></li>",[userobj objectForKey:@"name"] ,action,[item objectForKey:@"id"],[item objectForKey:@"title"]];
            
        }
        else if([[item objectForKey:@"type"] isEqualToString:@"Comment"])
        {
            html=[html stringByAppendingFormat:@"<li>%@对<a href='http://local_%@/'>%@</a>评论:%@</li>",[userobj objectForKey:@"name"] ,[item objectForKey:@"id"],[item objectForKey:@"title"],[item objectForKey:@"comment"]];
            
        }
        NSLog(@"item:%@",item);
        
        
    }
    [statusStr release];
    [html stringByAppendingString:@"</ul>"];
    [responseString release];  
    NSURL *baseURL = [NSURL fileURLWithPath:@""];
    NSLog(@"load html");
    [webview loadHTMLString:html baseURL:nil];
    [pool release];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self LoadUserNews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self LoadUserNews];
    [NSThread detachNewThreadSelector:@selector(LoadUserNews) toTarget:self withObject:nil];

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

@end
