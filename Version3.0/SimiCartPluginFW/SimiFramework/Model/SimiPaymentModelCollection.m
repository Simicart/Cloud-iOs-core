//
//  SimiPaymentModelCollection.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/19/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiPaymentModelCollection.h"
#import "SimiPaymentAPI.h"
#import "SimiResponder.h"

@implementation SimiPaymentModelCollection

- (void)addBillingAddressForQuote:(NSString *)quoteId withParams:(NSMutableDictionary *)params{
    currentNotificationName = DidGetPaymentMethod;
    NSString *extendsUrl = @"";
    if(quoteId && ![quoteId isEqualToString:@""])
        extendsUrl = [NSString stringWithFormat:@"%@%@%@", @"/", quoteId, @"/billing-address"];    [self preDoRequest];
    [(SimiPaymentAPI *)[self getAPI] addAddressForQuote:params extendsUrl:(NSString *)extendsUrl target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder
{
    if ([currentNotificationName isEqualToString:DidGetPaymentMethod]) {
        if (responder.simiObjectName) {
            currentNotificationName = responder.simiObjectName;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
        if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
            NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
            switch (modelActionType) {
                case ModelActionTypeInsert:{
                    [self addData:[responseObjectData valueForKey:@"payment"]];
                }
                    break;
                default:{
                    [self setData:[responseObjectData valueForKey:@"payment"]];
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
