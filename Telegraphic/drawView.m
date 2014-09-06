//
//  drawView.m
//  Telegraphic
//
//  Created by Kenneth Siu on 9/6/14.
//  Copyright (c) 2014 Base Twelve. All rights reserved.
//

#import "DrawView.h"

@implementation DrawView {
    CGPoint lastPoint;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat brush;
    CGFloat opacity;
    BOOL mouseSwiped;
    
    CGFloat difference;
    
    BOOL pinch;
}

@synthesize tempDrawImage, panGesture, isEditable;

- (id)initWithFrame:(CGRect)frame difference:(CGFloat) nDifference isEditable:(BOOL)nIsEditable
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //initialize colors and brushes
        red = 0.0/255.0;
        green = 0.0/255.0;
        blue = 0.0/255.0;
        brush = 5.0;
        opacity = 1.0;
        difference = nDifference;
        
        isEditable = nIsEditable;
        
        //drawing context is everything but the bottom buttons
        tempDrawImage = [[UIImageView alloc] initWithFrame:[self frame]];
        
        [self addSubview:tempDrawImage];
        
        if(isEditable) {
            panGesture = [[UIPanGestureRecognizer
                          alloc] initWithTarget:self action:@selector(handlePan:)];
            [panGesture setDelegate:self];
            [self addGestureRecognizer:panGesture];
        }
        
    }
    return self;
}

-(IBAction)handlePan:(UIPanGestureRecognizer*)recognizer {
    
    if(recognizer.state == UIGestureRecognizerStateBegan) {
        //mouse has not mouved yet
        mouseSwiped = NO;
        
        //check the last point that has been touched
        lastPoint = [recognizer locationInView:nil];
        lastPoint.y += (difference * (lastPoint.y / [self frame].size.height));
        
    } else if(recognizer.state == UIGestureRecognizerStateChanged) {
        
        mouseSwiped = YES;
        CGPoint currentPoint = [recognizer locationInView:nil];
        currentPoint.y += (difference * (currentPoint.y / [self frame].size.height));
        
        UIGraphicsBeginImageContext(self.superview.frame.size);
        [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.superview.frame.size.width, self.superview.frame.size.height)];
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
        
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
        [self.tempDrawImage setAlpha:opacity];
        UIGraphicsEndImageContext();
        
        lastPoint = currentPoint;
        
    } else if(recognizer.state == UIGestureRecognizerStateEnded) {
        
        if(!mouseSwiped) {
            UIGraphicsBeginImageContext(self.superview.frame.size);
            [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.superview.frame.size.width, self.superview.frame.size.height)];
            CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
            CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
            CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, opacity);
            CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
            CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
            CGContextStrokePath(UIGraphicsGetCurrentContext());
            CGContextFlush(UIGraphicsGetCurrentContext());
            self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        
        UIGraphicsBeginImageContext(self.superview.frame.size);
        [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.superview.frame.size.width, self.superview.frame.size.height) blendMode:kCGBlendModeNormal alpha:opacity];
        self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
}

- (void) setColorRed:(CGFloat)nRed green:(CGFloat)nGreen blue:(CGFloat)nBlue {
    red = nRed;
    green = nGreen;
    blue = nBlue;
}

- (void) setBrush:(CGFloat) nBrush {
    brush *= nBrush;
    
    if(brush > 20.0f) {
        brush = 20.0f;
    } else if(brush < 0.5f) {
        brush = 0.5f;
    }
}

- (CGFloat) getBrushSize {
    return brush;
}

- (void) setPinch:(BOOL)nPinch {
    pinch = nPinch;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
