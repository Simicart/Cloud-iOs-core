//
//  SimiAppAPI.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/26/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiAppAPI.h"

@implementation SimiAppAPI

- (void)registerDeviceWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiRegisterDevice];
    [self requestWithMethod:POST URL:url params:params target:target selector:selector header:nil];
}

@end
