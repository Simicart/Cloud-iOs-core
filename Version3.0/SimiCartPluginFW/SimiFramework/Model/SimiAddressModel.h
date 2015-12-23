//
//  SimiAddressModel.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/19/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiCustomerModel.h"

@interface SimiAddressModel : SimiCustomerModel

/*
 Notification name: DidSaveAddress
 */
- (void)saveToServerWithCustomerId:(NSString *)customerId;

/*
 Notification name: DidSaveAddress
 */
- (void)saveToLocal;

/**
 * Format Address as inline text
 */
- (NSString *)formatAddress;

@end
