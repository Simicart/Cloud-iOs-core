//
//  SCWishlistModelCollection.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 11/11/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCAppWishlistModelCollection.h"

@implementation SCAppWishlistModelCollection

- (void)removeProductFromWishlist:(NSString *)itemId otherParams:(NSDictionary *)otherParams
{
    currentNotificationName = @"DidRemoveProductFromWishlist";
    [self preDoRequest];
    modelActionType = ModelActionTypeGet;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:otherParams];
    [params setValue:itemId forKey:@"wishlist_item_id"];
    
    [(SCAppWishlistAPI *)[self getAPI] removeProductFromWishlistWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)addProductToWishlist:(SimiProductModel*)params otherParams:(NSDictionary *)otherParams
{
    currentNotificationName = @"DidAddProductToWishlist";
    [self preDoRequest];
    modelActionType = ModelActionTypeGet;
    [(SCAppWishlistAPI *)[self getAPI] addProductToWishlistWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}


- (void)getWishlistQty
{
    currentNotificationName = @"DidGetWishlistQty";
    [self preDoRequest];
    modelActionType = ModelActionTypeGet;
    [(SCAppWishlistAPI *)[self getAPI] getWishlistQty:self selector:@selector(didFinishRequest:responder:)];
}


- (void) addWishlistProductToCart:(NSString *)itemId otherParams:(NSDictionary *)otherParams
{
    currentNotificationName = @"DidAddWishlistProductToCart";
    [self preDoRequest];
    modelActionType = ModelActionTypeGet;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:otherParams];
    [params setValue:itemId forKey:@"wishlist_item_id"];
    
    [(SCAppWishlistAPI *)[self getAPI] addWishlistProductToCartWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
    
}

- (void)getWishlistProducts:(NSInteger)offset limit:(NSInteger)limit sortType:(ProductCollectionSortType)sortType otherParams:(NSDictionary *)otherParams{

    currentNotificationName = @"DidGetWishlist";
    [self preDoRequest];
    modelActionType = ModelActionTypeGet;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:otherParams];
    [params setValue:[NSString stringWithFormat:@"%ld", (long)offset] forKey:@"offset"];
    [params setValue:[NSString stringWithFormat:@"%ld", (long)limit] forKey:@"limit"];
    [params setValue:[NSString stringWithFormat:@"%ld", (long)sortType] forKey:@"sort_option"];
    
    [(SCAppWishlistAPI *)[self getAPI] getWishlistProductsWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
    
}


@end
