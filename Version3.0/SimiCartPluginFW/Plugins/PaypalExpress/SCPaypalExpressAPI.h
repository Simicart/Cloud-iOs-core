//
//  SCProductAPI.h
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 11/11/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>



@interface SCPaypalExpressAPI : SimiAPI


- (void)startPaypalExpress:(id)target selector:(SEL)selector;

- (void)reviewAddress:(id)target selector:(SEL)selector;

- (void)updateAddressWithParam:(NSDictionary *)params target:(id)target selector:(SEL)selector;

- (void) getShippingMethod:(id)target selector:(SEL)selector;

- (void) placeOrderWithParam:(NSDictionary *)params target:(id)target selector:(SEL)selector;
/*
- (void)addWishlistProductToCartWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
*/

@end
