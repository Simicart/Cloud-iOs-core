//
//  SimiCategoryModelCollection.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/10/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiCategoryModelCollection.h"
#import "SimiCategoryAPI.h"
NSString *const scDefaultGetHomeCategory = @"category-widgets";

@implementation SimiCategoryModelCollection

- (void)getCategoryCollectionWithParentId:(NSString *)categoryId params:(NSDictionary *)params{
    currentNotificationName = DidGetCategoryCollection;
    [self preDoRequest];
    modelActionType = ModelActionTypeGet;
    NSString *extendsUrl = @"";
    NSMutableDictionary *parameters = nil;
    if (params != nil) {
        parameters = [[NSMutableDictionary alloc]initWithDictionary:params];
    }else
        parameters = [NSMutableDictionary new];
    [parameters setValue:@"50" forKey:@"limit"];
    [parameters setValue:@"0" forKey:@"offset"];
    [parameters setValue:@"1" forKey:@"filter[status]"];
    [(SimiCategoryAPI *)[self getAPI] getCategoryCollectionWithParams:parameters extendsUrl:extendsUrl target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)getHomeDefaultCategories{
    modelActionType = ModelActionTypeGet;
    currentNotificationName = DidGetHomeCategories;
    [self preDoRequest];
    NSString *urlPath = [NSString stringWithFormat:@"%@%@", kBaseURL, scDefaultGetHomeCategory];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setValue:@"50" forKey:@"limit"];
    [parameters setValue:@"0" forKey:@"offset"];
    [parameters setValue:@"1" forKey:@"filter[status]"];
    [[self getAPI] requestWithMethod:GET URL:urlPath params:parameters target:self selector:@selector(didFinishRequest:responder:) header:nil];
}

- (void)didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder
{
    if ([currentNotificationName isEqualToString:DidGetCategoryCollection]) {
        if (responder.simiObjectName) {
            currentNotificationName = responder.simiObjectName;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
        if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
            NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
            switch (modelActionType) {
                case ModelActionTypeInsert:{
                    [self addData:[responseObjectData valueForKey:@"categories"]];
                }
                    break;
                default:{
                    [self setData:[responseObjectData valueForKey:@"categories"]];
                }
                    break;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }else if (responseObject == nil){
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }
    }else if([currentNotificationName isEqualToString:DidGetHomeCategories])
    {
        if (responder.simiObjectName) {
            currentNotificationName = responder.simiObjectName;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
        if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
            NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
            switch (modelActionType) {
                case ModelActionTypeInsert:{
                    [self addData:[responseObjectData valueForKey:@"category-widgets"]];
                }
                    break;
                default:{
                    [self setData:[responseObjectData valueForKey:@"category-widgets"]];
                }
                    break;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }else if (responseObject == nil){
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }
    }else{
        [super didFinishRequest:responseObject responder:responder];
    }
}


@end
