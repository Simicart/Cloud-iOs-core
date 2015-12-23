//
//  SimiCartTabsBlock.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiCartTabsBlock.h"
#import "SimiCartSelector.h"

NSString *const SimiCartTabChangedNotification = @"SimiCartTabChangedNotification";

#pragma mark - Tab Item
@implementation SimiCartTabItem {
    NSMutableArray *actions;
}
@synthesize title = _title, content = _content, sortOrder = _sortOrder;

- (void)addTarget:(id)target action:(SEL)action
{
    if (actions == nil) {
        actions = [NSMutableArray new];
    }
    [actions addObject:[[SimiCartSelector alloc] initWithTarget:target action:action]];
}

- (void)addTargetUsingBlock:(void (^)())block
{
    if (actions == nil) {
        actions = [NSMutableArray new];
    }
    [actions addObject:block];
}

- (void)invokeActions
{
    for (id action in actions) {
        if ([action isKindOfClass:[SimiCartSelector class]]) {
            [(SimiCartSelector *)action invoke:self];
        } else {
            ((void (^)())action)();
        }
    }
}

@end

#pragma mark - Tab Block
@interface SimiCartTabsBlock()
@property (weak, nonatomic) SimiCartTabItem *activatedTab;
@end

@implementation SimiCartTabsBlock
@synthesize autoResize = _autoResize, tabs = _tabs, activatedTab = _activatedTab;

- (instancetype)init
{
    if (self = [super init]) {
        self.delegate = self;
    }
    return self;
}

// Tab Methods
- (SimiCartTabItem *)addTab:(NSString *)title content:(UIView *)content sortOrder:(NSInteger)order
{
    SimiCartTabItem *tab = [SimiCartTabItem new];
    tab.title = title;
    tab.content = content;
    tab.sortOrder = order;
    [self addTabItem:tab];
    return tab;
}

- (void)addTabItem:(SimiCartTabItem *)tab
{
    if (self.tabs == nil) {
        self.tabs = [NSMutableArray new];
    }
    [self.tabs addObject:tab];
}

- (void)removeTabItem:(SimiCartTabItem *)tab
{
    [self.tabs removeObject:tab];
}

- (void)clearTabs
{
    [self.tabs removeAllObjects];
}


- (SimiCartTabItem *)getActiveTab
{
    return self.activatedTab;
}

- (BOOL)isTabActivated:(SimiCartTabItem *)tab
{
    if (self.activatedTab && [self.activatedTab isEqual:tab]) {
        return YES;
    }
    return NO;
}

- (void)activeTab:(SimiCartTabItem *)tab
{
    self.activatedTab = tab;
}

- (void)sortTabs
{
    [self.tabs sortUsingComparator:^NSComparisonResult(SimiCartTabItem *tab1, SimiCartTabItem *tab2) {
        if (tab1.sortOrder > tab2.sortOrder) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
}

// Block Methods
- (UIView *)showingViewPhone:(UIView *)view on:(UIView *)parent
{
    if (view == nil) {
        CGRect frame = CGRectMake(0, 0, 320, 480);
        if (parent) {
            frame = parent.frame;
        }
        view = [[UIScrollView alloc] initWithFrame:frame];
    }
    // Sort Tabs
    [self sortTabs];
    if ([self getActiveTab] == nil && [self.tabs count]) {
        [self setActivatedTab:[self.tabs objectAtIndex:0]];
    }
    // Show Tabs: Title
    UISegmentedControl *controls = (UISegmentedControl *)[view viewWithTag:11];
    if (controls == nil) {
        controls = [[UISegmentedControl alloc] initWithFrame:CGRectMake(10, 10, 0, 29)];
        [controls setApportionsSegmentWidthsByContent:YES];
        [controls setTag:11];
        [controls addTarget:self action:@selector(switchToNewTab:) forControlEvents:UIControlEventValueChanged];
        [view addSubview:controls];
    } else {
        [controls removeAllSegments];
    }
    for (NSUInteger i = 0; i < [self.tabs count]; i++) {
        SimiCartTabItem *tab = [self.tabs objectAtIndex:i];
        [controls insertSegmentWithTitle:tab.title atIndex:i animated:NO];
        if ([self isTabActivated:tab]) {
            [controls setSelectedSegmentIndex:i];
        }
    }
    controls.center = CGPointMake(view.center.x, controls.center.y);
    
    // Show Tabs: Content
    [self showTabContent:(UIScrollView *)view];
    
    return view;
}

- (void)showTabContent:(UIScrollView *)view
{
    UIView *oldContent = [view viewWithTag:22];
    if (oldContent) {
        [oldContent removeFromSuperview];
    }
    SimiCartTabItem *activatedTab = [self getActiveTab];
    activatedTab.content.tag = 22;
    [view addSubview:activatedTab.content];
    
    CGRect frame = activatedTab.content.frame;
    frame.origin.y = 44;
    activatedTab.content.frame = frame;
    activatedTab.content.center = CGPointMake(view.center.x, activatedTab.content.center.y);
    
    view.contentSize = CGSizeMake(view.frame.size.width, 49 + frame.size.height);
    
    if (self.autoResize) {
        // Resize content view
        CGRect resizeFrame = view.frame;
        resizeFrame.size.height = view.contentSize.height;
        view.frame = resizeFrame;
    }
}

- (void)switchToNewTab:(UISegmentedControl *)controls
{
    SimiCartTabItem *selected = [self.tabs objectAtIndex:controls.selectedSegmentIndex];
    [self activeTab:selected];
    [self showTabContent:(UIScrollView *)[controls superview]];
    [[NSNotificationCenter defaultCenter] postNotificationName:SimiCartTabChangedNotification object:self];
}

@end
