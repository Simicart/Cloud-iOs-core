//
//  SimiOrderModelCollection.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/4/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiOrderModelCollection.h"

@implementation SimiOrderModelCollection

- (void)getCustomerOrderCollectionWithOffset:(NSInteger)offset limit:(NSInteger)limit filters:(NSDictionary *)filters{
    currentNotificationName = @"DidGetOrderCollection";
    [self preDoRequest];
    modelActionType = ModelActionTypeInsert;
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:filters];
    [params setValue:[NSString stringWithFormat:@"%ld", (long)offset] forKey:@"offset"];
    [params setValue:[NSString stringWithFormat:@"%ld", (long)limit] forKey:@"limit"];
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
