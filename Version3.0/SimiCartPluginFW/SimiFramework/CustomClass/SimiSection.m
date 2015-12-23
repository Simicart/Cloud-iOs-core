//
//  SimiSection.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/25/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiSection.h"

@implementation SimiSection
@synthesize identifier = _identifier;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _headerTitle = nil;
        _footerTitle = nil;
        _rows = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithIdentifier:(NSString *)identifier
{
    if (self = [self init]) {
        self.identifier = identifier;
    }
    return self;
}

- (instancetype)initWithHeaderTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle rows:(NSMutableArray *)rows{
    self = [super init];
    if (self) {
        _headerTitle = headerTitle;
        _footerTitle = footerTitle;
        _rows = rows;
    }
    return self;
}

- (instancetype)initWithHeaderTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle{
    self = [super init];
    if (self) {
        _headerTitle = headerTitle;
        _footerTitle = footerTitle;
        _rows = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addRowWithIdentifier:(NSString *)identifier height:(double)height{
    SimiRow *row = [[SimiRow alloc] initWithIdentifier:identifier height:height];
    [self.rows addObject:row];
    row.sortOrder = [self.rows count] * 100;
}

- (SimiRow *)objectAtIndex:(NSInteger)index{
    return [self.rows objectAtIndex:index];
}

- (void)removeRowsAtIndexes:(NSIndexSet *)indexes{
    [self.rows removeObjectsAtIndexes:indexes];
}

- (void)removeRowAtIndex:(NSUInteger)index{
    [self.rows removeObjectAtIndex:index];
}

- (void)insertObject:(SimiRow *)object inRowsAtIndex:(NSUInteger)index{
    [self.rows insertObject:object atIndex:index];
}

- (void)addObject:(SimiRow *)row{
    [self.rows addObject:row];
    SimiRow *simiRow = [self.rows lastObject];
    if (!simiRow.sortOrder) {
        simiRow.sortOrder = [self.rows count] * 100;
    }
}

- (NSInteger)count{
    return self.rows.count;
}

- (NSMutableArray *)rows{
    return _rows;
}


- (SimiRow *)addRowWithIdentifier:(NSString *)identifier height:(double)height sortOrder:(NSInteger)order
{
    SimiRow *row = [[SimiRow alloc] initWithIdentifier:identifier height:height sortOrder:order];
    [self.rows addObject:row];
    if (!row.sortOrder) {
        row.sortOrder = [self.rows count] * 100;
    }
    return row;
}

- (SimiRow *)getRowByIdentifier:(NSString *)identifier
{
    for (SimiRow *row in self.rows) {
        if ([row.identifier isEqual:identifier]) {
            return row;
        }
    }
    return nil;
}

- (NSUInteger)getRowIndexByIdentifier:(NSString *)identifier
{
    for (NSUInteger index = 0; index < self.rows.count; index++) {
        SimiRow *row = [self.rows objectAtIndex:index];
        if ([row.identifier isEqual:identifier]) {
            return index;
        }
    }
    return NSNotFound;
}

- (void)addRow:(SimiRow *)row
{
    [self.rows addObject:row];
    if (!row.sortOrder) {
        row.sortOrder = [self.rows count] * 100;
    }
}

- (void)removeRowByIdentifier:(NSString *)identifier
{
    for (NSInteger i = [self.rows count]; i > 0; ) {
        SimiRow *row = [self.rows objectAtIndex:--i];
        if ([row.identifier isEqualToString:identifier]) {
            [self.rows removeObjectAtIndex:i];
        }
    }
}

- (void)removeRow:(SimiRow *)row
{
    [self.rows removeObject:row];
}

- (void)removeAll
{
    [self.rows removeAllObjects];
}

- (void)sortItems
{
    [self.rows sortUsingComparator:^NSComparisonResult(SimiRow *row1, SimiRow *row2) {
        if (row2.sortOrder < row1.sortOrder) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
}

@end
