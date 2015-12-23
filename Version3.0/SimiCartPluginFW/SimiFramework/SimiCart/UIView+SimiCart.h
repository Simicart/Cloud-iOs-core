//
//  UIView+SimiCart.h
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimiBlock.h"

@interface UIView (SimiCart)
// Add Object Name for a UIView in Interface Builder
@property (strong, nonatomic) IBInspectable NSString *simiObjectName;

// Class Property
//@property (strong, nonatomic) NSMutableArray *initMethods;
+ (NSMutableArray *)initMethods:(SEL)aSelector;
// Category need implement +load to
// 1. add init methods
// 2. call superload to run when a view is created
// Example
// + load {
//      [self initMethods:@selector(aFormatMethod)];
//      [self superload];
// }
+ (void)superload;

// Object Properties
@property (strong, nonatomic) SimiBlock *block;
@property (strong, nonatomic) NSMutableArray *controllers;

// Working with block
- (void)assignBlock:(SimiBlock *)block;

// Working with controller
- (void)addController:(NSObject *)controller;
- (void)removeController:(NSObject *)controller;
- (void)removeAllControllers;

// Working with View tree
- (UIView *)down:(NSString *)pattern;
- (UIView *)up:(NSString *)pattern;
- (NSArray *)allSubviews:(NSString *)pattern;

- (void)replaceBy:(UIView *)view;

// Copy a view
- (instancetype)clone;

@end
