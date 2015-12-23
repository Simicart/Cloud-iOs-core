//
//  SimiCurrencyModelCollection.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/25/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SimiCurrencyModelCollection.h"

@implementation SimiCurrencyModelCollection
- (void)getCurrencyCollection{
    currentNotificationName = @"DidGetCurrencyCollection";
    [self preDoRequest];
    [(SimiCurrencyAPI *)[self getAPI] getCurrencyCollectionWithParams:nil target:self selector:@selector(didFinishRequest:responder:)];
}
@end
