//
//  SimiOrderAPI.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 1/20/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiOrderAPI.h"

@implementation SimiOrderAPI

- (void)getOrderDetailWithID:(NSString* )orderId target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiOrders];
    [url stringByAppendingString:[NSString stringWithFormat:@"/%@",orderId]];
    [self requestWithMethod:GET URL:url params:nil target:target selector:selector header:nil];
}

- (void)getOrderConfigWithParams:(NSDictionary *)params extendsUrl:(NSString *)extendsUrl target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiQuotes, extendsUrl];
    [self requestWithMethod:GET URL:url params:params target:target selector:selector header:nil];
}

- (void)getCustomerOrderListWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiOrders];
    [self requestWithMethod:GET URL:url params:params target:target selector:selector header:nil];
}

- (void)selectShippingMethod:(NSDictionary *)params extendsUrl:(NSString *)extendsUrl target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiQuotes, extendsUrl];
     [self requestWithMethod:PUT URL:url params:params target:target selector:selector header:nil];
}

- (void)setCouponCode:(NSMutableDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiSetCouponCode];
    [self requestWithMethod:POST URL:url params:params target:target selector:selector header:nil];
}

- (void)removeCouponCode:(NSMutableDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiRemoveCouponCode];
    [self requestWithMethod:POST URL:url params:params target:target selector:selector header:nil];
}

- (void)placeOrderWithParams:(NSDictionary *)params extendsUrl:(NSString *)extendsUrl target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiQuotes, extendsUrl];
    [self requestWithMethod:PUT URL:url params:params target:target selector:selector header:nil];
}

- (void)addAddressForQuote:(NSDictionary *)params extendsUrl:(NSString *)extendsUrl target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiQuotes, extendsUrl];
    [self requestWithMethod:PUT URL:url params:params target:target selector:selector header:nil];
}
- (void)selectPaymentMethod:(NSDictionary *)params extendsUrl:(NSString *)extendsUrl target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiQuotes, extendsUrl];
     [self requestWithMethod:PUT URL:url params:params target:target selector:selector header:nil];
}

@end
