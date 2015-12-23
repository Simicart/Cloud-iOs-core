//
//  SimiGridBlock.h
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiBlock.h"

@class SimiGridBlock;

typedef NS_ENUM(NSInteger, SimiGridViewMode) {
    SimiGridViewModeList,
    SimiGridViewModeGrid
};

typedef NS_ENUM(NSInteger, SimiGridSortDir) {
    SimiGridSortDirAsc,
    SimiGridSortDirDesc
};

#pragma mark - Grid Delegate
@protocol SimiGridBlockDelegate <NSObject>
@optional
// Collection to show in Grid
- (void)loadMoreData:(SimiGridBlock *)block;

// Select row action
- (void)didSelectRow:(SimiGridBlock *)block indexPath:(NSIndexPath *)indexPath;
@end

#pragma mark - Grid Block
@interface SimiGridBlock : SimiBlock <SimiGridBlockDelegate, SimiBlockDelegate, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) id<SimiGridBlockDelegate> blockDelegate;
// Collection to show in grid
@property (strong, nonatomic) NSArray *collection; // Array of list items : [NSDictionary]
@property (nonatomic) BOOL isAjaxLoad; // Load more items from server
- (void)clearAndReloadData;

// View Mode
@property (nonatomic) SimiGridViewMode viewMode;

// Sort & Filter data
@property (strong, nonatomic) NSString *sortField;
@property (nonatomic) SimiGridSortDir sortDir;

@property (strong, nonatomic) NSMutableArray *filterData;

@end
