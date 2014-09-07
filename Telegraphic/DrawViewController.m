//
//  DrawViewController.m
//  Telegraphic
//
//  Created by Kenneth Siu on 9/6/14.
//  Copyright (c) 2014 Base Twelve. All rights reserved.
//

#import "DrawViewController.h"
#import <QuartzCore/QuartzCore.h>

#define NUM_BUTTONS 4

@interface DrawViewController ()

@end

@implementation DrawViewController {
    CGPoint lastPoint;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat brush;
    CGFloat opacity;
    BOOL mouseSwiped;
    
    CGPoint origPoint1;
    CGPoint origPoint2;
    
    UIButton *selectedButton;
    int count;
}

@synthesize drawing, blueButton, redButton, greenButton, blackButton, brushScaleLabel, navCont, timer, timerLabel, delegate, text, isEditable, imageNow, isNew, backLabel;

- (id)initWithNavViewController:(UINavigationController*)nNavCont withTime:(NSNumber*)nTime withText:(NSString *)nText withImage:(UIImage*)image isEditable:(BOOL)nIsEditable isCreate:(BOOL)isCreate{
    
    self = [super init];
    
    if(self) {
        navCont = nNavCont;
        timer = nTime;
        text = nText;
        imageNow = image;
        isEditable = nIsEditable;
        isNew = isCreate;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    

    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    //now add buttons (black, rgb, and erase)
    
    float heightOfButton = [self.view frame].size.height / 10;
    
     float originHeightOfButton = [self.view frame].size.height - heightOfButton;
    
    float widthOfButton = [self.view frame].size.width / NUM_BUTTONS;
    
    //move picture down when it is just viewing
    if(!isEditable && !isNew) {
        //now set the drawing view above the main view
        drawing = [[DrawView alloc] initWithFrame:CGRectMake(0, 0, [self.view frame].size.width, [self.view frame].size.height) difference:0 isEditable:isEditable];
        
        drawing.tempDrawImage.image = imageNow;
    } else {
        //now set the drawing view above the main view
        drawing = [[DrawView alloc] initWithFrame:CGRectMake(0, 0, [self.view frame].size.width, originHeightOfButton) difference:heightOfButton isEditable:isEditable];
        
        drawing.tempDrawImage.image = imageNow;
    }
    
    
    [self.view addSubview:drawing];
    
    //set a timer
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerHit:) userInfo:nil repeats:YES];
    
    timerLabel = [[UIOutlineLabel alloc] initWithFrame:CGRectMake(0, 0, [self.view frame].size.width, heightOfButton)];
    [timerLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.view addSubview:timerLabel];
    
    if(!isEditable && !isNew) {
        return;
    }
    
    //set custom button type
    
    blackButton = [[UIButton alloc] initWithFrame:CGRectMake(0, originHeightOfButton, [self.view frame].size.width / NUM_BUTTONS, heightOfButton * 2)];
    
    redButton = [[UIButton alloc] initWithFrame:CGRectMake(blackButton.frame.origin.x + blackButton.frame.size.width, originHeightOfButton, widthOfButton, heightOfButton * 2)];
    
    greenButton = [[UIButton alloc] initWithFrame:CGRectMake(redButton.frame.origin.x + redButton.frame.size.width, originHeightOfButton, widthOfButton, heightOfButton * 2)];
    
    blueButton = [[UIButton alloc] initWithFrame:CGRectMake(greenButton.frame.origin.x + greenButton.frame.size.width, originHeightOfButton, widthOfButton, heightOfButton * 2)];
    
    
    //now initialize the colors of the button
    [blackButton setBackgroundColor:[UIColor blackColor]];
    [redButton setBackgroundColor:[UIColor redColor]];
    [greenButton setBackgroundColor:[UIColor greenColor]];
    [blueButton setBackgroundColor:[UIColor blueColor]];
    
    [self.view addSubview:blackButton];
    [self.view addSubview:redButton];
    [self.view addSubview:greenButton];
    [self.view addSubview:blueButton];
    
    [blackButton addTarget:self action:@selector(setColor:) forControlEvents:UIControlEventTouchDown];
    [redButton addTarget:self action:@selector(setColor:) forControlEvents:UIControlEventTouchDown];
    [greenButton addTarget:self action:@selector(setColor:) forControlEvents:UIControlEventTouchDown];
    [blueButton addTarget:self action:@selector(setColor:) forControlEvents:UIControlEventTouchDown];
    
    selectedButton = blackButton;
    
    //add the pinch recognizer
    UIPinchGestureRecognizer *pinch =[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [pinch setDelegate:self];
    [self.view addGestureRecognizer:pinch];
    
    //add label
    brushScaleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, originHeightOfButton - heightOfButton, [self.view frame].size.width, heightOfButton)];
    
    //now add text
    [brushScaleLabel setTextAlignment:NSTextAlignmentCenter];
    [brushScaleLabel setText:[NSString stringWithFormat:@"Brush Size: %f", [drawing getBrushSize]]];
    [brushScaleLabel setTextColor:[UIColor whiteColor]];
    
    //now add back label
    backLabel = [[UILabel alloc] initWithFrame:brushScaleLabel.frame];
    [backLabel setBackgroundColor:[UIColor blackColor]];
    
    
    [brushScaleLabel setBackgroundColor:[UIColor clearColor]];
    
    [self.view addSubview:brushScaleLabel];
    [self.view addSubview:backLabel];
    
    [self.view bringSubviewToFront:brushScaleLabel];
    [self.view sendSubviewToBack:backLabel];
    
    [self.view sendSubviewToBack:drawing];
    
    count = 0;
}

-(IBAction)timerHit:(NSTimer*)sender {
    
    int counter = [timer intValue] - count;
    //now that timer is hit, keep checking
    [timerLabel setText:[NSString stringWithFormat:@"%d", [timer intValue] - count]];
    
    count++;
    
    if(counter == 0) {
        [sender invalidate];
        
        if(isNew && isEditable) {
            [delegate newImageCreate:drawing.tempDrawImage.image withNextUser:text];
        } else if(isEditable) {
            [delegate editImage:drawing.tempDrawImage.image withNextUser:text];
        } else {
            [delegate finishedImage:drawing.tempDrawImage.image];
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

-(IBAction)setColor:(id)sender {
    //set the previous selected button border's to clear color
    
    //now set new button to purple color
    selectedButton = sender;
    
    //now check to see what button it is
    if([sender isEqual:blackButton]) {
        [drawing setColorRed:0.0 green:0.0 blue:0.0];
    } else if([sender isEqual:redButton]) {
        [drawing setColorRed:1.0 green:0.0 blue:0.0];
    } else if([sender isEqual:greenButton]) {
        [drawing setColorRed:0.0 green:1.0 blue:0.0];
    } else if([sender isEqual:blueButton]) {
        [drawing setColorRed:0.0 green:0.0 blue:1.0];
    }
    
    [UIView transitionWithView:backLabel duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [backLabel setBackgroundColor:[sender backgroundColor]];
        
    } completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    
    [drawing setPinch:YES];
    
    if(recognizer.state == UIGestureRecognizerStateEnded){
        [drawing setPinch:NO];
    }
    
    //set the brush
    [drawing setBrush:recognizer.scale];
    
    [brushScaleLabel setText:[NSString stringWithFormat:@"Brush Size: %f", [drawing getBrushSize]]];
    
    recognizer.scale = 1;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
