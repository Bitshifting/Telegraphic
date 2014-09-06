//
//  TabViewController.h
//  Telegraphic
//
//  Created by Kenneth Siu on 9/6/14.
//  Copyright (c) 2014 Base Twelve. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendsTableViewController.h"
#import "DrawViewController.h"

@interface TabViewController : UITabBarController <FriendsTableDelegate, DrawViewDelegate>

@property NSMutableArray *tabBarItemArray;
@property NSMutableArray *viewContArray;

@property (weak) UINavigationController *navCont;
@property NSString* accessToken;

@property NSOperationQueue *queue;


- (id) initWithNavigationController:(UINavigationController*)nNavCont withAccessTokens:(NSString*)apiToken;

@end
