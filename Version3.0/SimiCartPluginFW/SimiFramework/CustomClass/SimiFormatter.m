//
//  SimiFormatter.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 6/27/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiFormatter.h"

@implementation SimiFormatter

+ (instancetype)sharedInstance{
    static SimiFormatter *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SimiFormatter alloc] init];
    });
    return _sharedInstance;
}

-(NSString *) priceWithPrice:(NSString *)price{
    NSString* currencyPosition = [[SimiGlobalVar sharedInstance] currencyPosition];
    NSString* currencySymbol = [[SimiGlobalVar sharedInstance] currencySymbol];
    NSString* thousandSeparator = [[SimiGlobalVar sharedInstance] thousandSeparator];
    NSString* decimalSeparator = [[SimiGlobalVar sharedInstance] decimalSeparator];
    int numberOfDecimals = [[[SimiGlobalVar sharedInstance] numberOfDecimals] intValue];
    NSNumberFormatter * formatter =  [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:numberOfDecimals];
    [formatter setMinimumFractionDigits:numberOfDecimals];
    [formatter setGroupingSeparator:thousandSeparator];
    [formatter setGroupingSize:3];
    [formatter setUsesGroupingSeparator:YES];
    [formatter setDecimalSeparator:decimalSeparator];
    [formatter setLocale:[NSLocale currentLocale]];
    price = [formatter stringFromNumber:[NSNumber numberWithFloat:[price floatValue]]];
    if([currencyPosition isEqualToString:@"left"]){
        return [NSString stringWithFormat:@"%@ %@", currencySymbol, price];
    }else if([currencyPosition isEqualToString:@"right"]){
        return [NSString stringWithFormat:@"%@ %@", price, currencySymbol];
    }else if([currencyPosition isEqualToString:@"left_space"]){
        return [NSString stringWithFormat:@" %@ %@", currencySymbol, price];
    }else if([currencyPosition isEqualToString:@"right_space"]){
        return [NSString stringWithFormat:@"%@ %@ ", price, currencySymbol];
    }else {
        return [NSString stringWithFormat:@"%@ %@", price, currencySymbol];
    }
}
- (NSString *)priceByLocalizeNumber:(NSNumber *)number locale:(NSLocale *)locale{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.locale = locale;
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setCurrencyCode:[[SimiGlobalVar sharedInstance] currencyCode]];
    if (![[[SimiGlobalVar sharedInstance] currencySymbol] isEqualToString:@""]) {
        [formatter setCurrencySymbol:[[SimiGlobalVar sharedInstance] currencySymbol]];
    }
    NSString *groupingSeparator = [formatter.locale objectForKey:NSLocaleGroupingSeparator];
    
    [formatter setGroupingSeparator:groupingSeparator];
    [formatter setGroupingSize:3];
    
    [formatter setMaximumFractionDigits:2];
    
    [formatter setAlwaysShowsDecimalSeparator:NO];
    [formatter setUsesGroupingSeparator:YES];
    
    NSString *formattedString = [formatter stringFromNumber:number];
    return formattedString;
}

- (NSString *)priceByLocalizeNumber:(NSNumber *)number{
    NSString *localeIdentifier = LOCALE_IDENTIFIER;
    if (localeIdentifier == nil || [localeIdentifier isEqualToString:@""]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SimiFormatter-MissLocale" object:nil];
    }
    NSLocale *locale = [NSLocale localeWithLocaleIdentifier:localeIdentifier];
    return [self priceByLocalizeNumber:number locale:locale];
}


@end
