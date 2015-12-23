//
//  SCRefineViewController.h
//  SimiCart
//
//  Created by Tan on 7/31/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import "SimiViewController.h"

@protocol RefineViewDelegate <NSObject>
@optional
- (void)didRefineWithSortType:(ProductCollectionSortType)sortType categoryID:(NSString *)cateID cateogryName:(NSString *)categoryName;
- (void)didRefineWithSortType:(ProductCollectionSortType)sortType;
@end

@interface SCRefineViewController : SimiViewController<UITableViewDataSource, UITableViewDelegate>{
    NSIndexPath *chosenSortOptionIndexPath;
}

/*
 The function tableView cellForRowAtIndexPath raise notification name: "InitializedRefineCell-After" after created a cell.
 The function tableView didSelectRowAtIndexPath raise notification name: "DidSelectRefineCellAtIndexPath" before TO-DO list in the function.
 */

@property (strong, nonatomic) UITableView *tableViewRefine;
@property (strong, nonatomic) NSMutableArray *sortTypeLabels;
@property (nonatomic) ProductCollectionSortType sortType;
@property (strong, nonatomic) id<RefineViewDelegate> delegate;

@end
