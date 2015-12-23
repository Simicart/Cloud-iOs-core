//
//  SimiResponder.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/7/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiResponder.h"

@implementation SimiResponder

@synthesize status, message, error, other;

- (id)init
{
    self = [super init];
    if (self) {
        status = @"";
        message = nil;
        error = nil;
    }
    return self;
}

- (NSString *)responseMessage{
    return self.message;
}

@end
