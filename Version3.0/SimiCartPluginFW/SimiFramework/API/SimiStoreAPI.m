//
//  SimiStoreAPI.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/17/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiStoreAPI.h"

@implementation SimiStoreAPI

- (void)getStoreWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiSettings];
    [self requestWithMethod:GET URL:url params:params target:target selector:selector header:nil];
}

- (void)getStoreCollectionWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    
}

- (void)getThemeConfigureParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kThemeConfigure];
    [self requestWithMethod:GET URL:url params:params target:target selector:selector header:nil];
}

@end
