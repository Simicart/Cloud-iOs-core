//
//  SimiCurrencyModel.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/25/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SimiCurrencyModel.h"

@implementation SimiCurrencyModel
- (void)saveCurrency:(NSDictionary*)param
{
    currentNotificationName = @"DidSaveCurrency";
    [self preDoRequest];
    [(SimiCurrencyAPI *)[self getAPI] saveCurrencyWithParams:param target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)saveToLocal:(NSString*)currencyCode{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *librarayPath = [paths objectAtIndex:0];
    NSString *currencyConfigFilePath = [librarayPath stringByAppendingPathComponent:@"CurrencyConfig.plist"];
    NSDictionary *currencyConfig = [[NSDictionary alloc]initWithObjects:@[currencyCode] forKeys:@[@"currency_code"]];
    [currencyConfig writeToFile:currencyConfigFilePath atomically:YES];
}
@end
