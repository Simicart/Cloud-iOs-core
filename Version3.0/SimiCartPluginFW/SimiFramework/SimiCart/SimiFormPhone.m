//
//  SimiFormPhone.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/24/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiFormPhone.h"

@implementation SimiFormPhone

- (instancetype)initWithConfig:(NSDictionary *)config
{
    if (self = [super initWithConfig:config]) {
        [self.inputText setKeyboardType:UIKeyboardTypePhonePad];
    }
    return self;
}

@end
