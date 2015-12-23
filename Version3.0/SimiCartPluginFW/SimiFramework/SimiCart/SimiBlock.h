//
//  SimiBlock.h
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiCartBundle.h"

extern NSString *const SimiBlockWillShowViewNotification;
extern NSString *const SimiBlockDidShowViewNotification;

// Simi Block Delegate
@protocol SimiBlockDelegate <NSObject>
@optional
// iPhone Delegate
- (BOOL)willShowViewPhone:(UIView *)parent;
- (UIView *)showingViewPhone:(UIView *)view on:(UIView *)parent;
- (void)didShowViewPhone;

// iPad Delegate, implement if you want to difference between iPad and iPhone
- (BOOL)willShowViewPad:(UIView *)parent;
- (UIView *)showingViewPad:(UIView *)view on:(UIView *)parent;
- (void)didShowViewPad;

@end

// Simi Block Main Class
@interface SimiBlock : SimiMutableDictionary
@property (assign, nonatomic) id<SimiBlockDelegate> delegate;

@property (weak, nonatomic) UIView *view;
@property (weak, nonatomic) SimiBlock *parentBlock;
@property (strong, nonatomic) NSMutableArray *childBlocks;

// Working with block tree
- (void)addChildBlock:(SimiBlock *)block;
- (void)removeChild:(SimiBlock *)block;
- (void)removeFromParent;

- (BOOL)replaceBy:(SimiBlock *)block;
- (void)replaceView:(UIView *)view;

// Working with view
- (UIView *)showView;
- (UIView *)showViewIn:(UIView *)parent;

// Showing View
- (BOOL)willShowView:(UIView *)parent;
- (UIView *)showingView:(UIView *)view on:(UIView *)parent;
- (void)didShowView;

@end
