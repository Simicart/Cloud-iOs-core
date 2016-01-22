//
//  SimiAddressModelCollection.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/19/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiAddressModelCollection.h"
@implementation SimiAddressModelCollection

- (void)getCountryCollection{
    currentNotificationName = DidGetCountryCollection;
    [self preDoRequest];
    modelActionType = ModelActionTypeGet;
    [(SimiAddressAPI *)[self getAPI] getCountryCollectionWithParams:nil target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)getStateCollectionWithCountryName:(NSString *)countryName countryCode:(NSString *)countryCode
{
    
}

- (void)didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder
{
    if ([currentNotificationName isEqualToString:DidGetCountryCollection]) {
        if (responder.simiObjectName) {
            currentNotificationName = responder.simiObjectName;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
        if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
            NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
            switch (modelActionType) {
                case ModelActionTypeInsert:{
                    [self addData:[responseObjectData valueForKey:@"countries"]];
                }
                    break;
                default:{
                    [self setData:[responseObjectData valueForKey:@"countries"]];
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
