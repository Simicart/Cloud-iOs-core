//
//  SimiFormNumber.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiFormNumber.h"

@implementation SimiFormNumber

- (instancetype)initWithConfig:(NSDictionary *)config
{
    if (self = [super initWithConfig:config]) {
        [self.inputText setKeyboardType:UIKeyboardTypeDecimalPad];
    }
    return self;
}

@end
