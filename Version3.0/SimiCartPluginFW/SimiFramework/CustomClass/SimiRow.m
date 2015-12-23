//
//  SimiRow.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/25/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiRow.h"
#import "SimiCartSelector.h"

@implementation SimiRow {
    NSMutableArray *actions;
}

@synthesize data, accessoryType;

- (instancetype)initWithIdentifier:(NSString *)identifier height:(double)height{
    self = [super init];
    if (self) {
        _identifier = identifier;
        _height = (CGFloat) height;
    }
    return self;
}

#pragma mark - Working with Row and action
- (instancetype)initWithIdentifier:(NSString *)identifier height:(CGFloat)height sortOrder:(NSInteger)order
{
    if (self = [super init]) {
        _identifier = identifier;
        _height = height;
        _sortOrder = order;
    }
    return self;
}

- (void)addTarget:(id)target action:(SEL)action
{
    if (actions == nil) {
        actions = [NSMutableArray new];
    }
    [actions addObject:[[SimiCartSelector alloc] initWithTarget:target action:action]];
}

- (void)addTargetUsingBlock:(void (^)())block
{
    if (actions == nil) {
        actions = [NSMutableArray new];
    }
    [actions addObject:block];
}

- (void)invokeActions
{
    for (id action in actions) {
        if ([action isKindOfClass:[SimiCartSelector class]]) {
            [(SimiCartSelector *)action invoke:self];
        } else {
            ((void (^)())action)();
        }
    }
}

@end
