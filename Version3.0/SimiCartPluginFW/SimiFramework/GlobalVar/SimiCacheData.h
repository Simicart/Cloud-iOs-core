//
//  SimiCacheData.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 11/27/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface SimiCacheData : NSObject
// Category screen
@property (nonatomic, strong) NSMutableDictionary *dataCategories;
@property (nonatomic, strong) NSMutableDictionary *dataCategoryProducts;
@property (nonatomic, strong) NSMutableDictionary *dataCategoryProductIDs;

// Product List screem
@property (nonatomic, strong) NSMutableDictionary *dataListProducts;
@property (nonatomic, strong) NSMutableDictionary *dataListProductIDs;
@property (nonatomic, strong) NSMutableDictionary *dataListProductFilters;
+ (instancetype)sharedInstance;
- (void)renewData;
@end
