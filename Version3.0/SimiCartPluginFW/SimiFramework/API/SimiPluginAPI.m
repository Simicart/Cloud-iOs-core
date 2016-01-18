//
//  SimiPluginAPI.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/23/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiPluginAPI.h"

@implementation SimiPluginAPI

- (void)getActivePluginsWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kActivePlugins];
    [self requestWithMethod:GET URL:url params:params target:target selector:selector header:nil];
}

- (void)getSitePluginsWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSitePlugins];
    [self requestWithMethod:GET URL:url params:params target:target selector:selector header:nil];
}

@end
