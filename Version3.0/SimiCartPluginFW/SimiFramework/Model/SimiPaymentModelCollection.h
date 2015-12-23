//
//  SimiPaymentModelCollection.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/19/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiModelCollection.h"

@interface SimiPaymentModelCollection : SimiModelCollection

/*
 Notification name: DidAddBillingMethod
 */
- (void)addBillingAddressForQuote:(NSString *)quoteId withParams:(NSMutableDictionary *)params;

@end
