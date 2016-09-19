//
//  SimiTagAPI.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 6/27/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiTagAPI.h"
#import "SimiGlobalVar+StoreLocator.h"
@implementation SimiTagAPI
- (void)getTagListWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector
{
    NSString *url = [NSString stringWithFormat:@"%@%@", @"http://demo.magestore.com/simicart/simipos3/index.php/", kSimiGetTagList];
    [self requestWithURL:url params:params target:target selector:selector header:nil];
}
@end
