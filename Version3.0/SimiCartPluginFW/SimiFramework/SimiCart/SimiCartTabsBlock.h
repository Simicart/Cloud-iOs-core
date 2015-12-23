//
//  SimiCartTabsBlock.h
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiBlock.h"

extern NSString *const SimiCartTabChangedNotification;

#pragma mark - Tab Item
@interface SimiCartTabItem : SimiMutableDictionary
@property (copy, nonatomic) NSString *title;
@property (strong, nonatomic) UIView *content;
@property (nonatomic) NSInteger sortOrder;

- (void)addTarget:(id)target action:(SEL)action;
- (void)addTargetUsingBlock:(void(^)())block;
- (void)invokeActions;

@end

#pragma mark - Tab Block
@interface SimiCartTabsBlock : SimiBlock <SimiBlockDelegate>
@property (nonatomic) BOOL autoResize;
@property (strong, nonatomic) NSMutableArray *tabs;

- (SimiCartTabItem *)addTab:(NSString *)title content:(UIView *)content sortOrder:(NSInteger)order;
- (void)addTabItem:(SimiCartTabItem *)tab;
- (void)removeTabItem:(SimiCartTabItem *)tab;
- (void)clearTabs;

- (SimiCartTabItem *)getActiveTab;
- (BOOL)isTabActivated:(SimiCartTabItem *)tab;
- (void)activeTab:(SimiCartTabItem *)tab;

- (void)sortTabs;

@end
