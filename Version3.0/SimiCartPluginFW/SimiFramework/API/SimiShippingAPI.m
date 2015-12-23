//
//  SimiShippingAPI.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 12/21/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import "SimiShippingAPI.h"

@implementation SimiShippingAPI
- (void)addAddressForQuote:(NSDictionary *)params extendsUrl:(NSString *)extendsUrl target:(id)target selector:(SEL)selector{
    NSString *url = [NSString stringWithFormat:@"%@%@%@", kBaseURL, kSimiQuotes, extendsUrl];
    [self requestWithMethod:PUT URL:url params:params target:target selector:selector header:nil];
}
@end
