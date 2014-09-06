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

@interface DrawViewController : UIViewController <UIGestureRecognizerDelegate>

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

@end
