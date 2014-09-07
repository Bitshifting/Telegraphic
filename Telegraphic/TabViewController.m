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

@synthesize tabBarItemArray, viewContArray, accessToken, friendVC, isEditable, isCreate, everyVC, queue, image, UUID;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithImage:(UIImage*)nImage withAccessToken:(NSString*)apiToken isEditable:(BOOL)nIsEditable isCreate:(BOOL)nIsCreate withUUID:(NSString*)nUUID {
    self = [super init];
    
    if(self) {
        self.title = @"Favorites";
        UUID = nUUID;
        
        image = nImage;
        
        queue = [[NSOperationQueue alloc] init];
        
        isEditable = nIsEditable;
        isCreate = nIsCreate;
        
        accessToken = apiToken;
        
        // Do any additional setup after loading the view.
        
        tabBarItemArray = [[NSMutableArray alloc] init];
        viewContArray = [[NSMutableArray alloc] init];
        
        //initialize the two view controllers
        friendVC = [[FriendsTableViewController alloc] initWithAccessToken:accessToken];
        friendVC.delegate = self;
        
        friendVC.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:0 ];
        
        //initialize everyone
        everyVC = [[EveryoneTableTableViewController alloc] initWithAccessToken:accessToken];
        everyVC.delegate = self;
        
        everyVC.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:1];
        
        [tabBarItemArray addObject:friendVC.tabBarItem];
        [viewContArray addObject:friendVC];
        [tabBarItemArray addObject:everyVC.tabBarItem];
        [viewContArray addObject:everyVC];
        
        //now add the everyone
        self.tabBarItemArray = tabBarItemArray;
        [self setViewControllers:@[friendVC, everyVC]];
        [self openDrawing:nil];
        
        
        
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
        self.title = @"Favorites";
    } else if([item tag] == 1) {
        //show the bar
        self.title = @"Everyone";
    }
    
}

-(void) sendImage:(NSString*)text {
    [self openDrawing:text];
}

-(void) sendImageEveryone:(NSString *)text {
    [self openDrawing:text];
}

- (void) openDrawing:(NSString*)text {
    DrawViewController *drawVC = [[DrawViewController alloc] initWithNavViewController:self.navigationController withTime:[NSNumber numberWithInt:TIME_TO_EDIT] withText:text withImage:image isEditable:isEditable isCreate:isCreate];
    
    drawVC.delegate = self;
    
    [friendVC.friendsTimer invalidate];
    [everyVC.everyoneTimer invalidate];
    
    [self.navigationController presentViewController:drawVC animated:YES completion:nil];
}

#pragma mark DrawView Delegates
-(void) finishedImage:(UIImage *)nImage{
    //clean up here
    NSMutableURLRequest *req = [APIFunctions seenImage:[SecretKeys getURL] withAccessToken:accessToken withUUID:UUID];
    
    [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        //if there is an error, return
        if(error) {
            return;
        }
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        if([[dict objectForKey:@"success"] boolValue]) {
            NSLog(@"Image cleaned!");
        }
        
    }];
    
    [friendVC.friendsTimer invalidate];
    [everyVC.everyoneTimer invalidate];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}


-(void) editImage:(UIImage *)nImage withNextUser:(NSString *)nNextUser {
    //continue the chain
    
    NSData *imageData = UIImageJPEGRepresentation(nImage, 1.0);
    
    NSString *encodedString = [imageData base64EncodedStringWithOptions:0];
    
    if(encodedString == nil) {
        return;
    }
    
    NSMutableURLRequest *req = [APIFunctions updateImage:[SecretKeys getURL] withUUID:UUID withAccessToken:accessToken withNextUser:nNextUser withImage:encodedString];
    
    [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        //if there is an error, return
        if(error) {
            return;
        }
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        if([[dict objectForKey:@"success"] boolValue]) {
            NSLog(@"Image Successfully updated!");
        }
        
    }];
    
    [friendVC.friendsTimer invalidate];
    [everyVC.everyoneTimer invalidate];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void) newImageCreate:(UIImage *)nImage withNextUser:(NSString *)nNextUser {
    
    NSData *imageData = UIImageJPEGRepresentation(nImage, 1.0);
    
    NSString *encodedString = [imageData base64EncodedStringWithOptions:0];
    
    if(encodedString == nil) {
        return;
    }
    
    NSMutableURLRequest *req = [APIFunctions createImage:[SecretKeys getURL] withAccessToken:accessToken withEditTime:[NSNumber numberWithInt:TIME_TO_EDIT] withHopsLeft:[NSNumber numberWithInt:MAX_HOPS] withNextUser:nNextUser withImage:encodedString];
    
    [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        //if there is an error, return
        if(error) {
            return;
        }
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        if([[dict objectForKey:@"success"] boolValue]) {
            NSLog(@"Image Successfully created!");
        }
        
    }];
    
    [friendVC.friendsTimer invalidate];
    [everyVC.everyoneTimer invalidate];
    
    
    [self.navigationController popToRootViewControllerAnimated:YES];
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
