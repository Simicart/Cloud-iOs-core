//
//  SimiGridBlock.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiGridBlock.h"
#import "UIScrollView+SVInfiniteScrolling.h"

@implementation SimiGridBlock
@synthesize blockDelegate = _blockDelegate;
@synthesize collection = _collection, isAjaxLoad = _isAjaxLoad;
@synthesize viewMode = _viewMode;
@synthesize sortField = _sortField, sortDir = _sortDir;
@synthesize filterData = _filterData;

- (instancetype)init
{
    if (self = [super init]) {
        self.delegate = self;
        self.blockDelegate = self;
        self.isAjaxLoad = NO;
        self.viewMode = SimiGridViewModeList;
        self.sortDir = SimiGridSortDirAsc;
    }
    return self;
}

#pragma mark - Collection to show in grid
- (void)clearAndReloadData
{
    if (self.isAjaxLoad && [self.collection isKindOfClass:[NSMutableArray class]]) {
        [(NSMutableArray *)self.collection removeAllObjects];
    }
    if ([self.blockDelegate respondsToSelector:@selector(clearAndReloadData)]) {
        [self.blockDelegate loadMoreData:self];
    }
}

#pragma mark - Block methods
- (UIView *)showingViewPhone:(UIView *)view on:(UIView *)parent
{
    if (self.viewMode == SimiGridViewModeGrid) {
        // Collection View
        if (view == nil || ![view isKindOfClass:[UICollectionView class]]) {
            view = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewLayout alloc] init]];
        }
        UICollectionView *collectionView = (UICollectionView *)view;
        collectionView.dataSource = self;
        collectionView.delegate = self;
        [collectionView reloadData];
    } else {
        // Table View
        if (view == nil || ![view isKindOfClass:[UITableView class]]) {
            view = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        }
        UITableView *tableView = (UITableView *)view;
        tableView.dataSource = self;
        tableView.delegate = self;
        [tableView reloadData];
    }
    if (self.isAjaxLoad) {
        __weak SimiGridBlock *wSelf = self;
        [(UIScrollView *)view addInfiniteScrollingWithActionHandler:^{
            if ([wSelf.blockDelegate respondsToSelector:@selector(loadMoreData:)]) {
                [wSelf.blockDelegate loadMoreData:wSelf];
            }
        }];
        if (![self.collection count]) {
            [self clearAndReloadData];
        }
    }
    return view;
}

#pragma mark - Table view datasource and delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.collection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Grid"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Grid"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.blockDelegate respondsToSelector:@selector(didSelectRow:indexPath:)]) {
        [self.blockDelegate didSelectRow:self indexPath:indexPath];
    }
}

#pragma mark - Collection view datasource and delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.collection count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Grid"];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Grid" forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.blockDelegate respondsToSelector:@selector(didSelectRow:indexPath:)]) {
        [self.blockDelegate didSelectRow:self indexPath:indexPath];
    }
}

@end
