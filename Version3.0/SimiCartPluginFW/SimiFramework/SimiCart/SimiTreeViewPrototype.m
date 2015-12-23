//
//  SimiTreeViewPrototype.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/17/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiTreeViewPrototype.h"

// Pattern Object
@implementation SimiTreeViewPrototypePattern
@synthesize className = _className, name = _name, identify = _identify;

- (instancetype)initWithString:(NSString *)pattern
{
    if (self = [super init]) {
        // [className][.name][#identify]
        NSArray *parts = [pattern componentsSeparatedByString:@"."];
        if ([parts count] == 2) {
            [self initPatternParts:(NSString *)[parts objectAtIndex:0]];
            NSArray *nameAndIds = [(NSString *)[parts objectAtIndex:1] componentsSeparatedByString:@"#"];
            self.name = [nameAndIds objectAtIndex:0];
            if ([nameAndIds count] == 2) {
                self.identify = [nameAndIds objectAtIndex:1];
            }
        } else {
            [self initPatternParts:pattern];
        }
    }
    return self;
}

// [className][#identify]
- (void)initPatternParts:(NSString *)pattern
{
    NSArray *classAndIds = [pattern componentsSeparatedByString:@"#"];
    NSString *className = [classAndIds objectAtIndex:0];
    if (className != nil && ![className isEqualToString:@""]) {
        self.className = className;
    }
    if ([classAndIds count] == 2) {
        self.identify = [classAndIds objectAtIndex:1];
    }
}

// Check view is matched with this pattern
- (BOOL)match:(UIView *)view
{
    if (self.className && ![NSStringFromClass(view.class) isEqualToString:self.className]) {
        return NO;
    }
    if (self.name && ![self.name isEqualToString:view.simiObjectName]) {
        return NO;
    }
    if (self.identify) {
        if ([view.simiObjectIdentifier isKindOfClass:[NSString class]]) {
            if (![self.identify isEqualToString:(NSString *)view.simiObjectIdentifier]) {
                return NO;
            }
        } else {
            return NO;
        }
    }
    return YES;
}

@end

// Prototype Algorithm
@implementation SimiTreeViewPrototype

#pragma mark - Algorithm methods
- (UIView *)down:(NSString *)pattern fromView:(UIView *)view
{
    NSArray *patternObj = [self patternObj:pattern];
    if ([patternObj count]) {
        return [self findDown:patternObj index:0 fromView:view];
    }
    return nil;
}

- (UIView *)up:(NSString *)pattern fromView:(UIView *)view
{
    if (pattern == nil || [pattern isEqualToString:@""] || [pattern isEqualToString:@" "]) {
        return view.superview;
    }
    SimiTreeViewPrototypePattern *patternObj = [[self patternObj:pattern] objectAtIndex:0];
    while (view.superview) {
        view = view.superview;
        if ([patternObj match:view]) {
            return view;
        }
    }
    return nil;
}

- (NSArray *)allSubviews:(NSString *)pattern ofView:(UIView *)view
{
    NSArray *patternObj = [self patternObj:pattern];
    if ([patternObj count]) {
        NSMutableArray *result = [NSMutableArray new];
        [self findSubviews:result withPatterns:patternObj index:0 fromView:view];
        if ([result count]) {
            return result;
        }
    }
    return nil;
}

#pragma mark - Analysis methods
- (NSArray *)patternObj:(NSString *)pattern
{
    NSArray *parts = [pattern componentsSeparatedByString:@" "];
    NSMutableArray *objs = [NSMutableArray new];
    for (NSString *child in parts) {
        if ([child isEqualToString:@""]) {
            continue;
        }
        [objs addObject:[[SimiTreeViewPrototypePattern alloc] initWithString:child]];
    }
    return objs;
}

- (UIView *)findDown:(NSArray *)pattern index:(NSUInteger)index fromView:(UIView *)view
{
    SimiTreeViewPrototypePattern *patternObj = (SimiTreeViewPrototypePattern *)[pattern objectAtIndex:index];
    // Terminal
    if (index == [pattern count] - 1) {
        return [self downView:patternObj fromView:view];
    }
    // Loop To Find
    for (UIView *subview in view.subviews) {
        if ([patternObj match:subview]) {
            // Continue find with next level
            UIView *found = [self findDown:pattern index:(index + 1) fromView:subview];
            if (found) {
                return found;
            }
        } else {
            // Find in current level
            UIView *found = [self findDown:pattern index:index fromView:subview];
            if (found) {
                return found;
            }
        }
    }
    return nil;
}

- (UIView *)downView:(SimiTreeViewPrototypePattern *)pattern fromView:(UIView *)view
{
    // Ignore root view - Find in subviews
    for (UIView *aView in view.subviews) {
        if ([pattern match:aView]) {
            return aView;
        }
        UIView *found = [self downView:pattern fromView:aView];
        if (found) {
            return found;
        }
    }
    return nil;
}

- (void)findSubviews:(NSMutableArray *)result withPatterns:(NSArray *)patterns index:(NSUInteger)index fromView:(UIView *)view
{
    SimiTreeViewPrototypePattern *patternObj = (SimiTreeViewPrototypePattern *)[patterns objectAtIndex:index];
    // Terminal
    if (index == [patterns count] - 1) {
        return [self subviews:result withPattern:patternObj fromView:view];
    }
    // Loop To Find All
    for (UIView *subview in view.subviews) {
        if ([patternObj match:subview]) {
            // Continue find with next level
            [self findSubviews:result withPatterns:patterns index:(index + 1) fromView:subview];
        } else {
            // Find in current level
            [self findSubviews:result withPatterns:patterns index:index fromView:subview];
        }
    }
}

- (void)subviews:(NSMutableArray *)result withPattern:(SimiTreeViewPrototypePattern *)pattern fromView:(UIView *)view
{
    // Ignore root view - Find in subviews
    for (UIView *subview in view.subviews) {
        if ([pattern match:subview]) {
            [result addObject:subview];
        }
        [self subviews:result withPattern:pattern fromView:subview];
    }
}

@end
