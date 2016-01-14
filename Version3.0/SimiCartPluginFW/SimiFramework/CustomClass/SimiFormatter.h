//
//  SimiFormatter.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 6/27/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimiFormatter : NSObject

+ (instancetype)sharedInstance;
- (NSString *)priceByLocalizeNumber:(NSNumber *)number;
- (NSString *)priceByLocalizeNumber:(NSNumber *)number locale:(NSLocale *)locale;
- (NSString *) priceWithPrice:(NSString *) price;
@end
