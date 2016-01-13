//
//  SimiCartAPI.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 1/20/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiCartAPI.h"

@implementation SimiCartAPI

- (void)mergeQuoteWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiQuotes,@"/merge"];
    [self requestWithMethod:POST URL:url params:params target:target selector:selector header:nil];
}

- (void)getQuotesWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiQuotes];
    [self requestWithMethod:GET URL:url params:params target:target selector:selector header:nil];
}

- (void)getCartItemsWithParams:(NSDictionary *)params extendsUrl:(NSString *)extendsUrl target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiQuotes, extendsUrl];
    [self requestWithMethod:GET URL:url params:params target:target selector:selector header:nil];
}

- (void)addToCartWithParams:(NSDictionary *)params extendUrl:extendUrl target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiQuotes,extendUrl];
    [self requestWithMethod:POST URL:url params:params target:target selector:selector header:nil];
}

- (void)editCartItemsWithParams:(NSDictionary *)params extendsUrl:(NSString *)extendsUrl target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiQuotes, extendsUrl];
    [self requestWithMethod:PUT URL:url params:params target:target selector:selector header:nil];
}

- (void)deleteCartItem:(NSString *)extendsUrl target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiQuotes, extendsUrl];
    [self requestWithMethod:DELETE URL:url params:nil target:target selector:selector header:nil];
}

- (void)updateCouponCodeWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *url = @"";
    [self requestWithURL:url params:params target:target selector:selector header:nil];
}

- (void)createNewQuoteWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiQuotes];
    [self requestWithMethod:POST URL:url params:params target:target selector:selector header:nil];
}

- (void)addCustomerToQuote:(NSDictionary *)params extendUrl:extendUrl target:(id)target selector:(SEL)selector
{
    NSString *url = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiQuotes, extendUrl];
    [self requestWithMethod:PUT URL:url params:params target:target selector:selector header:nil];
}
@end
