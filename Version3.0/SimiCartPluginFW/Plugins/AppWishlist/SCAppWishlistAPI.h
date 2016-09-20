//
//  SCProductAPI.h
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 11/11/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiProductAPI.h>



@interface SCAppWishlistAPI : SimiProductAPI

- (void)getWishlistProductsWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
- (void)removeProductFromWishlistWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
- (void)addProductToWishlistWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
- (void)getWishlistQty:(id)target selector:(SEL)selector;
- (void)addWishlistProductToCartWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;


@end
