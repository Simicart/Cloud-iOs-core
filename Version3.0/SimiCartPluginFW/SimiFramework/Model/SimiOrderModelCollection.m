//
//  SimiOrderModelCollection.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/4/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiOrderModelCollection.h"

@implementation SimiOrderModelCollection

- (void)getCustomerOrderCollectionWithParams:(NSDictionary* )params{
    currentNotificationName = @"DidGetOrderCollection";
    [self preDoRequest];
    modelActionType = ModelActionTypeInsert;
    [(SimiOrderAPI *)[self getAPI] getCustomerOrderListWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder
{
    if ([currentNotificationName isEqualToString:DidGetOrderCollection]) {
        if (responder.simiObjectName) {
            currentNotificationName = responder.simiObjectName;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
        if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
            NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
            switch (modelActionType) {
                case ModelActionTypeInsert:{
                    [self addData:[responseObjectData valueForKey:@"orders"]];
                }
                    break;
                default:{
                    [self setData:[responseObjectData valueForKey:@"orders"]];
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
