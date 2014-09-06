//
//  DrawViewController.h
//  Telegraphic
//
//  Created by Kenneth Siu on 9/6/14.
//  Copyright (c) 2014 Base Twelve. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawView.h"
#import "UIOutlineLabel.h"

@protocol DrawViewDelegate <NSObject>

-(void) drawViewEnded:(UIImage*)nImage withText:(NSString*)nText;

@end


@interface DrawViewController : UIViewController <UIGestureRecognizerDelegate>

//delegate
@property id<DrawViewDelegate> delegate;

//draw and erase buttons
@property UIButton *blueButton;
@property UIButton *redButton;
@property UIButton *greenButton;
@property UIButton *blackButton;
@property UIButton *eraseButton;

//drawing view
@property DrawView *drawing;

//scale of brush label
@property UIOutlineLabel *brushScaleLabel;
@property UIOutlineLabel *timerLabel;

//text to pass through
@property NSString *text;

//timer and navigation controller
@property (weak) UINavigationController *navCont;
@property NSNumber *timer;

- (id)initWithNavViewController:(UINavigationController*)nNavCont withTime:(NSNumber*)nTime withText:(NSString*)nText;

@end
