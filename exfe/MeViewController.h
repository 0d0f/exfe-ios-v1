//
//  MeViewController.h
//  exfe
//
//  Created by huoju on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MeViewController : UIViewController {
    IBOutlet UIWebView *webview;    
    IBOutlet UILabel *labelusername;
    IBOutlet UILabel *labelbio;    
}
- (IBAction) LogoutButtonPress:(id) sender;
- (void)LoadData;
//- (IBAction) test:(id) sender;
@end
