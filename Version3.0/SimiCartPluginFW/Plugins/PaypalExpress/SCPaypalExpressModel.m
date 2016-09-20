//
//  SCWishlistModelCollection.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 11/11/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCPaypalExpressModel.h"

@implementation SCPaypalExpressModel


- (void)startPaypalExpress
{
    currentNotificationName = @"DidStartPaypalExpress";
    [self preDoRequest];
    modelActionType = ModelActionTypeGet;
    [(SCPaypalExpressAPI *)[self getAPI] startPaypalExpress:self selector:@selector(didFinishRequest:responder:)];
}

- (void)reviewAddress
{
    currentNotificationName = @"DidGetPaypalAdressInformation";
    [self preDoRequest];
    modelActionType = ModelActionTypeGet;
    [(SCPaypalExpressAPI *)[self getAPI] reviewAddress:self selector:@selector(didFinishRequest:responder:)];
}

- (void)placeOrderWithParam:(NSDictionary *)params{
    modelActionType = ModelActionTypeGet;
    currentNotificationName = @"PaypalExpressDidPlaceOrder";
    [self preDoRequest];
    [(SCPaypalExpressAPI *)[self getAPI] placeOrderWithParam:params target:self selector:@selector(didFinishRequest:responder:)];
}



@end
