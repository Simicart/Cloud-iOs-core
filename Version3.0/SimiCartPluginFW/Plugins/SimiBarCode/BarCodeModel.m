//
//  BarCodeModel.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 1/20/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "BarCodeModel.h"
#import "BarCodeAPI.h"

@implementation BarCodeModel
- (void)getProductIdWithParams:(NSDictionary *)params
{
    currentNotificationName = @"BarCode-DidGetProductID";
    modelActionType = ModelActionTypeGet;
    [(BarCodeAPI *)[self getAPI] getProductIdWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}
@end
