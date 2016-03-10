//
//  SimiOrderModel.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/19/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiOrderModel.h"
#import "SimiOrderAPI.h"

@implementation SimiOrderModel

- (void)getOrderWithId:(NSString *)orderId{
    currentNotificationName = DidGetOrder;
    [self preDoRequest];
    [(SimiOrderAPI *)[self getAPI] getOrderDetailWithID:orderId target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)cancelAnOrder:(NSString *)orderId{
    currentNotificationName = DidCancelOrder;
    [self preDoRequest];
    [(SimiOrderAPI *)[self getAPI] cancelAnOrderWithOrderId:orderId target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)getOrderConfigWithParams:(NSDictionary *)params quoteId:(NSString *)quoteId{
    modelActionType = ModelActionTypeGet;
    currentNotificationName = DidGetOrderConfig;
    NSString *extendsUrl = @"";
    if(quoteId && ![quoteId isEqualToString:@""])
        extendsUrl = [@"/" stringByAppendingString:quoteId];
    [self preDoRequest];
    [(SimiOrderAPI *)[self getAPI] getOrderConfigWithParams:params extendsUrl:(NSString *)extendsUrl target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)selectShippingMethod:(SimiModel *)method quoteId:(NSString *)quoteId{
    modelActionType = ModelActionTypeEdit;
    currentNotificationName = DidSaveShippingMethod;
    NSString *extendsUrl = @"";
    if(quoteId && ![quoteId isEqualToString:@""])
        extendsUrl = [@"/" stringByAppendingString:quoteId];
    [self preDoRequest];
    [(SimiOrderAPI *)[self getAPI] selectShippingMethod:method extendsUrl:(NSString *)extendsUrl target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)setCouponCode:(NSString *)couponCode quoteId:(NSString *)quoteId{
    modelActionType = ModelActionTypeEdit;
    currentNotificationName = DidSetCouponCode;
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:couponCode forKey:@"coupon_code"];
    [params setValue:quoteId forKey:@"quote_id"];
    [self preDoRequest];
    [(SimiOrderAPI *)[self getAPI] setCouponCode:params target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)removeCouponCode:(NSString *)couponCode quoteId:(NSString *)quoteId{
    modelActionType = ModelActionTypeEdit;
    currentNotificationName = DidSetCouponCode;
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:couponCode forKey:@"coupon_code"];
    [params setValue:quoteId forKey:@"quote_id"];
    [self preDoRequest];
    [(SimiOrderAPI *)[self getAPI] removeCouponCode:params target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)placeOrderWithParams:(NSString *)quoteId{
    modelActionType = ModelActionTypeEdit;
    currentNotificationName = DidPlaceOrder;
    NSString *extendsUrl = @"";
    if(quoteId && ![quoteId isEqualToString:@""])
        extendsUrl = [@"/" stringByAppendingString:quoteId];
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:@"createorder" forKey:@"action"];
    [self preDoRequest];
    [(SimiOrderAPI *)[self getAPI] placeOrderWithParams:params extendsUrl:(NSString *)extendsUrl target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)selectPaymentMethod:(SimiModel *)paymentmethod quoteId:(NSString *)quoteId{
    modelActionType = ModelActionTypeEdit;
    currentNotificationName = DidSavePaymentMethod;
    NSString *extendsUrl = @"";
    if(quoteId && ![quoteId isEqualToString:@""])
        extendsUrl = [[@"/" stringByAppendingString:quoteId] stringByAppendingString:@"/payment"];
    [self preDoRequest];
    [(SimiOrderAPI *)[self getAPI] selectPaymentMethod:paymentmethod extendsUrl:extendsUrl target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)reOrder:(NSString *)orderId{
    
}

- (void)saveCreditCard:(NSDictionary *)params
{
    currentNotificationName = DidSaveCreditCard;
    [self preDoRequest];
    [(SimiOrderAPI *)[self getAPI] saveCreditCard:params target:self selector:@selector(didFinishRequest:responder:)];
}


- (void)didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder
{
    if ([currentNotificationName isEqualToString:DidGetOrderConfig] || [currentNotificationName isEqualToString:DidSaveShippingMethod] ||[currentNotificationName isEqualToString:DidSavePaymentMethod] || [currentNotificationName isEqualToString:DidSetCouponCode]) {
        if (responder.simiObjectName) {
            currentNotificationName = responder.simiObjectName;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
        if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
            NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
            switch (modelActionType) {
                case ModelActionTypeInsert:{
                    [self addData:[responseObjectData valueForKey:@"quote"]];
                }
                    break;
                default:{
                    [self setData:[responseObjectData valueForKey:@"quote"]];
                }
                    break;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }else if (responseObject == nil){
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }
    }else if ([currentNotificationName isEqualToString:DidGetOrder] || [currentNotificationName isEqualToString:DidPlaceOrder] || [currentNotificationName isEqualToString:DidCancelOrder]) {
        if (responder.simiObjectName) {
            currentNotificationName = responder.simiObjectName;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
        if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
            NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
            switch (modelActionType) {
                case ModelActionTypeInsert:{
                    [self addData:[responseObjectData valueForKey:@"order"]];
                }
                    break;
                default:{
                    [self setData:[responseObjectData valueForKey:@"order"]];
                }
                    break;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }else if (responseObject == nil){
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }
    }
    else if([currentNotificationName isEqualToString:DidUpdatePaymentStatus]){
        if (responder.simiObjectName) {
            currentNotificationName = responder.simiObjectName;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
        if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
            NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];

                switch (modelActionType) {
                    case ModelActionTypeInsert:{
                        if([responseObjectData valueForKey:@"order"])
                            [self addData:[responseObjectData valueForKey:@"order"]];
                        else if([responseObjectData valueForKey:@"invoice"])
                            [self addData:[responseObjectData valueForKey:@"invoice"]];
                        else if([responseObjectData valueForKey:@"errors"])
                            [self addData:[responseObjectData valueForKey:@"errors"]];
                            [self addData:@{@"status":@"errors"}];
                    }
                        break;
                    default:{
                        if([responseObjectData valueForKey:@"order"])
                            [self setData:[responseObjectData valueForKey:@"order"]];
                        else if([responseObjectData valueForKey:@"invoice"])
                            [self setData:[responseObjectData valueForKey:@"invoice"]];
                        else if([responseObjectData valueForKey:@"errors"]){
                            [self setData:[responseObjectData valueForKey:@"errors"]];
                            [self addData:@{@"status":@"errors"}];
                        }
                    }
                        break;
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }else if (responseObject == nil){
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }
    
    else{
        [super didFinishRequest:responseObject responder:responder];
    }
}

//end editing

@end
