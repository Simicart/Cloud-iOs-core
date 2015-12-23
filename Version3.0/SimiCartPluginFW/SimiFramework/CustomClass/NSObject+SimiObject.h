//
//  NSObject+SimiObject.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/21/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NSObject (SimiObject)

// Object identifier
@property (strong, nonatomic) NSObject *simiObjectIdentifier;
@property (strong, nonatomic) NSString *simiObjectName;
@property (nonatomic) BOOL isDiscontinue;

// Notification methods
- (void)removeObserverForNotification:(NSNotification *)noti;
- (void)didReceiveNotification:(NSNotification *)noti;
- (void)postNotificationName:(NSString *)notificationName object:(id)anObject userInfo:(NSDictionary *)aUserInfo;

// Singleton pattern
+ (instancetype)singleton;

// IB Localized
/**
 * This method is used to translate strings in .xib files.
 * Using the "User Defined Runtime Attributes" set an entry like:
 * 
 * Key Path: textLocalized
 * Type: String
 * Value: {THE TRANSLATION KEY}
 * 
 */
- (void)setTextLocalized:(NSString *)key;

@end
