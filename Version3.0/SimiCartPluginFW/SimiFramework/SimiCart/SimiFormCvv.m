//
//  SimiFormCvv.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiFormCvv.h"

@implementation SimiFormCvv

- (instancetype)initWithConfig:(NSDictionary *)config
{
    if (self = [super initWithConfig:config]) {
        [self.inputText setKeyboardType:UIKeyboardTypeNumberPad];
    }
    return self;
}

@end
