//
//  SCOrderHistoryViewController.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/4/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiViewController.h"
#import "SimiTableView.h"
#import "SimiOrderModelCollection.h"
#import "UIScrollView+SVInfiniteScrolling.h"

@interface SCOrderHistoryViewController : SimiViewController<UITableViewDataSource, UITableViewDelegate>

/*
 The function tableView cellForRowAtIndexPath raise notification name: "InitializedOrderHistoryCell-After" after created a cell.
 The function tableView didSelectRowAtIndexPath raise notification name: "DidSelectOrderHistoryCellAtIndexPath" before TO-DO list in the function.
 */

@property (strong, nonatomic) SimiTableView *tableViewOrder;
@property (strong, nonatomic) SimiOrderModelCollection *orderCollection;
@property (nonatomic) BOOL isLoadData;

@end
