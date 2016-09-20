//
//  LoyaltyAPI.h
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 1/16/15.
//  Copyright (c) 2015 Magestore. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

@interface LoyaltyAPI : SimiAPI

- (void)loadProgramOverviewWithTarget:(id)target selector:(SEL)selector;

- (void)loadTransactionWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;

- (void)spendPointsWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;

- (void)saveSettings:(NSDictionary *)target selector:(SEL)selector;

@end
