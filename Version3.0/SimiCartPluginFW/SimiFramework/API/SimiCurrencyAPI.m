//
//  SimiCurrencyAPI.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/25/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SimiCurrencyAPI.h"
NSString *const kSimiGetListCurrency = @"simicategory/api/get_currencies";
NSString *const kSimiSaveCurrency = @"simicategory/api/save_currency";
@implementation SimiCurrencyAPI
- (void)saveCurrencyWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiSaveCurrency];
    [self requestWithURL:url params:params target:target selector:selector header:nil];
}
- (void)getCurrencyCollectionWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiGetListCurrency];
    [self requestWithURL:url params:params target:target selector:selector header:nil];
}
@end
