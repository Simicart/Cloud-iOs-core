//
//  LoyaltyAPI.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 1/16/15.
//  Copyright (c) 2015 Magestore. All rights reserved.
//

#import "LoyaltyAPI.h"

@implementation LoyaltyAPI

- (void)loadProgramOverviewWithTarget:(id)target selector:(SEL)selector
{
    NSString *url = [NSString stringWithFormat:@"%@loyalty/point/home", kBaseURL];
    [self requestWithURL:url params:nil target:target selector:selector header:nil];
}

- (void)loadTransactionWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    NSString *url = [NSString stringWithFormat:@"%@loyalty/point/history", kBaseURL];
    [self requestWithURL:url params:params target:target selector:selector header:nil];
}

- (void)spendPointsWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    NSString *url = [NSString stringWithFormat:@"%@loyalty/point/spend", kBaseURL];
    [self requestWithURL:url params:params target:target selector:selector header:nil];
}

- (void)saveSettings:(NSDictionary *)target selector:(SEL)selector
{
     NSString *url = [NSString stringWithFormat:@"%@loyalty/point/settings", kBaseURL];
    [self requestWithURL:url params:target target:target selector:selector header:nil];
}

@end
