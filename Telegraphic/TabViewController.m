//
//  TabViewController.m
//  Telegraphic
//
//  Created by Kenneth Siu on 9/6/14.
//  Copyright (c) 2014 Base Twelve. All rights reserved.
//

#import "TabViewController.h"
#import "APIFunctions.h"
#import "SecretKeys.h"

#define TIME_TO_EDIT 5
#define MAX_HOPS 5

@interface TabViewController ()

@end

@implementation TabViewController

@synthesize tabBarItemArray, viewContArray, navCont, accessToken, queue, friendVC, imageVC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithNavigationController:(UINavigationController*)nNavCont withAccessTokens:(NSString*)apiToken {
    self = [super init];
    
    if(self) {
        queue = [[NSOperationQueue alloc] init];
        accessToken = apiToken;
        navCont = nNavCont;
        
        //title
        self.title = @"Friends";
        
        // Do any additional setup after loading the view.
        
        tabBarItemArray = [[NSMutableArray alloc] init];
        viewContArray = [[NSMutableArray alloc] init];
        
        //initialize the two view controllers
        friendVC = [[FriendsTableViewController alloc] initWithAccessToken:accessToken];
        friendVC.delegate = self;
        
        imageVC = [[ImagesTableViewController alloc] initWithAccessToken:accessToken];
        imageVC.delegate = self;
        
        friendVC.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:0 ];
        friendVC.title = @"Friends";
        
        imageVC.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemDownloads tag:1];
        imageVC.title = @"Images";
        
        [tabBarItemArray addObject:friendVC.tabBarItem];
        [viewContArray addObject:friendVC];
        
        [tabBarItemArray addObject:imageVC.tabBarItem];
        [viewContArray addObject:imageVC];
        
        self.tabBarItemArray = tabBarItemArray;
        [self setViewControllers:@[friendVC, imageVC]];
        
        [navCont setNavigationBarHidden:NO animated:YES];
        
    }
    
    return self;
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    //show the bar
    if([item tag] == 0) {
        self.title = @"Friends";
    } else if([item tag] == 1) {
        //show the bar
        self.title = @"Images";
    }
    
}

#pragma mark Send Image
-(void) sendImage:(NSString *)text {
    
    DrawViewController *drawVC = [[DrawViewController alloc] initWithNavViewController:navCont withTime:[NSNumber numberWithInt:TIME_TO_EDIT] withText:text];
    drawVC.delegate = self;
    
    [navCont presentViewController:drawVC animated:YES completion:nil];
}

-(void) viewImage:(NSString *)text {
    
}

-(void) drawViewEnded:(UIImage *)nImage withText:(NSString *)nText{
    
    NSData *imageData = UIImageJPEGRepresentation(nImage, 1.0);
    
    NSString *encodedString = [imageData base64EncodedStringWithOptions:0];
    
    NSMutableURLRequest *req = [APIFunctions createImage:[SecretKeys getURL] withAccessToken:accessToken withEditTime:[NSNumber numberWithInt:TIME_TO_EDIT] withHopsLeft:[NSNumber numberWithInt:MAX_HOPS] withNextUser:nText withImage:encodedString];
    
    [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        //if there is an error, return
        if(error) {
            return;
        }
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        if([[dict objectForKey:@"success"] boolValue]) {
            NSLog(@"Image Success!");
        }
        
    }];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
