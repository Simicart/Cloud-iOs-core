//
//  LoyaltyModelCollection.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 1/27/15.
//  Copyright (c) 2015 Magestore. All rights reserved.
//

#import "LoyaltyModelCollection.h"
#import "LoyaltyAPI.h"

@implementation LoyaltyModelCollection

- (void)getTransactionsWithOffset:(NSInteger)offset limit:(NSInteger)limit
{
    currentNotificationName = @"DidGetLoyaltyTransactions";
    [self preDoRequest];
    modelActionType = ModelActionTypeInsert;
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:[NSNumber numberWithInteger:offset] forKey:@"offset"];
    [params setValue:[NSNumber numberWithInteger:limit] forKey:@"limit"];
    
    [(LoyaltyAPI *)[self getAPI] loadTransactionWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}

@end
