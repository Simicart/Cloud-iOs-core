//
//  NSObject+SimiObject.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/21/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "NSObject+SimiObject.h"

@implementation NSObject (SimiObject)

- (void)postNotificationName:(NSString *)notificationName object:(id)anObject userInfo:(NSDictionary *)aUserInfo{
    notificationName = [NSString stringWithFormat:@"%@-%@", NSStringFromClass(self.class), notificationName];
    if (aUserInfo) {
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:anObject userInfo:aUserInfo];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:anObject];
    }
}

#pragma mark - singleton pattern
+ (instancetype)singleton
{
    static NSMutableDictionary *_singletons;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singletons = [NSMutableDictionary new];
    });
    // Check and create dictionary
    id _instance = nil;
    @synchronized(self) {
        NSString *klass = NSStringFromClass(self);
        _instance = [_singletons objectForKey:klass];
        if (_instance == nil) {
            _instance = [self new];
            [_singletons setValue:_instance forKey:klass];
        }
    }
    // Return singleton instance
    return _instance;
}

#pragma mark - notification
- (void)removeObserverForNotification:(NSNotification *)noti{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:noti.name object:nil];
}

- (void)didReceiveNotification:(NSNotification *)noti{
    [self removeObserverForNotification:noti];
    
}

#pragma mark - object identifier
- (void)setSimiObjectIdentifier:(NSObject *)object {
    objc_setAssociatedObject(self, @selector(simiObjectIdentifier), object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSObject *)simiObjectIdentifier {
    return objc_getAssociatedObject(self, @selector(simiObjectIdentifier));
}

- (void)setSimiObjectName:(NSString *)object {
    objc_setAssociatedObject(self, @selector(simiObjectName), object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)simiObjectName {
    return objc_getAssociatedObject(self, @selector(simiObjectName));
}

- (void)setIsDiscontinue:(BOOL)isDiscont{
    NSNumber *number = [NSNumber numberWithBool:isDiscont];
    objc_setAssociatedObject(self, @selector(isDiscontinue), number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isDiscontinue{
    NSNumber *number = objc_getAssociatedObject(self, @selector(isDiscontinue));
    return [number boolValue];
}

// IB Localized
- (void)setTextLocalized:(NSString *)key
{
    if ([self isKindOfClass:[UIButton class]]) {
        [(UIButton *)self setTitle:SCLocalizedString(key) forState:UIControlStateNormal];
    } else if ([self isKindOfClass:[UITextField class]]) {
        [(UITextField *)self setPlaceholder:SCLocalizedString(key)];
    } else if ([self isKindOfClass:[UILabel class]]) {
        [(UILabel *)self setText:SCLocalizedString(key)];
    } else if ([self isKindOfClass:[UISearchBar class]]) {
        [(UISearchBar *)self setPlaceholder:SCLocalizedString(key)];
    } else if ([self isKindOfClass:[UIBarButtonItem class]]) {
        [(UIBarButtonItem *)self setTitle:SCLocalizedString(key)];
    }
}

@end
