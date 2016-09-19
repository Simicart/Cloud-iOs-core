//
//  SCEmailContactAPI.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 10/24/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
@interface SCEmailContactAPI : SimiAPI
- (void)getEmailContactWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
@end
