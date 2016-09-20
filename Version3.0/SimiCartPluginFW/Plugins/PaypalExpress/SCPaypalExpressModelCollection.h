//
//  SCPaypalExpressModelCollection.h
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 12/22/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import "SCPaypalExpressAPI.h"

@interface SCPaypalExpressModelCollection : SimiModelCollection

/*
 Notification name: DidUpdatePaypalCheckoutAddress
 */
- (void)updateAddressWithParam:(NSDictionary *)params;


/*
 Notification name: DidGetPaypalCheckoutShippingMethods
 */
- (void)getShippingMethods;

@end
