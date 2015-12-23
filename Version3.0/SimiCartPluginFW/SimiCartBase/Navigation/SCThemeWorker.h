//
//  SCThemeWorker.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/3/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCNavigationBarPhone.h"
#import "SCNavigationBarPad.h"
@interface SCThemeWorker : NSObject
+ (SCThemeWorker *)sharedInstance;
@property (nonatomic, strong) SCNavigationBarPhone *navigationBarPhone;
@property (nonatomic, strong) SCNavigationBarPad *navigationBarPad;
@property (nonatomic, strong) UITabBarController *rootController;
@end
