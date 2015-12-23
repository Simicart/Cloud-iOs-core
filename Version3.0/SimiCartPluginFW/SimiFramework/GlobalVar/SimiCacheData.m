//
//  SimiCacheData.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 11/27/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import "SimiCacheData.h"

@implementation SimiCacheData


+ (id)sharedInstance{
    static SimiCacheData *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SimiCacheData alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    self.dataCategories = [NSMutableDictionary new];
    self.dataCategoryProducts = [NSMutableDictionary new];
    self.dataCategoryProductIDs = [NSMutableDictionary new];
    
    self.dataListProducts = [NSMutableDictionary new];
    self.dataListProductIDs = [NSMutableDictionary new];
    self.dataListProductFilters = [NSMutableDictionary new];
    return self;
}

- (void)renewData
{
    self.dataCategories = [NSMutableDictionary new];
    self.dataCategoryProducts = [NSMutableDictionary new];
    self.dataCategoryProductIDs = [NSMutableDictionary new];
    
    self.dataListProducts = [NSMutableDictionary new];
    self.dataListProductIDs = [NSMutableDictionary new];
    self.dataListProductFilters = [NSMutableDictionary new];
}
@end
