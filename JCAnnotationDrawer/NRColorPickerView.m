//
//  NRColorPickerView.m
//  Nurep
//
//  Created by Jordan Coff on 10/11/16.
//  Copyright © 2016 Nurep. All rights reserved.
//

#import "NRColorPickerView.h"
#define IPAD  UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

@implementation NRColorPickerView {
    NSArray* _colors;
    NSMutableArray* _circles;
}

-(id)initWithFrame:(CGRect)frame colors:(NSArray*)colors {
    self = [super initWithFrame:frame];
    if (self) {
        _colors = colors;
        [self commonInit];
    }
    return self;
}

-(void)commonInit {
    _circles = [NSMutableArray new];
    CGFloat dim = self.frame.size.width * .5 / (CGFloat)[_colors count];
    NSLog(@"Dim: %f", dim);
    for (int i = 0; i < [_colors count]; i++) {
        NRColorCircleView* circle = [[NRColorCircleView alloc] initWithFrame:CGRectMake(0, 0, dim, dim) color:_colors[i]];
        circle.delegate = self;
        [_circles addObject:circle];
        [self addSubview:circle];
        [self addConstraints:@[
                               [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:circle attribute:NSLayoutAttributeCenterY multiplier:1 constant:0],
                               [NSLayoutConstraint constraintWithItem:circle attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:(i+1.)/([_colors count] + 1.) constant:0]
                               ]];
    }
    [_circles[0] setSelected:YES];
    [self setCurrentColor:_colors[0]];
    
    if (!(IPAD)) {
        [self setBackgroundColor:[UIColor colorWithWhite:.8 alpha:.7]];
        self.layer.cornerRadius = 10.;
        self.clipsToBounds = YES;
    }
}


-(void)circleViewWasSelected:(id)circleView {
    for (NRColorCircleView* c in _circles) {
        if (![c isEqual:circleView]) {
            [c setSelected:NO];
        }
    }
    [self setCurrentColor:((NRColorCircleView*)circleView).color];
    [_delegate colorChanged:_currentColor];
}


-(void)setCurrentColor:(UIColor *)currentColor {
    _currentColor = currentColor;
    
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    // iOS 5
    if ([currentColor respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [currentColor getRed:&red green:&green blue:&blue alpha:&alpha];
    } else {
        // < iOS 5
        const CGFloat *components = CGColorGetComponents(currentColor.CGColor);
        red = components[0];
        green = components[1];
        blue = components[2];
        alpha = components[3];
    }
    
    // This is a non-RGB color
    if(CGColorGetNumberOfComponents(currentColor.CGColor) == 2) {
        CGFloat hue;
        CGFloat saturation;
        CGFloat brightness;
        [currentColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    }
    _red = red;
    _green = green;
    _blue = blue;
}

@end


@implementation NRColorCircleView {
    UIView* _blackDot;
}

-(id)initWithFrame:(CGRect)frame color:(UIColor *)color {
    
    self = [super initWithFrame:frame];
    if (self) {
        _color = color;
        [self commonInit];
    }
    return self;
}

-(void) commonInit {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    _selected = NO;
    [self addConstraints:@[
                           [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:self.frame.size.height],
                           [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:self.frame.size.width]
                           ]];
    self.layer.cornerRadius = self.frame.size.height / 2.;
    self.backgroundColor = _color;
    self.layer.borderWidth = 0;
    self.layer.borderColor = [UIColor blackColor].CGColor;
    
    CGFloat blackDotRatio = .3;
    _blackDot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.height * blackDotRatio, self.frame.size.height*blackDotRatio)];
    _blackDot.translatesAutoresizingMaskIntoConstraints = NO;
    _blackDot.hidden = YES;
    
    if (![_color isEqual:[UIColor blackColor]]) {
        _blackDot.backgroundColor = [UIColor blackColor];
    }
    else {
        _blackDot.backgroundColor = [UIColor colorWithWhite:.7 alpha:1.];
    }
    
    _blackDot.layer.cornerRadius = _blackDot.frame.size.height/2.;
    [self addSubview:_blackDot];
    
    [self addConstraints:@[
                           [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_blackDot attribute:NSLayoutAttributeCenterX multiplier:1 constant:0],
                           [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_blackDot attribute:NSLayoutAttributeCenterY multiplier:1 constant:0],
                           [NSLayoutConstraint constraintWithItem:_blackDot attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:blackDotRatio constant:0],
                           [NSLayoutConstraint constraintWithItem:_blackDot attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_blackDot attribute:NSLayoutAttributeWidth multiplier:1 constant:0]
                           ]];
    [self setNeedsLayout];
    UITapGestureRecognizer* tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
    [self addGestureRecognizer:tapgr];
}

-(void) setSelected:(BOOL)selected {
    
    _selected = selected;
    //self.layer.borderColor = selected ? [UIColor blackColor].CGColor : [UIColor whiteColor].CGColor;
    self.layer.borderWidth = selected ? 2 : 0;
    
    _blackDot.hidden = !selected;
}


-(void)didTap {
    if (!_selected) {
        [self setSelected:YES];
        [_delegate circleViewWasSelected:self];
    }
}


@end
