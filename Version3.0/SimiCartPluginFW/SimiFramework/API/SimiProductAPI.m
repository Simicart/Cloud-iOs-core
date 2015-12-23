//
//  SimiProductAPI.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/10/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiProductAPI.h"

@implementation SimiProductAPI

- (void)getProductCollectionWithParams:(NSDictionary *)params extendsUrl:(NSString *)extendsUrl target:(id)target selector:(SEL)selector{
    NSString *urlPath = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiCategories,extendsUrl];
    [self requestWithMethod:GET URL:urlPath params:params target:target selector:selector header:nil];
}

- (void)getProductWithParams:(NSDictionary *)params extendsUrl:(NSString *)extendsUrl target:(id)target selector:(SEL)selector{
    NSString *urlPath = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiProducts, extendsUrl];
    [self requestWithMethod:GET URL:urlPath params:params target:target selector:selector header:nil];
}

- (void)searchProductWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *urlPath = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiSearchProduct];
    [self requestWithMethod:GET URL:urlPath params:params target:target selector:selector header:nil];
}

- (void)searchOnAllProductWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *urlPath = [NSString stringWithFormat:@"%@%@", kBaseURL, kSimiSearchProduct];
    [self requestWithMethod:GET URL:urlPath params:params target:target selector:selector header:nil];
}

- (void)getAllProductsWithParams:(NSDictionary *)params extendsUrl:(NSString*)extendsUrl target:(id)target selector:(SEL)selector{
    NSString *urlPath = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiProducts, extendsUrl];
    [self requestWithMethod:GET URL:urlPath params:params target:target selector:selector header:nil];
}
@end
