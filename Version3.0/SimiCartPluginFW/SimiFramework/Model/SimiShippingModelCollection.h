//
//  SimiShippingModelCollection.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/19/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiModelCollection.h"
#import "SimiShippingModel.h"

@interface SimiShippingModelCollection : SimiModelCollection


/*
 Notification name: DidAddShippingMethod
 */
- (void)addShippingAddressForQuote:(NSString *)quoteId withParams:(NSMutableDictionary *)params;

@end
