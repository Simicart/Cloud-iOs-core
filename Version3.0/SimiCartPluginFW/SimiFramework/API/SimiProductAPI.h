//
//  SimiProductAPI.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/10/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiAPI.h"

@interface SimiProductAPI : SimiAPI

- (void)getProductWithParams:(NSDictionary *)params extendsUrl:(NSString *)extendsUrl target:(id)target selector:(SEL)selector;

- (void)getProductCollectionWithParams:(NSDictionary *)params extendsUrl:(NSString*)extendsUrl target:(id)target selector:(SEL)selector;

- (void)searchProductWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;

- (void)searchOnAllProductWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;

- (void)getAllProductsWithParams:(NSDictionary *)params extendsUrl:(NSString*)extendsUrl target:(id)target selector:(SEL)selector;

@end
