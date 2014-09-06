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
#import "EveryoneTableTableViewController.h"

@interface TabViewController : UITabBarController <FriendsTableDelegate, EveryoneTableDelegate, DrawViewDelegate>

@property NSMutableArray *tabBarItemArray;
@property NSMutableArray *viewContArray;

@property NSString* accessToken;

@property FriendsTableViewController *friendVC;
@property EveryoneTableTableViewController *everyVC;

@property NSOperationQueue *queue;


@property BOOL isEditable;
@property BOOL isCreate;

@property NSString *UUID;

@property UIImage *image;

- (id) initWithImage:(UIImage*)nImage withAccessToken:(NSString*)apiToken isEditable:(BOOL)nIsEditable isCreate:(BOOL)nIsCreate withUUID:(NSString*)nUUID;

@end
