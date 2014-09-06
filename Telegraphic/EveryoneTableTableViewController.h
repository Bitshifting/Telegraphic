//
//  EveryoneTableTableViewController.h
//  Telegraphic
//
//  Created by Kenneth Siu on 9/6/14.
//  Copyright (c) 2014 Base Twelve. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EveryoneTableDelegate <NSObject>

-(void) sendImageEveryone:(NSString*)text;

@end

@interface EveryoneTableTableViewController : UITableViewController <UIGestureRecognizerDelegate, UIAlertViewDelegate>

@property NSOperationQueue *queue;
@property NSMutableArray *arrOfEveryone;
@property id<EveryoneTableDelegate> delegate;

@property NSTimer *everyoneTimer;

@property NSString *accessToken;
@property NSString *temporaryName;

-(id)initWithAccessToken:(NSString*)apiToken;

@end
