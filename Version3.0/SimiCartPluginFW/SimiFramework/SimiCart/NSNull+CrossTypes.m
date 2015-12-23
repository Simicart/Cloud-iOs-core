//
//  NSNull+CrossTypes.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 12/10/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import <objc/runtime.h>
#import "NSNull+CrossTypes.h"

@implementation NSNull (CrossTypes)

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if (class_getInstanceMethod([NSNumber class], aSelector)) {
        return @0;
    } else if (class_getInstanceMethod([NSString class], aSelector)) {
        return @"";
    } else if (class_getInstanceMethod([NSArray class], aSelector)) {
        return @[];
    } else if (class_getInstanceMethod([NSDictionary class], aSelector)) {
        return @{};
    } else if (class_getInstanceMethod([NSMutableArray class], aSelector)) {
        return [NSMutableArray new];
    } else if (class_getInstanceMethod([NSMutableDictionary class], aSelector)) {
        return [NSMutableDictionary new];
    }
    return nil;
}

@end
