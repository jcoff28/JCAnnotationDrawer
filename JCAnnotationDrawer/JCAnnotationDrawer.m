//
//  JCAnnotationDrawer.m
//  JCAnnotationDrawer
//
//  Created by Jordan Coff on 11/9/16.
//  Copyright © 2016 JordanCoff. All rights reserved.
//

#import "JCAnnotationDrawer.h"

@implementation JCAnnotationDrawer {
    NSMutableDictionary<NSString*,NSMutableArray*>* _queuedMoves;
    NSMutableDictionary* _lastAnnotationPointsByRepId;
}


-(id)initWithMainView:(UIImageView *)mainView tempView:(UIImageView *)tempView {
    self = [super init];
    if (self) {
        _mainView = mainView;
        _tempView = tempView;
    }
    return self;
}

-(id)initWithMainView:(UIImageView *)mainView tempView:(UIImageView *)tempView queueCapacity:(int)queueCapacity {
    self = [super init];
    if (self) {
        _mainView = mainView;
        _tempView = tempView;
        _queueCapacity = queueCapacity;
    }
    return self;
}


-(void) handleAnnotation:(JCAnnotationState)state x:(CGFloat)x y:(CGFloat)y userId:(NSString*)userId width:(CGFloat)width red:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
    
    if (state == JCAnnotationStateStart) {
        if (!_lastAnnotationPointsByRepId) {
            _lastAnnotationPointsByRepId = [NSMutableDictionary new];
        }
        if (_queueCapacity == 0) {
            NSLog(@"Queue capacity not set before the first annotation was received. Set to default: %d", DEFAULT_QUEUE_CAPACITY);
            _queueCapacity = DEFAULT_QUEUE_CAPACITY;
        }
        if (!_queuedMoves) {
            _queuedMoves = [NSMutableDictionary new];
        }
        if (!_queuedMoves[userId]) {
            _queuedMoves[userId] = [NSMutableArray new];
        }
        
        _lastAnnotationPointsByRepId[userId] = [NSValue valueWithCGPoint:CGPointMake(x, y)];
    }
    else if (state == JCAnnotationStateMove) {
        
        if (width <= 0) {
            width = 10.0;
        }
        
        [_queuedMoves[userId] addObject:[[AnnotationMove alloc] initWithState:JCAnnotationStateMove x:x y:y userId:userId width:width red:red green:green blue:blue]];
        
        if ([_queuedMoves[userId] count] >= _queueCapacity) {
            //flush the queue
            [self flushQueueForUserId:userId];
        }
    }
    else if (state == JCAnnotationStateStop) {
        
        NSLog(@"%s", __PRETTY_FUNCTION__);
        
        [self flushQueueForUserId:userId];
        
        [_queuedMoves[userId] removeAllObjects];
        
        [self saveTempImageToMainImage];
    }
    else if (state == JCAnnotationStateCancelled) {
        NSLog(@"%s - CANCELLED", __PRETTY_FUNCTION__);
        _tempView.image = nil;
        [_queuedMoves[userId] removeAllObjects];
    }
}

-(void)clear {
    _mainView.image = nil;
    _tempView.image = nil;
}

-(void) flushQueueForUserId:(NSString*)userId {
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (!_queuedMoves || !_queuedMoves[userId] || [_queuedMoves[userId] count] <= 0) {
        return;
    }
    if (!_tempView || !_mainView) {
        NSLog(@"Didn't set a temp view or main view");
        return;
    }
    
    UIGraphicsBeginImageContext(_mainView.frame.size);
    [_tempView.image drawInRect:CGRectMake(0, 0, _mainView.frame.size.width, _mainView.frame.size.height)];
    
    
    CGPoint lastPoint = [_lastAnnotationPointsByRepId[userId] CGPointValue];
    
    AnnotationMove* lastMove = [_queuedMoves[userId] lastObject];
    _lastAnnotationPointsByRepId[userId] = [NSValue valueWithCGPoint:CGPointMake(lastMove.x, lastMove.y)];
    
    while (_queuedMoves && _queuedMoves[userId] && [_queuedMoves[userId] count] > 0) {
        
        AnnotationMove* point = _queuedMoves[userId][0];
        [_queuedMoves[userId] removeObjectAtIndex:0];
        
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), point.x, point.y);
        
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), point.width);
        
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), point.red, point.green, point.blue, 1.0);
        
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
        
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        
        lastPoint = CGPointMake(point.x, point.y);
    }
    
    _tempView.image = UIGraphicsGetImageFromCurrentImageContext();
    [_tempView setAlpha:1.0];
    
    UIGraphicsEndImageContext();
}

- (void) saveTempImageToMainImage
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    UIGraphicsBeginImageContext(_mainView.frame.size);
    [_mainView.image drawInRect:CGRectMake(0, 0, _mainView.frame.size.width, _mainView.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [_tempView.image drawInRect:CGRectMake(0, 0, _mainView.frame.size.width, _mainView.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    _mainView.image = UIGraphicsGetImageFromCurrentImageContext();
    _tempView.image = nil;
    UIGraphicsEndImageContext();
}

@end

@implementation AnnotationMove

-(id)initWithState:(JCAnnotationState)state x:(CGFloat) x y:(CGFloat) y userId:(NSString*) userId width:(CGFloat) width red:(CGFloat) red green:(CGFloat) green blue:(CGFloat) blue {
    self = [super init];
    if (self) {
        _state = state;
        _x = x;
        _y = y;
        _userId = userId;
        _width = width;
        _red = red;
        _green = green;
        _blue = blue;
    }
    return self;
}

+(id)annotationStartWithUserId:(NSString*)userId x:(CGFloat)x y:(CGFloat)y {
    return [[AnnotationMove alloc] initWithState:JCAnnotationStateStart x:x y:y userId:userId width:0 red:0 green:0 blue:0];
}

@end

