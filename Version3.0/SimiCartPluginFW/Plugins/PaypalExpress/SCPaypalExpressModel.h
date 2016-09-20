//
//  SCWishlistModelCollection.h
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 11/11/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import "SCPaypalExpressAPI.h"

@interface SCPaypalExpressModel: SimiModel


/*
 Notification name: DidStartPaypalExpress
 */
- (void)startPaypalExpress;

/*
 Notification name: DidGetPaypalAdressInformation
 */
- (void)reviewAddress;


/*
 Notification name: PaypalExpressDidPlaceOrder
 */
- (void)placeOrderWithParam:(NSDictionary *)params;

@end
