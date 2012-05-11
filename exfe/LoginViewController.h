//
//  LoginViewController.h
//  exfe
//
//  Created by huoju on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAuthLoginViewController.h"

@protocol LoginViewControllerDelegate;
@interface LoginViewController : UIViewController <OAuthLoginViewControllerDelegate> {
    id<LoginViewControllerDelegate> delegate;
    IBOutlet UITextField *textUsername;
    IBOutlet UITextField *textPassword;    
    IBOutlet UILabel *hint;
    IBOutlet UIActivityIndicatorView* activityIndicatorview;
    IBOutlet UIButton *loginbtn;
}
@property (nonatomic, assign) id <LoginViewControllerDelegate> delegate;

- (IBAction) LoginButtonPress:(id) sender;
- (IBAction) TwitterLoginButtonPress:(id) sender;
- (void) reloadUI;
- (void) loginSuccessWithUserId:(NSString*)userid username:(NSString*)username external_id:(NSString*)external_id token:(NSString*)token;

@end

@protocol LoginViewControllerDelegate
-(void)loginViewControllerDidFinish:(LoginViewController *)loginViewController;
@end