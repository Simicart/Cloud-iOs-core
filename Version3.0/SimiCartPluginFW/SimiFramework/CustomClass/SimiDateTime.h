//
//  SimiDateTime.h
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 6/27/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimiDateTime : NSObject

+ (NSString *)formatDateTime:(NSString *)datetime;
+ (NSString *)formatDate:(NSString *)datetime;
+ (NSString *)formatTime:(NSString *)datetime;

@end
