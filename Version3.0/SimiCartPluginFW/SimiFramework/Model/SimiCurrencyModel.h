//
//  SimiCurrencyModel.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/25/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SimiCartBundle.h"
#import "SimiCurrencyAPI.h"
@interface SimiCurrencyModel : SimiModel
- (void)saveCurrency:(NSDictionary*)param;
- (void)saveToLocal:(NSString*)currencyCode;
@end
