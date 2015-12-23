//
//  SimiCartSelector.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/19/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiCartSelector.h"

@implementation SimiCartSelector
@synthesize target = _target, action = _action;

- (instancetype)initWithTarget:(id)target action:(SEL)action
{
    if (self = [super init]) {
        self.target = target;
        self.action = action;
    }
    return self;
}

- (void)invoke:(id)object
{
    if (self.target) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:self.action withObject:object];
#pragma clang diagnostic pop
    }
}

@end
