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
    if([currencyPosition isEqualToString:@"left"]){
        return [NSString stringWithFormat:@" %@ %.2f ", currencySymbol, [price floatValue]];
    }else{
        return [NSString stringWithFormat:@" %.2f %@ ", [price floatValue], currencySymbol];
    }
}


@end
