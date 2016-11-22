//
//  JCAnnotationDrawer.h
//  JCAnnotationDrawer
//
//  Created by Jordan Coff on 11/9/16.
//  Copyright © 2016 JordanCoff. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define DEFAULT_QUEUE_CAPACITY 5


/*!
 * @typedef JCAnnotationState
 * @brief The state of the Annotation
 * @constant JCAnnotationStateStart Annotation is starting
 * @constant JCAnnotationStateMove Annotation is moving
 * @constant JCAnnotationStateStop Annotation is stopping
 * @constant JCAnnotationStateCancelled Annotation is cancelled
 */
typedef NS_ENUM(NSInteger, JCAnnotationState) {
    JCAnnotationStateStart = 28280,
    JCAnnotationStateMove = 28281,
    JCAnnotationStateStop = 28282,
    JCAnnotationStateCancelled = 28283
};

@interface JCAnnotationDrawer : NSObject

/*!
 * @brief Initializes a new instance of an annotation drawer.
 * @param mainView The image view which displays the annotations
 * @param tempView The image view which displays the annotation that is currently being drawn. Should be a sibling the same size as mainView. When an annotation ends drawing, it get's transfered over to the mainView and the tempView gets cleared.
 */
-(id)initWithMainView:(UIImageView*)mainView tempView:(UIImageView*)tempView;

/*!
 * @brief Initializes a new instance of an annotation drawer.
 * @param mainView The image view which displays the annotations
 * @param tempView The image view which displays the annotation that is currently being drawn. Should be a sibling the same size as mainView. When an annotation ends drawing, it get's transfered over to the mainView and the tempView gets cleared.
 * @param queueCapacity Annotation Moves get queued up and drawn in batch when the queue is full. This param dictates the capacity of that queue. A low value might lead to lagging due to performance limits. A high value will lead to granular, segment by segment, drawing
 */
-(id)initWithMainView:(UIImageView *)mainView tempView:(UIImageView *)tempView queueCapacity:(int)queueCapacity;

/*!
 * @brief Draws the annotation. Make sure to start with a JCAnnotationStateStart and end with an JCAnnotationStateStop or Cancelled.
 * @warning All variables are normalized from 0 - 1. Width should be normalized by the WIDTH of the view. For example if the width of the annotation is 10, and the width of the image views is 100, send this method .1 as the width.
 */
-(void) handleAnnotation:(JCAnnotationState)state x:(CGFloat)x y:(CGFloat)y userId:(NSString*)userId  width:(CGFloat)width red:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;

/*!
 * @brief Clears annotations. You can do this yourself if you want to by doing the following
 * @code mainView.image = nil;
 tempView.image = nil;
 * @endcode
 * @warning Don't call this in the middle of an annotation. Don't be that guy. Nobody likes that guy.
 */
-(void)clear;

@property (nonatomic, weak) UIImageView* mainView;
@property (nonatomic, weak) UIImageView* tempView;
@property (nonatomic) int queueCapacity;

@end



@interface AnnotationMove : NSObject
@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic) NSString* userId;
@property (nonatomic) CGFloat  width;
@property (nonatomic) CGFloat red;
@property (nonatomic) CGFloat green;
@property (nonatomic) CGFloat blue;
@property (nonatomic) JCAnnotationState state;

-(id)initWithState:(JCAnnotationState)state x:(CGFloat) x y:(CGFloat) y userId:(NSString*) userId width:(CGFloat) width red:(CGFloat) red green:(CGFloat) green blue:(CGFloat) blue;

@end

static inline UIColor* JCMakeColor(CGFloat r, CGFloat g, CGFloat b) {return [UIColor colorWithRed:(r/255.0f) green:(g/255.0f) blue:(b/255.0f) alpha:1.0f];}
