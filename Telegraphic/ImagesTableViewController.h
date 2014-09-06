//
//  ImagesTableViewController.h
//  Telegraphic
//
//  Created by Kenneth Siu on 9/6/14.
//  Copyright (c) 2014 Base Twelve. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawViewController.h"

@interface ImagesTableViewController : UITableViewController <DrawViewDelegate>

@property NSString* accessToken;
@property NSOperationQueue *queue;
@property NSMutableArray *arrOfPrevUsers;
@property NSMutableArray *arrOfUUID;
@property NSMutableArray *arrOfHops;
@property NSMutableArray *arrOfBase64;

@property (weak) UINavigationController *navCont;

@property NSTimer *imageTimer;

@property NSString* tempUUID;

-(id) initWithAccessToken:(NSString*)apiToken withNavigationController:(UINavigationController*)nNavCont;

@end
