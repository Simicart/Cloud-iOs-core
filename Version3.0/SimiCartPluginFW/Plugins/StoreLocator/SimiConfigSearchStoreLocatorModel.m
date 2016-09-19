//
//  SimiConfigSearchStoreLocatorModel.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/11/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiConfigSearchStoreLocatorModel.h"
#import "SimiGlobalVar+StoreLocator.h"
#import "SimiConfigSearchStoreLocatorAPI.h"
@implementation SimiConfigSearchStoreLocatorModel
- (void)getSearchConfigWithParams:(NSDictionary*)dict
{
    currentNotificationName = @"DidGetSearchConfig";
    modelActionType = ModelActionTypeGet;
    //Gin edit
    [self preDoRequest];
    //end
    [(SimiConfigSearchStoreLocatorAPI *)[self getAPI] getSearchConfigWithParams:dict target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder
{
    if ([currentNotificationName isEqualToString:@"DidGetSearchConfig"]) {
        if (responder.simiObjectName) {
            currentNotificationName = responder.simiObjectName;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
        if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
            NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
            switch (modelActionType) {
                case ModelActionTypeInsert:{
                    [self addData:[[responseObjectData valueForKey:@"data"]objectAtIndex:0]];
                }
                    break;
                default:{
                    [self setData:[[responseObjectData valueForKey:@"data"]objectAtIndex:0]];
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
