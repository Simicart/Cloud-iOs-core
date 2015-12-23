//
//  SimiCategoryAPI.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/10/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiCategoryAPI.h"

@implementation SimiCategoryAPI

- (void)getCategoryCollectionWithParams:(NSDictionary *)params extendsUrl:(NSString *)extendsUrl target:(id)target selector:(SEL)selector{
    NSString *urlPath = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiCategories, extendsUrl];
    [self requestWithMethod:GET URL:urlPath params:params target:target selector:selector header:nil];
}

-(void) getCategoryWithId:(NSString* )categoryId params:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString* urlPath = [NSString stringWithFormat:@"%@%@/%@",kBaseURL,kSimiCategories,categoryId];
    [self requestWithMethod:GET URL:urlPath params:params target:target selector:selector header:nil];
}
@end
