//
//  SimiCart.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiCart.h"
#import "SimiGlobalVar.h"
#import "SCAppDelegate.h"

@implementation SimiCart

#pragma mark - Block structure in SimiCart
+ (SimiBlock *)rootBlock
{
    static SimiBlock *root;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        root = [self createBlock:@"SimiBlock"];
    });
    return root;
}

+ (SimiBlock *)createBlock:(NSString *)aClass
{
    if (THEME_NAME) {
        Class themeClass = NSClassFromString([THEME_NAME stringByAppendingString:aClass]);
        if (themeClass) {
            return [themeClass new];
        }
    }
    Class blockClass = NSClassFromString(aClass);
    if (blockClass) {
        return [blockClass new];
    }
    return [SimiBlock new];
}

#pragma mark - View tree global access
+ (UIView *)overlayer
{
    static UIView *overlayer;
    if (overlayer == nil) {
        overlayer = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    if ([overlayer superview] == nil) {
        [[self rootView] addSubview:overlayer];
    }
    [[self rootView] bringSubviewToFront:overlayer];
    return overlayer;
}

+ (UIWindow *)mainWindow
{
    SCAppDelegate *delegate = (SCAppDelegate *)[[UIApplication sharedApplication] delegate];
    return delegate.window;
}

+ (UIView *)rootView
{
    SCAppDelegate *delegate = (SCAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (delegate.window.rootViewController) {
        return delegate.window.rootViewController.view;
    }
    return nil;
}

+ (NSArray *)findViews:(NSString *)pattern
{
    return [[self rootView] allSubviews:pattern];
}

+ (UIView *)view:(NSString *)pattern
{
    return [[self rootView] down:pattern];
}

@end
