//
//  SCAppDelegate.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 4/16/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCAppDelegate : UIResponder<UIApplicationDelegate>

/*
 Notification names:
    - ApplicationDidFinishLaunching
    - ApplicationWillSwitchLanguage
    - ApplicationWillResignActive
    - ApplicationDidEnterBackground
    - ApplicationWillEnterForeground
    - ApplicationDidBecomeActive
    - ApplicationWillTerminate
    - ApplicationOpenURL
    - ApplicationDidRegisterForRemote
    - ApplicationDidReceiveNotificationFromServer
    - ApplicationDidFailToRegisterForRemote
 */

@property (strong, nonatomic) UIWindow *window;

- (void)switchLanguage;

@end
