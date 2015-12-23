//
//  SimiFormName.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 12/1/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiFormName.h"

@implementation SimiFormName

- (instancetype)initWithConfig:(NSDictionary *)config
{
    if (self = [super initWithConfig:config]) {
        [self.inputText setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    }
    return self;
}

@end
