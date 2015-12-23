//
//  SimiBlock.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiBlock.h"
#import "UIView+SimiCart.h"

NSString *const SimiBlockWillShowViewNotification = @"SimiBlockWillShowViewNotification";
NSString *const SimiBlockDidShowViewNotification = @"SimiBlockDidShowViewNotification";

@implementation SimiBlock
@synthesize delegate = _delegate;
@synthesize view = _view, parentBlock = _parentBlock, childBlocks = _childBlocks;

#pragma mark - Working with block tree
- (void)addChildBlock:(SimiBlock *)block
{
    if (self.childBlocks == nil) {
        self.childBlocks = [NSMutableArray new];
    }
    [self.childBlocks addObject:block];
    block.parentBlock = self;
    // Add child block view to the view tree
    if (self.view) {
        [block showViewIn:self.view];
    }
}

- (void)removeChild:(SimiBlock *)block
{
    [self.childBlocks removeObject:block];
    block.parentBlock = nil;
    if (block.view) {
        [block.view removeFromSuperview];
    }
}

- (void)removeFromParent
{
    if (self.parentBlock) {
        [self.parentBlock removeChild:self];
    }
}

- (BOOL)replaceBy:(SimiBlock *)block
{
    // Replace View
    if (self.view) {
        [self.view assignBlock:block];
        self.view = nil;
    }
    // Update link from Parent
    [block removeFromParent];
    if (self.parentBlock) {
        [self.parentBlock addChildBlock:block];
    }
    [self removeFromParent];
    // Remove all children
    self.childBlocks = nil;
    return YES;
}

- (void)replaceView:(UIView *)view
{
    if (self.view) {
        [self.view replaceBy:view];
    }
    [view assignBlock:self];
}

#pragma mark - Working with view
- (UIView *)showView
{
    return [self showViewIn:nil];
}

- (UIView *)showViewIn:(UIView *)parent
{
    if ([self willShowView:parent]) {
        if (self.view) { // Unlink Block from Current View
            self.view.block = nil;
            if (parent == nil) {
                parent = self.view.superview;
            }
        }
        // Show view with current view linked
        UIView *view = [self showingView:self.view on:parent];
        if (parent) {
            if (view == nil) {
                view = [UIView new];
            }
            [parent addSubview:view];
        }
        if (view) { // Assign block to view
            if (self.view && ![self.view isEqual:view]) {
                [self.view removeFromSuperview];
            }
            [view assignBlock:self];
        }
        [self didShowView];
        return view;
    }
    return nil;
}

#pragma mark - Showing View
- (BOOL)willShowView:(UIView *)parent
{
    if (parent) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SimiBlockWillShowViewNotification object:self userInfo:@{@"parent": parent}];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SimiBlockWillShowViewNotification object:self];
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if ([self.delegate respondsToSelector:@selector(willShowViewPad:)]) {
            return [self.delegate willShowViewPad:parent];
        }
    }
    if ([self.delegate respondsToSelector:@selector(willShowViewPhone:)]) {
        return [self.delegate willShowViewPhone:parent];
    }
    return YES;
}

- (UIView *)showingView:(UIView *)view on:(UIView *)parent
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if ([self.delegate respondsToSelector:@selector(showingViewPad:on:)]) {
            return [self.delegate showingViewPad:view on:parent];
        }
    }
    if ([self.delegate respondsToSelector:@selector(showingViewPhone:on:)]) {
        return [self.delegate showingViewPhone:view on:parent];
    }
    return view;
}

- (void)didShowView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SimiBlockDidShowViewNotification object:self];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if ([self.delegate respondsToSelector:@selector(didShowViewPad)]) {
            return [self.delegate didShowViewPad];
        }
    }
    if ([self.delegate respondsToSelector:@selector(didShowViewPhone)]) {
        [self.delegate didShowViewPhone];
    }
}

@end
