//
//  SCEmailContactAPI.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 10/24/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCEmailContactAPI.h"
#import "SimiGlobalVar+EmailContact.h"
@implementation SCEmailContactAPI
- (void)getEmailContactWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    NSString *url = [NSString stringWithFormat:@"%@%@", @"http://demo.magestore.com/simicart/simipos3/index.php/", kSCGetEmailContact];
    [self requestWithURL:url params:params target:target selector:selector header:nil];
}
@end
