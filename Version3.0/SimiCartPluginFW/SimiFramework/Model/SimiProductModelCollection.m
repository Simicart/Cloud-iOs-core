//
//  SimiProductModelCollection.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/11/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiProductModelCollection.h"
#import "SimiProductAPI.h"

@implementation SimiProductModelCollection

- (void)getProductCollectionWithCategoryId:(NSString *)categoryId offset:(NSInteger)offset limit:(NSInteger)limit sortType:(ProductCollectionSortType)sortType otherParams:(NSDictionary *)otherParams{
    currentNotificationName = DidGetProductCollectionWithCategoryId;
    modelActionType = ModelActionTypeInsert;
    [self preDoRequest];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:otherParams];
    [params setValue:[NSString stringWithFormat:@"%ld", (long)offset] forKey:@"offset"];
    [params setValue:[NSString stringWithFormat:@"%ld", (long)limit] forKey:@"limit"];
    switch (sortType) {
        case ProductCollectionSortNone:
            break;
        case ProductCollectionSortPriceLowToHigh:
        {
            [params setValue:@"sale_price" forKey:@"order"];
            [params setValue:@"asc" forKey:@"dir"];
        }
            break;
        case ProductCollectionSortPriceHighToLow:
        {
            [params setValue:@"sale_price" forKey:@"order"];
            [params setValue:@"desc" forKey:@"dir"];
        }
            break;
        case ProductCollectionSortNameASC:
        {
            [params setValue:@"name" forKey:@"order"];
            [params setValue:@"asc" forKey:@"dir"];
        }
            break;
        case ProductCollectionSortNameDESC:
        {
            [params setValue:@"name" forKey:@"order"];
            [params setValue:@"desc" forKey:@"dir"];
        }
        default:
            break;
    }
    [params setValue:@"1" forKey:@"filter[visibility]"];
    [params setValue:@"1" forKey:@"filter[status]"];
    NSString *extendsUrl = [NSString stringWithFormat:@"/%@/products",categoryId];
    [(SimiProductAPI *)[self getAPI] getProductCollectionWithParams:params extendsUrl:extendsUrl target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)searchProductsWithKey:(NSString *)key offset:(NSInteger)offset limit:(NSInteger)limit categoryId:(NSString *)categoryId sortType:(ProductCollectionSortType)sortType otherParams:(NSDictionary *)otherParams{
    currentNotificationName = DidSearchProducts;
    [self preDoRequest];
    modelActionType = ModelActionTypeInsert;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:otherParams];
    [params setValue:key forKey:@"filter[keywords]"];
    [params setValue:[NSString stringWithFormat:@"%ld", (long)offset] forKey:@"offset"];
    [params setValue:[NSString stringWithFormat:@"%ld", (long)limit] forKey:@"limit"];
    switch (sortType) {
        case ProductCollectionSortNone:
            break;
        case ProductCollectionSortPriceLowToHigh:
        {
            [params setValue:@"sale_price" forKey:@"order"];
            [params setValue:@"asc" forKey:@"dir"];
        }
            break;
        case ProductCollectionSortPriceHighToLow:
        {
            [params setValue:@"sale_price" forKey:@"order"];
            [params setValue:@"desc" forKey:@"dir"];
        }
            break;
        case ProductCollectionSortNameASC:
        {
            [params setValue:@"name" forKey:@"order"];
            [params setValue:@"asc" forKey:@"dir"];
        }
            break;
        case ProductCollectionSortNameDESC:
        {
            [params setValue:@"name" forKey:@"order"];
            [params setValue:@"desc" forKey:@"dir"];
        }
        default:
            break;
    }
    [params setValue:@"1" forKey:@"filter[visibility]"];
    [params setValue:@"1" forKey:@"filter[status]"];
    if (categoryId) {
        [params setValue:categoryId forKey:@"filter[category_ids][all][]"];
    }
    
    [(SimiProductAPI *)[self getAPI] searchProductWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)searchOnAllProductsWithKey:(NSString *)key offset:(NSInteger)offset limit:(NSInteger)limit sortType:(ProductCollectionSortType)sortType otherParams:(NSDictionary *)otherParams
{
    currentNotificationName = DidSearchProducts;
    [self preDoRequest];
    modelActionType = ModelActionTypeInsert;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:otherParams];
    [params setValue:[NSString stringWithFormat:@"%ld", (long)offset] forKey:@"offset"];
    [params setValue:[NSString stringWithFormat:@"%ld", (long)limit] forKey:@"limit"];
    switch (sortType) {
        case ProductCollectionSortNone:
            break;
        case ProductCollectionSortPriceLowToHigh:
        {
            [params setValue:@"sale_price" forKey:@"order"];
            [params setValue:@"asc" forKey:@"dir"];
        }
            break;
        case ProductCollectionSortPriceHighToLow:
        {
            [params setValue:@"sale_price" forKey:@"order"];
            [params setValue:@"desc" forKey:@"dir"];
        }
            break;
        case ProductCollectionSortNameASC:
        {
            [params setValue:@"name" forKey:@"order"];
            [params setValue:@"asc" forKey:@"dir"];
        }
            break;
        case ProductCollectionSortNameDESC:
        {
            [params setValue:@"name" forKey:@"order"];
            [params setValue:@"desc" forKey:@"dir"];
        }
        default:
            break;
    }
    [params setValue:key forKey:@"filter[keywords]"];
    [params setValue:@"1" forKey:@"filter[visibility]"];
    [params setValue:@"1" forKey:@"filter[status]"];
    [(SimiProductAPI *)[self getAPI] searchOnAllProductWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)getAllProductsWithOffset:(NSInteger)offset limit:(NSInteger)limit sortType:(ProductCollectionSortType)sortType otherParams:(NSDictionary *)otherParams{
    currentNotificationName = DidGetAllProducts;
    [self preDoRequest];
    modelActionType = ModelActionTypeInsert;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:otherParams];
    [params setValue:[NSString stringWithFormat:@"%ld", (long)offset] forKey:@"offset"];
    [params setValue:[NSString stringWithFormat:@"%ld", (long)limit] forKey:@"limit"];
    switch (sortType) {
        case ProductCollectionSortNone:
            break;
        case ProductCollectionSortPriceLowToHigh:
        {
            [params setValue:@"sale_price" forKey:@"order"];
            [params setValue:@"asc" forKey:@"dir"];
        }
            break;
        case ProductCollectionSortPriceHighToLow:
        {
            [params setValue:@"sale_price" forKey:@"order"];
            [params setValue:@"desc" forKey:@"dir"];
        }
            break;
        case ProductCollectionSortNameASC:
        {
            [params setValue:@"name" forKey:@"order"];
            [params setValue:@"asc" forKey:@"dir"];
        }
            break;
        case ProductCollectionSortNameDESC:
        {
            [params setValue:@"name" forKey:@"order"];
            [params setValue:@"desc" forKey:@"dir"];
        }
        default:
            break;
    }
    [params setValue:@"1" forKey:@"filter[visibility]"];
    [params setValue:@"1" forKey:@"filter[status]"];
    
    [(SimiProductAPI *)[self getAPI] getAllProductsWithParams:params extendsUrl:@"" target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder
{
    if ([currentNotificationName isEqualToString:DidGetAllProducts] || [currentNotificationName isEqualToString:DidGetProductCollectionWithCategoryId] || [currentNotificationName isEqualToString:DidSearchProducts]) {
        if (responder.simiObjectName) {
            currentNotificationName = responder.simiObjectName;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
        if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
            NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
            switch (modelActionType) {
                case ModelActionTypeInsert:{
                    [self addData:[responseObjectData valueForKey:@"products"]];
                }
                    break;
                default:{
                    [self setData:[responseObjectData valueForKey:@"products"]];
                }
                    break;
            }
            self.productIDs = [[NSMutableArray alloc]initWithArray:[responseObjectData valueForKey:@"all_ids"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }else if (responseObject == nil){
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }
    }else if([currentNotificationName isEqualToString:DidGetSpotProduct]){
        if (responder.simiObjectName) {
            currentNotificationName = responder.simiObjectName;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
        if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
            NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
            switch (modelActionType) {
                case ModelActionTypeInsert:{
                    [self addData:[responseObjectData valueForKey:@"spot-product"]];
                }
                    break;
                default:{
                    [self setData:[responseObjectData valueForKey:@"spot-product"]];
                }
                    break;
            }
            self.productIDs = [[NSMutableArray alloc]initWithArray:[responseObjectData valueForKey:@"all_ids"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }else if (responseObject == nil){
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }
    }else if ([currentNotificationName isEqualToString:DidGetShippingMethod]) {
        if (responder.simiObjectName) {
            currentNotificationName = responder.simiObjectName;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
        if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
            NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
            switch (modelActionType) {
                case ModelActionTypeInsert:{
                    [self addData:[responseObjectData valueForKey:@"shipping"]];
                }
                    break;
                default:{
                    [self setData:[responseObjectData valueForKey:@"shipping"]];
                }
                    break;
            }
            self.productIDs = [[NSMutableArray alloc]initWithArray:[responseObjectData valueForKey:@"all_ids"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }else if (responseObject == nil){
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }
    } else if ([currentNotificationName isEqualToString:DidGetPaymentMethod]) {
        if (responder.simiObjectName) {
            currentNotificationName = responder.simiObjectName;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
        if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
            NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
            switch (modelActionType) {
                case ModelActionTypeInsert:{
                    [self addData:[responseObjectData valueForKey:@"payment"]];
                }
                    break;
                default:{
                    [self setData:[responseObjectData valueForKey:@"payment"]];
                }
                    break;
            }
            self.productIDs = [[NSMutableArray alloc]initWithArray:[responseObjectData valueForKey:@"all_ids"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }else if (responseObject == nil){
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }
    }else{
        [super didFinishRequest:responseObject responder:responder];
    }
}
@end
