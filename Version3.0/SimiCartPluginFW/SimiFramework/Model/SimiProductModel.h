//
//  SimiProductModel.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/10/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiModel.h"

//Type of product
typedef NS_ENUM(NSInteger, ProductType){
    ProductTypeSimple,          //0 - Product Type Simple
    ProductTypeConfigurable,    //1 - Product Type Configurable
    ProductTypeGrouped,         //2 - Product Type Group
    ProductTypeBundle           //3 - Product Type Bundle
};

@interface SimiProductModel : SimiModel

/*
 Notification name: DidGetProductWithProductId
 */
- (void)getProductWithProductId:(NSString *)productId params:(NSDictionary *)params;

- (ProductType)productType;

@end
