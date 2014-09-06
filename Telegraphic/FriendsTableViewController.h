//
//  FriendsTableViewController.h
//  Telegraphic
//
//  Created by Kenneth Siu on 9/6/14.
//  Copyright (c) 2014 Base Twelve. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FriendsTableDelegate <NSObject>

-(void) sendImage:(NSString*)text;

@end

@interface FriendsTableViewController : UITableViewController

@property NSOperationQueue *queue;
@property NSMutableArray *arrOfFriends;
@property id<FriendsTableDelegate> delegate;

@property NSString *accessToken;

@property NSTimer *friendsTimer;

-(id)initWithAccessToken:(NSString*)apiToken;

@end
