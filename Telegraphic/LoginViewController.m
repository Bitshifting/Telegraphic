//
//  LoginViewController.m
//  Telegraphic
//
//  Created by Ricardo Lopez on 9/6/14.
//  Copyright (c) 2014 Base Twelve. All rights reserved.
//

#import <CommonCrypto/CommonHMAC.h>
#import "LoginViewController.h"
#import "APIFunctions.h"
#import "SecretKeys.h"
#import "DrawViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize usernameField, passwordField, queue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerKeyboardNotifications];
    
    queue = [[NSOperationQueue alloc] init];
    
    
    usernameField.delegate = self;
    passwordField.delegate = self;
    self.originalCenter = self.view.center;
    NSLog(@"%@", NSStringFromCGPoint(self.originalCenter));
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButton:(UIButton *)sender {
    
    NSMutableURLRequest *req = [APIFunctions loginUser:[SecretKeys getURL] withUsername:usernameField.text withPassHash:[self hashString:passwordField.text withSalt:usernameField.text]];
    
    [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        //if there is an error, return
        if(error) {
            return;
        }
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        if(dict && [[dict objectForKey:@"success"] boolValue]) {
            //now get access token and send to the tab view controller
            NSString *accessToken = [dict objectForKey:@"accessToken"];
            
            
            
        }
        
    }];
}

- (IBAction)creatAccountButton:(UIButton *)sender {
    NSMutableURLRequest *req = [APIFunctions registerUser:[SecretKeys getURL] withUsername:usernameField.text withPassHash:[self hashString:passwordField.text withSalt:usernameField.text] withPhoneNumb:usernameField.text];
    
    [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        //if there is an error, return
        if(error) {
            return;
        }
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        if(dict && [[dict objectForKey:@"success"] boolValue]) {
            NSLog(@"Successfully registered the account");
        }
        
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == usernameField) {
        [textField resignFirstResponder];
        [passwordField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    return YES;
}

/**
 * Register keyboard notifications.
 */
-(void) registerKeyboardNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(keyboardDidShow:)
                   name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self
               selector:@selector(keyboardWillHide:)
                   name:UIKeyboardWillHideNotification object:nil];
}


/**
 * Unregister keyboard notifications.
 */
-(void) unregisterKeyboardNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [center removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void)keyboardDidShow:(NSNotification *)notification
{
    //Assign new frame to your view
//    [self.view setFrame:CGRectMake(0,-20,320,460)]; //here taken -20 for example i.e. your view will be scrolled to -20. change its value according to your requirement.
    self.view.center = CGPointMake(self.originalCenter.x, 130.0f);
}

-(void)keyboardWillHide:(NSNotification *)notification
{
//    [self.view setFrame:CGRectMake(0,0,320,460)];
    self.view.center = self.originalCenter;
}

#pragma mark crypto
-(NSString *) hashString :(NSString *) data withSalt: (NSString *) salt {
    
    
    const char *cKey  = [salt cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSString *hash;
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", cHMAC[i]];
    hash = output;
    return hash;
    
}

@end
