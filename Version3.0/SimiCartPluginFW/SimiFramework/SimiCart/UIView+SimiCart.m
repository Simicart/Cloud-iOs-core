//
//  UIView+SimiCart.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import <objc/runtime.h>
#import "UIView+SimiCart.h"
#import "SimiController.h"
#import "SimiTreeView.h"

@implementation UIView (SimiCart)
// Class Property
+ (NSMutableArray *)initMethods:(SEL)aSelector
{
    static NSMutableDictionary *initMethods;
    if (initMethods == nil) {
        initMethods = [NSMutableDictionary new];
    }
    NSString *klass = NSStringFromClass(self);
    NSMutableArray *methods = [initMethods objectForKey:klass];
    if (aSelector) {
        if (methods == nil) {
            methods = [NSMutableArray new];
            [initMethods setValue:methods forKey:klass];
        }
        [methods addObject:NSStringFromSelector(aSelector)];
    }
    return methods;
}

+ (BOOL)initWithFrameFlags:(BOOL)flag
{
    static NSMutableDictionary *initViewFlags;
    if (initViewFlags == nil) {
        initViewFlags = [NSMutableDictionary new];
    }
    NSString *klass = NSStringFromClass(self);
    if (flag) {
        if ([initViewFlags objectForKey:klass]) {
            return YES;
        }
        [initViewFlags setValue:[NSNull null] forKey:klass];
    } else {
        [initViewFlags removeObjectForKey:klass];
    }
    return NO;
}

- (instancetype)initWithFrameSimiCart:(CGRect)frame
{
    if ([self.class initWithFrameFlags:YES]) {
        // Forward message to original method
        SEL aSelector = NSSelectorFromString([NSStringFromClass(self.class) stringByAppendingString:@"init"]);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([self respondsToSelector:aSelector]) {
            [self performSelector:aSelector];
        }
#pragma clang diagnostic pop
        return self;
    }
    if (self = [self initWithFrameSimiCart:frame]) {
        // Execute Custom Layout for Class
        NSArray *methods = [self.class initMethods:nil];
        if ([methods count]) {
            for (NSString *method in methods) {
                SEL aSelector = NSSelectorFromString(method);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self performSelector:aSelector];
#pragma clang diagnostic pop
            }
        }
        [self.class initWithFrameFlags:NO];
    }
    return self;
}

+ (void)superload
{
    static NSMutableDictionary *superloads;
    if (superloads == nil) {
        superloads = [NSMutableDictionary new];
    }
    NSString *klass = NSStringFromClass(self);
    if ([superloads objectForKey:klass]) {
        return;
    }
    [superloads setValue:[NSNull null] forKey:klass];
    NSString *selectorName = [klass stringByAppendingString:@"init"];
    class_addMethod(self, NSSelectorFromString(selectorName), method_getImplementation(class_getInstanceMethod(self, @selector(initWithFrame:))), "v@:");
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(initWithFrame:)), class_getInstanceMethod(self, @selector(initWithFrameSimiCart:)));
}

// Object properties
- (void)setBlock:(SimiBlock *)block
{
    objc_setAssociatedObject(self, @selector(block), block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SimiBlock *)block
{
    return objc_getAssociatedObject(self, @selector(block));
}

- (void)setControllers:(NSMutableArray *)controllers
{
    objc_setAssociatedObject(self, @selector(controllers), controllers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)controllers
{
    return objc_getAssociatedObject(self, @selector(controllers));
}

// Working with block
- (void)assignBlock:(SimiBlock *)block
{
    self.block = block;
    block.view = self;
}

// Working with controllers
- (void)addController:(NSObject *)controller
{
    if (self.controllers == nil) {
        self.controllers = [NSMutableArray new];
    }
    if ([controller isKindOfClass:[SimiController class]]) {
        [(SimiController *)controller setView:self];
    }
    [self.controllers addObject:controller];
}

- (void)removeController:(NSObject *)controller
{
    if (self.controllers) {
        [self.controllers removeObject:controller];
        if ([controller isKindOfClass:[SimiController class]]) {
            [(SimiController *)controller deinitControllerForview];
        }
    }
}

- (void)removeAllControllers
{
    [self.controllers removeAllObjects];
}

// Working with view tree
- (UIView *)down:(NSString *)pattern
{
    return [[SimiTreeView getAlgorithm] down:pattern fromView:self];
}

- (UIView *)up:(NSString *)pattern
{
    return [[SimiTreeView getAlgorithm] up:pattern fromView:self];
}

- (NSArray *)allSubviews:(NSString *)pattern
{
    return [[SimiTreeView getAlgorithm] allSubviews:pattern ofView:self];
}

- (void)replaceBy:(UIView *)view
{
    if (self.superview == nil) {
        return;
    }
    UIView *superview = self.superview;
    [self removeFromSuperview];
    [superview addSubview:view];
}

// Copy a view
- (instancetype)clone
{
    NSData *archivedViewData = [NSKeyedArchiver archivedDataWithRootObject:self];
    id clone = [NSKeyedUnarchiver unarchiveObjectWithData:archivedViewData];
    return clone;
}

@end
