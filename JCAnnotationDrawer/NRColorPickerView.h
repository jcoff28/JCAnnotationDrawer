//
//  NRColorPickerView.h
//  Nurep
//
//  Created by Jordan Coff on 10/11/16.
//  Copyright © 2016 Nurep. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NRCircleViewDelegate <NSObject>
-(void)circleViewWasSelected:(id)circleView;
@end

@protocol NRColorPickerDelegate <NSObject>
-(void)colorChanged:(UIColor*)color;
@end

@interface NRColorPickerView : UIView <NRCircleViewDelegate>

-(id)initWithFrame:(CGRect)frame colors:(NSArray*)colors;
@property (nonatomic) UIColor* currentColor;
@property (nonatomic, weak) id<NRColorPickerDelegate> delegate;

@property (nonatomic, readonly) CGFloat red;
@property (nonatomic, readonly) CGFloat green;
@property (nonatomic, readonly) CGFloat blue;

@end



@interface NRColorCircleView : UIView
-(id)initWithFrame:(CGRect)frame color:(UIColor*)color;
@property (nonatomic) BOOL selected;
@property (nonatomic) UIColor* color;
@property (nonatomic, weak) id<NRCircleViewDelegate> delegate;
@end













