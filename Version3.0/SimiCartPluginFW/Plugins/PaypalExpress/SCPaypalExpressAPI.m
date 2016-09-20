//
//  SCProductAPI.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 11/11/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCPaypalExpressAPI.h"



NSString *const kSimiPaypalExpressStartURL = @"paypalexpress/api/start";
NSString *const kSimiPaypalExpressReviewAddress = @"paypalexpress/api/review_address";
NSString *const kSimiPaypalExpressUpdateAddress = @"paypalexpress/api/update_address";
NSString *const kSimiPaypalExpressGetShippingMethods = @"paypalexpress/api/get_shipping_methods";
NSString *const kSimiPaypalExpressPlaceOrder = @"paypalexpress/api/place";


@implementation SCPaypalExpressAPI


- (void) startPaypalExpress:(id)target selector:(SEL)selector
{
    NSString *urlPath = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiPaypalExpressStartURL];
    [self requestWithURL:urlPath params:nil target:target selector:selector header:nil];
}


- (void) reviewAddress:(id)target selector:(SEL)selector
{
    NSString *urlPath = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiPaypalExpressReviewAddress];
    [self requestWithURL:urlPath params:nil target:target selector:selector header:nil];
}

- (void) updateAddressWithParam:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiPaypalExpressUpdateAddress];
    [self requestWithURL:url params:params target:target selector:selector header:nil];
}

- (void) getShippingMethod:(id)target selector:(SEL)selector
{
    NSString *urlPath = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiPaypalExpressGetShippingMethods];
    [self requestWithURL:urlPath params:nil target:target selector:selector header:nil];
}

- (void) placeOrderWithParam:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiPaypalExpressPlaceOrder];
    [self requestWithURL:url params:params target:target selector:selector header:nil];
}

/*

-(void) addWishlistProductToCartWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *urlPath = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiAppwishlistURL, kSimiAddWishlistProductToCart];
    [self requestWithURL:urlPath params:params target:target selector:selector header:nil];
}
 */


@end
