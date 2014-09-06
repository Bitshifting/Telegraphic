//
//  ImagesTableViewController.h
//  Telegraphic
//
//  Created by Kenneth Siu on 9/6/14.
//  Copyright (c) 2014 Base Twelve. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImagesTableDelegate <NSObject>

-(void) viewImage:(NSString*)text;

@end


@interface ImagesTableViewController : UITableViewController


@property NSString* accessToken;
@property NSOperationQueue *queue;
@property NSMutableArray *arrOfImages;
@property NSMutableArray *arrOfUUID;
@property id<ImagesTableDelegate> delegate;

-(id) initWithAccessToken:(NSString*)apiToken;

@end
