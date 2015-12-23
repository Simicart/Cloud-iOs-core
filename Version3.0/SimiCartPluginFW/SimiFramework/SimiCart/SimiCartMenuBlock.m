//
//  SimiCartMenuBlock.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiCartMenuBlock.h"
#import "SimiCartSelector.h"
#import "NSObject+SimiObject.h"

#pragma mark - Menu section and row object
@implementation SimiCartMenuItem {
    NSMutableArray *actions;
}
@synthesize image = _image, title = _title, sortOrder = _sortOrder;

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

@implementation SimiCartMenuSection
@synthesize items = _items;

- (instancetype)init
{
    if (self = [super init]) {
        self.items = [NSMutableArray new];
    }
    return self;
}

- (void)addItem:(SimiCartMenuItem *)item
{
    [self.items addObject:item];
}

- (void)removeItem:(SimiCartMenuItem *)item
{
    [self.items removeObject:item];
}

- (void)sortMenuItems
{
    [self.items sortUsingComparator:^NSComparisonResult(SimiCartMenuItem *item1, SimiCartMenuItem *item2) {
        if (item2.sortOrder < item1.sortOrder) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
}
@end

#pragma mark - Menu block
@interface SimiCartMenuBlock ()
@property (weak, nonatomic) SimiCartMenuItem *activatedItem;
@end

@implementation SimiCartMenuBlock
@synthesize activatedItem = _activatedItem, sections;

- (instancetype)init
{
    if (self = [super init]) {
        sections = [NSMutableArray new];
        self.delegate = self;
    }
    return self;
}

#pragma mark - SimiCart Menu Block Methods
// Working with sections
- (SimiCartMenuSection *)getSection:(NSString *)sectionId
{
    for (SimiCartMenuSection *sec in sections) {
        if ([sectionId isEqualToString:(NSString *)sec.simiObjectIdentifier]) {
            return sec;
        }
    }
    return nil;
}

- (SimiCartMenuSection *)createSection:(NSString *)title withId:(NSString *)sectionId sortOrder:(NSInteger)order
{
    SimiCartMenuSection *sec = [self getSection:sectionId];
    if (sec == nil) {
        sec = [[SimiCartMenuSection alloc] init];
        sec.simiObjectIdentifier = sectionId;
        [sections addObject:sec];
    }
    sec.title = title;
    sec.sortOrder = order;
    return sec;
}

- (BOOL)addSection:(SimiCartMenuSection *)section
{
    if (section.simiObjectIdentifier == nil) {
        section.simiObjectIdentifier = [NSString stringWithFormat:@"%lu", (unsigned long)[sections count]];
    }
    if ([self getSection:(NSString *)section.simiObjectIdentifier] == nil) {
        [sections addObject:section];
        return YES;
    }
    return NO;
}

- (SimiCartMenuSection *)newSection:(NSString *)sectionId
{
    SimiCartMenuSection *sec = [self getSection:sectionId];
    if (sec == nil) {
        sec = [SimiCartMenuSection new];
        sec.simiObjectIdentifier = sectionId;
        [sections addObject:sec];
    }
    return sec;
}

- (void)removeSection:(NSString *)sectionId
{
    SimiCartMenuSection *sec = [self getSection:sectionId];
    if (sec) {
        [sections removeObject:sec];
    }
}

- (void)removeAll
{
    [sections removeAllObjects];
}

// Working with Menu items
- (SimiCartMenuItem *)addItem:(NSString *)title image:(UIImage *)image sortOrder:(NSInteger)order inSection:(NSString *)sectionId
{
    SimiCartMenuItem *item = [SimiCartMenuItem new];
    item.title = title;
    item.image = image;
    item.sortOrder = order;
    [self addMenuItem:item inSection:sectionId];
    return item;
}

- (void)addMenuItem:(SimiCartMenuItem *)item inSection:(NSString *)sectionId
{
    SimiCartMenuSection *sec = [self newSection:sectionId];
    [sec addItem:item];
}

- (void)removeMenuItem:(SimiCartMenuItem *)item inSection:(NSString *)sectionId
{
    SimiCartMenuSection *sec = [self getSection:sectionId];
    if (sec) {
        [sec removeItem:item];
    }
}

- (void)clearMenuItemsInSection:(NSString *)sectionId
{
    SimiCartMenuSection *sec = [self getSection:sectionId];
    if (sec) {
        [sec.items removeAllObjects];
    }
}

// Active Menu Item
- (SimiCartMenuItem *)getActiveItem
{
    return self.activatedItem;
}

- (BOOL)isItemActivated:(SimiCartMenuItem *)item
{
    if (self.activatedItem && [self.activatedItem isEqual:item]) {
        return YES;
    }
    return NO;
}

- (void)activeItem:(SimiCartMenuItem *)item
{
    self.activatedItem = item;
}

// Sort Sections
- (void)sortSections
{
    [sections sortUsingComparator:^NSComparisonResult(SimiCartMenuSection *sec1, SimiCartMenuSection *sec2) {
        if (sec2.sortOrder < sec1.sortOrder) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
}

- (SimiCartMenuItem *)itemAtIndexPath:(NSIndexPath *)indexPath
{
    SimiCartMenuSection *section = [sections objectAtIndex:[indexPath section]];
    return (SimiCartMenuItem *)[section.items objectAtIndex:[indexPath row]];
}

- (NSIndexPath *)indexPathForItem:(SimiCartMenuItem *)item
{
    if (item == nil) {
        return nil;
    }
    for (NSUInteger section = 0; section < [sections count]; section++) {
        SimiCartMenuSection *sec = [sections objectAtIndex:section];
        for (NSUInteger row = 0; row < [sec.items count]; row++) {
            SimiCartMenuItem *rowItem = [sec.items objectAtIndex:row];
            if ([item isEqual:rowItem]) {
                return [NSIndexPath indexPathForRow:row inSection:section];
            }
        }
    }
    return nil;
}

#pragma mark - Block Methods
- (UIView *)showingViewPhone:(UIView *)view on:(UIView *)parent
{
    UITableView *tableView = (UITableView *)view;
    if (view == nil) {
        tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    } else if (![view isKindOfClass:[UITableView class]]) {
        tableView = [[UITableView alloc] initWithFrame:view.frame style:UITableViewStyleGrouped];
        [view addSubview:tableView];
    }
    // Sort Menu
    [self sortSections];
    [self.sections makeObjectsPerformSelector:@selector(sortMenuItems)];
    // TableView
    tableView.dataSource = self;
    tableView.delegate = self;
    [tableView reloadData];
    if (view) {
        return view;
    }
    return tableView;
}

#pragma mark - Tableview Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[sections objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menu"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"menu"];
    }
    SimiCartMenuItem *item = [self itemAtIndexPath:indexPath];
    cell.imageView.image = item.image;
    cell.textLabel.text = item.title;
    if ([self isItemActivated:item]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - Tableview Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Item Invoke Action
    SimiCartMenuItem *item = [self itemAtIndexPath:indexPath];
    [item invokeActions];
    // Activate Item
    if ([self getActiveItem]) {
        if (![item isEqual:[self getActiveItem]]) {
            NSIndexPath *oldIndexPath = [self indexPathForItem:[self getActiveItem]];
            [tableView cellForRowAtIndexPath:oldIndexPath].accessoryType = UITableViewCellAccessoryNone;
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    }
    [self activeItem:item];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
