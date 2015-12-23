//
//  SimiOrderAPI.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 1/20/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiAPI.h"
#import "SimiShippingModel.h"

@interface SimiOrderAPI : SimiAPI

- (void)getOrderDetailWithID:(NSString*) orderId target:(id)target selector:(SEL)selector;
- (void)getOrderConfigWithParams:(NSDictionary *)params extendsUrl:(NSString *)extendsUrl target:(id)target selector:(SEL)selector;
- (void)getCustomerOrderListWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
- (void)selectShippingMethod:(NSDictionary *)params extendsUrl:(NSString *)extendsUrl target:(id)target selector:(SEL)selector;
- (void)selectPaymentMethod:(NSDictionary *)params extendsUrl:(NSString *)extendsUrl target:(id)target selector:(SEL)selector;
- (void)setCouponCode:(NSMutableDictionary *)params target:(id)target selector:(SEL)selector;
- (void)removeCouponCode:(NSMutableDictionary *)params target:(id)target selector:(SEL)selector;
- (void)placeOrderWithParams:(NSDictionary *)params extendsUrl:(NSString *)extendsUrl target:(id)target selector:(SEL)selector;
- (void)addAddressForQuote:(NSDictionary *)params extendsUrl:(NSString *)extendsUrl target:(id)target selector:(SEL)selector;

@end
