//
//  SimiOrderModelCollection.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/4/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiModelCollection.h"
#import "SimiOrderModel.h"
#import "SimiOrderAPI.h"

@interface SimiOrderModelCollection : SimiModelCollection

/*
 Notification name: DidGetOrderCollection
 */
- (void)getCustomerOrderCollectionWithParams:(NSDictionary* ) params;

@end
