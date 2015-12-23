//
//  SimiSection.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/25/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimiRow.h"

@interface SimiSection : NSObject
@property (strong, nonatomic) NSString *identifier;

@property (strong, nonatomic) NSString *headerTitle;
@property (strong, nonatomic) NSString *footerTitle;
@property (strong, nonatomic) NSMutableArray *rows;

- (instancetype)init;
- (instancetype)initWithIdentifier:(NSString *)identifier;
- (instancetype)initWithHeaderTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle;
- (instancetype)initWithHeaderTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle rows:(NSMutableArray *)rows;
- (void)addRowWithIdentifier:(NSString *)identifier height:(double)height; // auto generate sort order
- (void)insertObject:(SimiRow *)object inRowsAtIndex:(NSUInteger)index;
- (void)removeRowsAtIndexes:(NSIndexSet *)indexes;
- (void)removeRowAtIndex:(NSUInteger)index;
- (void)addObject:(SimiRow *)row;
- (SimiRow *)objectAtIndex:(NSInteger)index;
- (NSInteger)count;
- (NSMutableArray *)rows;

- (SimiRow *)addRowWithIdentifier:(NSString *)identifier height:(double)height sortOrder:(NSInteger)order;
- (SimiRow *)getRowByIdentifier:(NSString *)identifier;
- (NSUInteger)getRowIndexByIdentifier:(NSString *)identifier;
- (void)addRow:(SimiRow *)row;
- (void)removeRowByIdentifier:(NSString *)identifier;
- (void)removeRow:(SimiRow *)row;
- (void)removeAll;

- (void)sortItems;

@end
