//
//  SCAppDelegate.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 4/16/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SCAppDelegate.h"
#import "InitWorker.h"
#import "SimiCustomerModel.h"
#import "SimiCacheData.h"
#import "SimiNotificationName.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>

@implementation SCAppDelegate{
    InitWorker *worker;
    id object;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    object = [NSClassFromString(@"TimeLoaderWorker") new];
    [self initRootController];
    if (launchOptions == nil) {
        launchOptions = @{};
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ApplicationDidFinishLaunching object:nil userInfo:@{@"application": application, @"options": launchOptions}];
    return YES;

}

- (void)switchLanguage{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ApplicationWillSwitchLanguage" object:nil];
    [self.window removeFromSuperview];
    [self initRootController];
}

- (void)initRootController{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    worker = [[InitWorker alloc] init];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ApplicationWillResignActive" object:nil userInfo:@{@"application": application}];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ApplicationDidEnterBackground" object:nil userInfo:@{@"application": application}];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ApplicationWillEnterForeground" object:nil userInfo:@{@"application": application}];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ApplicationDidBecomeActive" object:nil userInfo:@{@"application": application}];
    [[SimiCacheData sharedInstance] renewData];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ApplicationWillTerminate" object:nil userInfo:@{@"application": application}];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    BOOL wasHandled = NO;
    NSNumber *number = [NSNumber numberWithBool:wasHandled];
    if (!annotation) {
        annotation = @{};
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ApplicationOpenURL" object:number userInfo:@{@"url":url, @"source_application":sourceApplication, @"annotation":annotation,@"application":application}];
    
    return [number boolValue];

}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    [[NSNotificationCenter defaultCenter] postNotificationName:ApplicationDidRegisterForRemote object:nil userInfo:@{@"application":application, @"device_token":deviceToken}];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ApplicationDidFailToRegisterForRemote" object:nil userInfo:@{@"application":application, @"error":error}];
    NSLog(@"Failed to get token. Error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    /*
    if([[userInfo objectForKey:@"aps"] objectForKey:@"soundUrl"] == nil &&
       [[userInfo objectForKey:@"aps"] objectForKey:@"sound"])
    {
        
        NSString *soundUrl = [NSString stringWithFormat:@"%@", [[userInfo objectForKey:@"aps"] objectForKey:@"soundUrl"]];
        NSString *soundName = [NSString stringWithFormat:@"%@", [[userInfo objectForKey:@"aps"] objectForKey:@"sound"]];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *libDir = [paths objectAtIndex:0];
        NSString *audioConfigFilePath = [libDir stringByAppendingPathComponent:soundName];
        NSFileManager *fileMan = [NSFileManager defaultManager];
        
        if (![fileMan fileExistsAtPath:audioConfigFilePath])
        {
            [fileMan createFileAtPath:audioConfigFilePath contents:[NSData dataWithContentsOfURL:[NSURL URLWithString:soundUrl]] attributes:nil];
        }
        
        SystemSoundID soundFileObject;
        NSURL *url = [NSURL fileURLWithPath:audioConfigFilePath];
        CFURLRef soundLink = (__bridge CFURLRef) url;
        AudioServicesCreateSystemSoundID (soundLink,&soundFileObject);
        AudioServicesPlaySystemSound (soundFileObject);
     
    }
     */
    [[NSNotificationCenter defaultCenter] postNotificationName:ApplicationDidReceiveNotificationFromServer object:nil userInfo:userInfo];
}

@end
