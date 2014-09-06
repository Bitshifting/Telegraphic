//
//  DrawViewController.m
//  Telegraphic
//
//  Created by Kenneth Siu on 9/6/14.
//  Copyright (c) 2014 Base Twelve. All rights reserved.
//

#import "DrawViewController.h"
#import <QuartzCore/QuartzCore.h>

#define NUM_BUTTONS 5
#define BORDER_WIDTH 3.0f

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

@synthesize drawing, blueButton, redButton, greenButton, blackButton, eraseButton, brushScaleLabel, navCont, timer, timerLabel, delegate, text, isEditable, imageNow;

- (id)initWithNavViewController:(UINavigationController*)nNavCont withTime:(NSNumber*)nTime withText:(NSString *)nText {
    
    self = [super init];
    
    if(self) {
        navCont = nNavCont;
        timer = nTime;
        text = nText;
        isEditable = YES;
    }
    
    return self;
}

- (id)initWithNavViewController:(UINavigationController*)nNavCont withTime:(NSNumber*)nTime withText:(NSString *)nText withImage:(UIImage*)image isEditable:(BOOL)nIsEditable {
    
    self = [super init];
    
    if(self) {
        navCont = nNavCont;
        timer = nTime;
        text = nText;
        imageNow = image;
        isEditable = nIsEditable;
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
    
    
    //set custom button type
    
    blackButton = [[UIButton alloc] initWithFrame:CGRectMake(0, originHeightOfButton, [self.view frame].size.width / NUM_BUTTONS, heightOfButton)];
    
    redButton = [[UIButton alloc] initWithFrame:CGRectMake(blackButton.frame.origin.x + blackButton.frame.size.width, originHeightOfButton, widthOfButton, heightOfButton)];
    
    greenButton = [[UIButton alloc] initWithFrame:CGRectMake(redButton.frame.origin.x + redButton.frame.size.width, originHeightOfButton, widthOfButton, heightOfButton)];
    
    blueButton = [[UIButton alloc] initWithFrame:CGRectMake(greenButton.frame.origin.x + greenButton.frame.size.width, originHeightOfButton, widthOfButton, heightOfButton)];
    
    eraseButton = [[UIButton alloc] initWithFrame:CGRectMake(blueButton.frame.origin.x + blueButton.frame.size.width, originHeightOfButton, widthOfButton, heightOfButton)];
    
    
    //now initialize the colors of the button
    [blackButton setBackgroundColor:[UIColor blackColor]];
    [redButton setBackgroundColor:[UIColor redColor]];
    [greenButton setBackgroundColor:[UIColor greenColor]];
    [blueButton setBackgroundColor:[UIColor blueColor]];
    
    [eraseButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [eraseButton setTitle:@"Erase" forState:UIControlStateNormal];
    
    //border width
    [blackButton.layer setBorderWidth:BORDER_WIDTH];
    [redButton.layer setBorderWidth:BORDER_WIDTH];
    [greenButton.layer setBorderWidth:BORDER_WIDTH];
    [blueButton.layer setBorderWidth:BORDER_WIDTH];
    [eraseButton.layer setBorderWidth:BORDER_WIDTH];
    
    [self.view addSubview:blackButton];
    [self.view addSubview:redButton];
    [self.view addSubview:greenButton];
    [self.view addSubview:blueButton];
    [self.view addSubview:eraseButton];

    //set black button as selected color and the rest as clear
    [blackButton.layer setBorderColor:[[UIColor purpleColor] CGColor]];
    [redButton.layer setBorderColor:[[UIColor clearColor] CGColor]];
    [greenButton.layer setBorderColor:[[UIColor clearColor] CGColor]];
    [blueButton.layer setBorderColor:[[UIColor clearColor] CGColor]];
    [eraseButton.layer setBorderColor:[[UIColor clearColor] CGColor]];
    
    [blackButton addTarget:self action:@selector(setColor:) forControlEvents:UIControlEventTouchDown];
    [redButton addTarget:self action:@selector(setColor:) forControlEvents:UIControlEventTouchDown];
    [greenButton addTarget:self action:@selector(setColor:) forControlEvents:UIControlEventTouchDown];
    [blueButton addTarget:self action:@selector(setColor:) forControlEvents:UIControlEventTouchDown];
    [eraseButton addTarget:self action:@selector(setColor:) forControlEvents:UIControlEventTouchDown];
    
    selectedButton = blackButton;
    
    //now set the drawing view above the main view
    drawing = [[DrawView alloc] initWithFrame:CGRectMake(0, 0, [self.view frame].size.width, originHeightOfButton) difference:heightOfButton isEditable:isEditable];
    
    drawing.tempDrawImage.image = imageNow;
    
    [self.view addSubview:drawing];
    
    //set a timer
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerHit:) userInfo:nil repeats:YES];
    
    timerLabel = [[UIOutlineLabel alloc] initWithFrame:CGRectMake(0, 0, [self.view frame].size.width, heightOfButton)];
    [timerLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.view addSubview:timerLabel];
    
    if(!isEditable) {
        return;
    }
    
    //add the pinch recognizer
    UIPinchGestureRecognizer *pinch =[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [pinch setDelegate:self];
    [self.view addGestureRecognizer:pinch];
    
    //add label
    brushScaleLabel = [[UIOutlineLabel alloc] initWithFrame:CGRectMake(0, originHeightOfButton - heightOfButton, [self.view frame].size.width, heightOfButton)];
    
    //now add text
    [brushScaleLabel setTextAlignment:NSTextAlignmentCenter];
    [brushScaleLabel setText:[NSString stringWithFormat:@"Brush Size: %f", [drawing getBrushSize]]];
    [brushScaleLabel setTextColor:[UIColor whiteColor]];
    
    [self.view addSubview:brushScaleLabel];
    
    count = 0;
}

-(IBAction)timerHit:(NSTimer*)sender {
    
    int counter = [timer intValue] - count;
    //now that timer is hit, keep checking
    [timerLabel setText:[NSString stringWithFormat:@"%d", [timer intValue] - count]];
    
    count++;
    
    if(counter == 0) {
        [sender invalidate];
        
        [delegate drawViewEnded:drawing.tempDrawImage.image withText:text isEditable:isEditable];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

-(IBAction)setColor:(id)sender {
    //set the previous selected button border's to clear color
    [selectedButton.layer setBorderColor:[[UIColor clearColor] CGColor]];
    
    //now set new button to purple color
    selectedButton = sender;
    [selectedButton.layer setBorderColor:[[UIColor purpleColor] CGColor]];
    
    //now check to see what button it is
    if([sender isEqual:blackButton]) {
        [drawing setColorRed:0.0 green:0.0 blue:0.0];
    } else if([sender isEqual:redButton]) {
        [drawing setColorRed:1.0 green:0.0 blue:0.0];
    } else if([sender isEqual:greenButton]) {
        [drawing setColorRed:0.0 green:1.0 blue:0.0];
    } else if([sender isEqual:blueButton]) {
        [drawing setColorRed:0.0 green:0.0 blue:1.0];
    } else if([sender isEqual:eraseButton]) {
        [drawing setColorRed:1.0 green:1.0 blue:1.0];
    }

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
