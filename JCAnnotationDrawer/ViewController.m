//
//  ViewController.m
//  JCAnnotationDrawer
//
//  Created by Jordan Coff on 11/9/16.
//  Copyright © 2016 JordanCoff. All rights reserved.
//

#import "ViewController.h"
#define IPAD  UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
#define MY_USER_ID @"Jordan Andrew Coff"

@interface ViewController ()

@end

@implementation ViewController {
    JCAnnotationDrawer* _annotationDrawer;
    NRColorPickerView* _colorPicker;
    UIViewController* _colorPickerVC;
    
    //Precalculate the values used to convert force of a touch to line width
    CGFloat _slope;
    CGFloat _intercept;
    CGFloat _minForce;
    CGFloat _screenWidth;
    
    //Configurable values
    
    //The width of a line if the force is 1 (or on a device without force touch)
    CGFloat _baseline;
    
    //Smallest possible width of a line
    CGFloat _minWidth;
    
    ///Maximum possible width of a line
    CGFloat _maxWidth;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //////// Tweak these values as needed ////////
    
    _maxWidth = IPAD ? 30. : 20;
    _baseline = IPAD ? 10. : 6;
    _minWidth = IPAD ? 2. : 1;
    
    //Maximum possible force of a touch. The value of which actually gets set on a UITouch object, but we use the hardcoded value so we can precalculate the values below and speed up performance slightly. Don't change these values unless Apple changes their values and you know what you're doing.
    CGFloat mpf = IPAD ? 25./6. : 20./3.;
    
    _slope = (_maxWidth-_baseline)/(mpf - 1.f);
    _intercept = _baseline - _slope;
    _minForce = (_minWidth - _intercept) / _slope;
    _screenWidth = MAX(_mainImage.frame.size.width, _mainImage.frame.size.height);
    
    //////////////////////////////////////////////
    
    
    _annotationDrawer = [[JCAnnotationDrawer alloc] initWithMainView:_mainImage tempView:_tempDrawImage queueCapacity:1];
    
    [self colorPickerPressed:nil];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    UITouch* touch = [touches anyObject];
    CGPoint p = [touch locationInView:_mainImage];
    
    [_annotationDrawer handleAnnotation:JCAnnotationStateStart x:p.x y:p.y userId:MY_USER_ID width:0 red:0 green:0 blue:0];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    for (UITouch* touch in [event coalescedTouchesForTouch:[touches anyObject]]) {
        
        CGPoint p = [touch locationInView:_mainImage];
        
        [_annotationDrawer handleAnnotation:JCAnnotationStateMove x:p.x y:p.y userId:MY_USER_ID width:[self widthForTouch:touch] red:_colorPicker.red green:_colorPicker.green blue:_colorPicker.blue];
    }
    
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    UITouch* touch = [touches anyObject];
    CGPoint p = [touch locationInView:_mainImage];
    
    [_annotationDrawer handleAnnotation:JCAnnotationStateStop x:p.x y:p.y userId:MY_USER_ID width:[self widthForTouch:touch] red:_colorPicker.red green:_colorPicker.green blue:_colorPicker.blue];
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [_annotationDrawer handleAnnotation:JCAnnotationStateCancelled x:0 y:0 userId:MY_USER_ID width:0 red:0 green:0 blue:0];
}


-(CGFloat)widthForTouch:(UITouch *)touch {
    
    //If the device doesn't support force touch, return baseline
    if(touch.maximumPossibleForce <= 0) {
        return _baseline;
    }
    
    //We precalculated _minForce so that any value below it returns _minWidth with no calculation required
    if (touch.force <= _minForce) {
        return _minWidth;
    }
    
    return _slope*touch.force+_intercept;;
}


- (IBAction)colorPickerPressed:(id)sender {
    
    if (!_colorPicker) {
        _colorPicker = [[NRColorPickerView alloc] initWithFrame: CGRectMake(0, 0, 300, 65)
                                                         colors:@[
                                                                  JCMakeColor(32,   187,  252), //blue
                                                                  JCMakeColor(45,   253,  47),  //green
                                                                  JCMakeColor(252,  40,   249), //pink
                                                                  JCMakeColor(234,  33,   45),  //red
                                                                  JCMakeColor(253,  126,  35),  //orange
                                                                  JCMakeColor(255,  250,  55),  //yellow
                                                                  JCMakeColor(255,  255,  255)  //white
                                                                  ]];
        _colorPicker.delegate = self;
    }
    if (!_colorPickerVC) {
        _colorPickerVC = [[UIViewController alloc] init];
        [_colorPickerVC loadViewIfNeeded];
        [_colorPickerVC.view setFrame:_colorPicker.bounds];
        [_colorPickerVC.view addSubview:_colorPicker];
    }
    
    if (!sender) {
        return;
    }
    
    if (IPAD) {
        _colorPickerVC.popoverPresentationController.sourceView = _colorPickerButton;
        _colorPickerVC.popoverPresentationController.sourceRect = CGRectMake(_colorPickerButton.frame.size.width/2., 0, 10, 10);
        _colorPickerVC.modalPresentationStyle = UIModalPresentationPopover;
        _colorPickerVC.preferredContentSize = _colorPicker.frame.size;
        _colorPickerVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
        
        [self presentViewController:_colorPickerVC animated:YES completion:nil];
        
        _colorPickerVC.popoverPresentationController.sourceView = _colorPickerButton;
        _colorPickerVC.popoverPresentationController.sourceRect = CGRectMake(_colorPickerButton.frame.size.width/2., 0, 10, 10);
        _colorPickerVC.modalPresentationStyle = UIModalPresentationPopover;
        _colorPickerVC.preferredContentSize = _colorPicker.frame.size;
        _colorPickerVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    }
    else {
//        [self addChildViewController:secondChildVC];
//        [secondChildVC didMoveToParentViewController:self];
//        secondChildVC.view.frame = CGRectMake(0,0,160,504);
//        [self.view addSubview:secondChildVC.view];
        [self addChildViewController:_colorPickerVC];
        [_colorPickerVC didMoveToParentViewController:self];
        _colorPickerVC.view.frame = CGRectMake(_colorPickerButton.center.x - _colorPickerVC.view.frame.size.width/2., _colorPickerButton.frame.origin.y - _colorPickerVC.view.frame.size.height - 10., _colorPickerVC.view.frame.size.width, _colorPickerVC.view.frame.size.height);
        [self.view addSubview:_colorPickerVC.view];
    }
}

-(void)colorChanged:(UIColor *)color {
    _colorPickerButton.backgroundColor = color;
    if (IPAD) {
        [_colorPickerVC dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [_colorPickerVC willMoveToParentViewController:nil];
        [_colorPickerVC.view removeFromSuperview];
        [_colorPickerVC removeFromParentViewController];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
