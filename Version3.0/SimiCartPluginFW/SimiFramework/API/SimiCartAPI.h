//
//  SimiCartAPI.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 1/20/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiAPI.h"

@interface SimiCartAPI : SimiAPI

- (void)mergeQuoteWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;

- (void)getQuotesWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;

- (void)getCartItemsWithParams:(NSDictionary *)params extendsUrl:(NSString *)extendsUrl target:(id)target selector:(SEL)selector;

- (void)addToCartWithParams:(NSDictionary *)params extendUrl:(NSString*)extendUrl target:(id)target selector:(SEL)selector;

- (void)editCartItemsWithParams:(NSDictionary *)params extendsUrl:(NSString *)extendsUrl target:(id)target selector:(SEL)selector;

- (void)deleteCartItem:(NSString *)extendsUrl target:(id)target selector:(SEL)selector;

- (void)updateCouponCodeWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;

- (void)createNewQuoteWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;

- (void)addCustomerToQuote:(NSDictionary *)params extendUrl:(NSString*)extendUrl target:(id)target selector:(SEL)selector;

@end
