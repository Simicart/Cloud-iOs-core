//
//  SimiOrderModel.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/19/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiModel.h"
#import "SimiShippingModel.h"

@interface SimiOrderModel : SimiModel

/*
 Notification name: DidGetOrder
 */
- (void)getOrderWithId:(NSString *)orderId;

/*
 Notification name: DidGetOrderConfig
 */
- (void)getOrderConfigWithParams:(NSDictionary *)params quoteId:(NSString *)quoteId;

/*
 Notification name: DidSaveShippingMethod
 */
- (void)selectShippingMethod:(SimiModel *)method quoteId:(NSString *)quoteId;

/*
 Notification name: DidSetCouponCode
 */
- (void)setCouponCode:(NSString *)couponCode quoteId:(NSString *)quoteId;

/*
 Notification name: DidSetCouponCode
 */
- (void)removeCouponCode:(NSString *)couponCode quoteId:(NSString *)quoteId;

/*
 Notification name: DidPlaceOrder
 */
- (void)placeOrderWithParams:(NSString *)quoteId;

/*
 Notification name: DidCompleteReOrder
 hainh
 */
- (void)selectPaymentMethod:(SimiModel *)paymentmethod quoteId:(NSString *)quoteId;
- (void)reOrder:(NSString *)orderId;
/*
 Cancel an order : VuThanhDo
*/
- (void)cancelAnOrder:(NSString *)orderId;

// Save Credit Card
- (void)saveCreditCard:(NSDictionary *)params;

//end editing
- (void)didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder;
@end
