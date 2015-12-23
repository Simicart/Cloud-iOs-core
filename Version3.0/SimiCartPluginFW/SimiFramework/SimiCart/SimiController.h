//
//  SimiController.h
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimiController : NSObject

// Weak retain view __ need check nil for init and deinit methods
@property (weak, nonatomic) UIView *view;

// Init and DeInit controllers for view
- (void)initControllerForView;
- (void)deinitControllerForview;

@end
