//
//  BarCodeAPI.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 1/20/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiAPI.h>

extern NSString *const kBarCodeGetProductID;

@interface BarCodeAPI : SimiAPI
- (void)getProductIdWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
@end
