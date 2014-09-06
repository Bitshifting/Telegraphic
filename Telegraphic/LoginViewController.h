//
//  LoginViewController.h
//  Telegraphic
//
//  Created by Ricardo Lopez on 9/6/14.
//  Copyright (c) 2014 Base Twelve. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *usernameField;

@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property CGPoint originalCenter;

- (IBAction)loginButton:(UIButton *)sender;

- (IBAction)creatAccountButton:(UIButton *)sender;

@end
