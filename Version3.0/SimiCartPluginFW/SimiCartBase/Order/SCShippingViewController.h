//
//  SCShippingViewController.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/20/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiViewController.h"
#import "SimiShippingModelCollection.h"
#import "SimiTableView.h"

@protocol SCShippingDelegate <NSObject>

- (void)didSelectShippingMethodAtIndex:(NSInteger)index;

@end

@interface SCShippingViewController : SimiViewController<UITableViewDataSource, UITableViewDelegate>

/*
 The function tableView cellForRowAtIndexPath raise notification name: "InitializedShippingCell-After" after created a cell.
 The function tableView didSelectRowAtIndexPath raise notification name: "DidSelectShippingCellAtIndexPath" before TO-DO list in the function.
 */

@property (strong, nonatomic) SimiTableView *tableViewShipping;
@property (strong, nonatomic) SimiShippingModelCollection *methodCollection;
@property (strong, nonatomic) id<SCShippingDelegate> delegate;
@property (nonatomic) NSInteger selectedMethodRow;

@end
