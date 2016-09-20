//
//  SCPaypalExpressModelCollection.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 12/22/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SCPaypalExpressModelCollection.h"

@implementation SCPaypalExpressModelCollection

- (void)updateAddressWithParam:(NSDictionary *)params{
    modelActionType = ModelActionTypeGet;
    currentNotificationName = @"DidUpdatePaypalCheckoutAddress";
    [self preDoRequest];
    [(SCPaypalExpressAPI *)[self getAPI] updateAddressWithParam:params target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)getShippingMethods
{
    currentNotificationName = @"DidGetPaypalCheckoutShippingMethods";
    [self preDoRequest];
    modelActionType = ModelActionTypeGet;
    [(SCPaypalExpressAPI *)[self getAPI] getShippingMethod:self selector:@selector(didFinishRequest:responder:)];
}

@end
