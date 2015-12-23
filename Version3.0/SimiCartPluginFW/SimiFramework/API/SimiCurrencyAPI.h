//
//  SimiCurrencyAPI.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/25/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SimiCartBundle.h"
#import "SimiAPI.h"
extern NSString *const kSimiGetListCurrency;
extern NSString *const kSimiSaveCurrency;
@interface SimiCurrencyAPI : SimiAPI
- (void)saveCurrencyWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
- (void)getCurrencyCollectionWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
@end
