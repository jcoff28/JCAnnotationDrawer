//
//  ViewController.h
//  JCAnnotationDrawer
//
//  Created by Jordan Coff on 11/9/16.
//  Copyright © 2016 JordanCoff. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCAnnotationDrawer.h"
#import "NRColorPickerView.h"

@interface ViewController : UIViewController <NRColorPickerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *tempDrawImage;
@property (strong, nonatomic) IBOutlet UIImageView *mainImage;

@property (strong, nonatomic) IBOutlet UIButton *colorPickerButton;

@end

