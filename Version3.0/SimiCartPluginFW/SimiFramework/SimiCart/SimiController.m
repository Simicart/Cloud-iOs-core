//
//  SimiController.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiController.h"

@implementation SimiController
@synthesize view = _view;

- (void)initControllerForView
{
    // Init target for view
}

- (void)deinitControllerForview
{
    // Remove target for view
}

- (void)dealloc
{
    [self deinitControllerForview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
