//
//  SCProductAPI.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 11/11/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCAppWishlistAPI.h"



NSString *const kSimiAppwishlistURL = @"appwishlist/";
NSString *const kSimiAddProductToWishlist = @"api/add_product_to_wishlist";
NSString *const kSimiGetWishlistProductList = @"api/get_wishlist_products";
NSString *const kSimiRemoveProductFromWishlist = @"api/remove_product_from_wishlist";
NSString *const kSimiGetWishlistQty = @"api/get_qty";
NSString *const kSimiAddWishlistProductToCart = @"api/add_wishlist_product_to_cart";


@implementation SCAppWishlistAPI

- (void)getWishlistProductsWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *urlPath = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiAppwishlistURL, kSimiGetWishlistProductList];
    [self requestWithURL:urlPath params:params target:target selector:selector header:nil];
}

- (void)removeProductFromWishlistWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *urlPath = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiAppwishlistURL, kSimiRemoveProductFromWishlist];
    [self requestWithURL:urlPath params:params target:target selector:selector header:nil];
}

- (void)addProductToWishlistWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *urlPath = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiAppwishlistURL, kSimiAddProductToWishlist];
    [self requestWithURL:urlPath params:params target:target selector:selector header:nil];
}

-(void) getWishlistQty:(id)target selector:(SEL)selector{
    NSString *urlPath = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiAppwishlistURL, kSimiGetWishlistQty];
    [self requestWithURL:urlPath params:nil target:target selector:selector header:nil];
}

-(void) addWishlistProductToCartWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *urlPath = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiAppwishlistURL, kSimiAddWishlistProductToCart];
    [self requestWithURL:urlPath params:params target:target selector:selector header:nil];
}


@end
