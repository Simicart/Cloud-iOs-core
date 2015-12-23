//
//  SimiProductModel.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/10/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiProductModel.h"
#import "SimiProductAPI.h"

@implementation SimiProductModel

- (void)getProductWithProductId:(NSString *)productId params:(NSDictionary *)params{
    currentNotificationName = DidGetProductWithProductId;
    [self preDoRequest];
    NSString *extendsUrl = @"";
    if(productId && ![productId isEqualToString:@""])
        extendsUrl = [@"/" stringByAppendingString:productId];
    [params setValue:@"1" forKey:@"all"];
    [(SimiProductAPI *)[self getAPI] getProductWithParams:params extendsUrl:(NSString *)extendsUrl target:self selector:@selector(didFinishRequest:responder:)];
}

- (ProductType)productType{
    if ([[self valueForKey:@"type"] isEqualToString:@"configurable"]) {
        return ProductTypeConfigurable;
    }else if ([[self valueForKey:@"type"] isEqualToString:@"grouped"]) {
        return ProductTypeGrouped;
    }else if ([[self valueForKey:@"type"] isEqualToString:@"bundle"]){
        return ProductTypeBundle;
    }
    return ProductTypeSimple;
}

- (void)didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder
{
    if ([currentNotificationName isEqualToString:DidGetProductWithProductId]) {
        if (responder.simiObjectName) {
            currentNotificationName = responder.simiObjectName;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
        if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
            NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
            switch (modelActionType) {
                case ModelActionTypeInsert:{
                    [self addData:[responseObjectData valueForKey:@"product"]];
                }
                    break;
                default:{
                    [self setData:[responseObjectData valueForKey:@"product"]];
                }
                    break;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }else if (responseObject == nil){
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }
    }else
    {
        [super didFinishRequest:responseObject responder:responder];
    }
}


@end
