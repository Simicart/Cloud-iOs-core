//
//  SimiAddressStoreLocatorModelCollection.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/11/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiAddressStoreLocatorModelCollection.h"
#import "SimiGlobalVar+StoreLocator.h"
#import "SimiAddressStoreLocatorAPI.h"
@implementation SimiAddressStoreLocatorModelCollection
- (void)getCountryListWithParams:(NSDictionary*)dict
{
    currentNotificationName = @"DidGetCountryCollection";
    modelActionType = ModelActionTypeGet;
    //Gin edit
    [self preDoRequest];
    //end
    [(SimiAddressStoreLocatorAPI *)[self getAPI] getCountryListWithParams:dict target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder
{
    if ([currentNotificationName isEqualToString:@"DidGetCountryCollection"]) {
        if (responder.simiObjectName) {
            currentNotificationName = responder.simiObjectName;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
        if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
            NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
            switch (modelActionType) {
                case ModelActionTypeInsert:{
                    [self addData:[responseObjectData valueForKey:@"data"]];
                }
                    break;
                default:{
                    [self setData:[responseObjectData valueForKey:@"data"]];
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
