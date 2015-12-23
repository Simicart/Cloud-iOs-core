//
//  SimiCartMenuBlock.h
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiBlock.h"

#pragma mark - Menu section and row object
@interface SimiCartMenuItem : SimiMutableDictionary
@property (strong, nonatomic) UIImage *image;
@property (copy, nonatomic) NSString *title;
@property (nonatomic) NSInteger sortOrder;

- (void)addTarget:(id)target action:(SEL)action;
- (void)addTargetUsingBlock:(void(^)())block;
- (void)invokeActions;

@end

@interface SimiCartMenuSection : SimiCartMenuItem
@property (strong, nonatomic) NSMutableArray *items;

- (void)addItem:(SimiCartMenuItem *)item;
- (void)removeItem:(SimiCartMenuItem *)item;

- (void)sortMenuItems;

@end

#pragma mark - Menu block
@interface SimiCartMenuBlock : SimiBlock <SimiBlockDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSMutableArray *sections;
// Working with Sections
- (SimiCartMenuSection *)getSection:(NSString *)sectionId;
- (SimiCartMenuSection *)createSection:(NSString *)title withId:(NSString *)sectionId sortOrder:(NSInteger)order;
- (BOOL)addSection:(SimiCartMenuSection *)section;
- (SimiCartMenuSection *)newSection:(NSString *)sectionId;
- (void)removeSection:(NSString *)sectionId;
- (void)removeAll;

// Working with Menu Items
- (SimiCartMenuItem *)addItem:(NSString *)title image:(UIImage *)image sortOrder:(NSInteger)order inSection:(NSString *)sectionId;
- (void)addMenuItem:(SimiCartMenuItem *)item inSection:(NSString *)sectionId;
- (void)removeMenuItem:(SimiCartMenuItem *)item inSection:(NSString *)sectionId;
- (void)clearMenuItemsInSection:(NSString *)sectionId;

// Activate Menu Item
- (SimiCartMenuItem *)getActiveItem;
- (BOOL)isItemActivated:(SimiCartMenuItem *)item;
- (void)activeItem:(SimiCartMenuItem *)item;

// Sort Sections
- (void)sortSections;

- (SimiCartMenuItem *)itemAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForItem:(SimiCartMenuItem *)item;

@end
