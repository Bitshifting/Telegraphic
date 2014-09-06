//
//  drawView.h
//  Telegraphic
//
//  Created by Kenneth Siu on 9/6/14.
//  Copyright (c) 2014 Base Twelve. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawView : UIView <UIGestureRecognizerDelegate>

@property UIImageView *tempDrawImage;

@property UIPanGestureRecognizer *panGesture;

@property BOOL isEditable;

- (id)initWithFrame:(CGRect)frame difference:(CGFloat) nDifference isEditable:(BOOL)nIsEditable;

- (void) setColorRed:(CGFloat)nRed green:(CGFloat)nGreen blue:(CGFloat)nBlue;

- (void) setBrush:(CGFloat) nBrush;

- (CGFloat) getBrushSize;

- (void) setPinch:(BOOL)nPinch;

@end
