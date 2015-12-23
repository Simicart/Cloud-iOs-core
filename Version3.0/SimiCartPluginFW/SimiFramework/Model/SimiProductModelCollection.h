//
//  SimiProductModelCollection.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/11/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiModelCollection.h"
#import "SimiProductModel.h"

@interface SimiProductModelCollection : SimiModelCollection
@property (nonatomic, strong) NSMutableArray *productIDs;
/*
 Notification name: DidGetProductCollectionWithCategoryId
 */
- (void)getProductCollectionWithCategoryId:(NSString *)categoryId offset:(NSInteger)offset limit:(NSInteger)limit sortType:(ProductCollectionSortType)sortType otherParams:(NSDictionary *)otherParams;

/*
 Notification name: DidSearchProducts
 */
- (void)searchProductsWithKey:(NSString *)key offset:(NSInteger)offset limit:(NSInteger)limit categoryId:(NSString *)categoryId sortType:(ProductCollectionSortType)sortType otherParams:(NSDictionary *)otherParams;

- (void)searchOnAllProductsWithKey:(NSString *)key offset:(NSInteger)offset limit:(NSInteger)limit sortType:(ProductCollectionSortType)sortType otherParams:(NSDictionary *)otherParams;

/*
 Notification name: DidGetAllProducts
 */
- (void)getAllProductsWithOffset:(NSInteger)offset limit:(NSInteger)limit sortType:(ProductCollectionSortType)sortType otherParams:(NSDictionary *)otherParams;
@end
