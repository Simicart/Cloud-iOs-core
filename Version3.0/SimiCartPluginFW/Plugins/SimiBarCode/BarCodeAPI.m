//
//  BarCodeAPI.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 1/20/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "BarCodeAPI.h"
NSString *const kBarCodeGetProductID = @"simibarcode/index/checkCode/";

@implementation BarCodeAPI
- (void)getProductIdWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@", kBaseURL, kBarCodeGetProductID];
    [self requestWithURL:url params:params target:target selector:selector header:nil];
}
@end
