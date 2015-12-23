//
//  SCCountryStateViewController.h
//  SimiCart
//
//  Created by Tan Hoang on 10/2/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import "SimiViewController.h"
#import "NSDictionary+MutableDeepCopy.h"

@protocol SCStoreViewDelegate <NSObject>
@optional
- (void)didSelectDataWithID:(NSString *)dataID dataCode:(NSString *)dataCode dataName:(NSString *)dataName dataType:(NSString*)dataType;
@end

@interface SCStoreViewController : SimiViewController<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIScrollViewDelegate>{
    NSMutableDictionary *allData;
    NSMutableDictionary *data;
}

/*
 The function tableView cellForRowAtIndexPath raise notification name: "InitializedCountryStateCell-After" after created a cell.
 The function tableView didSelectRowAtIndexPath raise notification name: "DidSelectCountryStateCellAtIndexPath" before TO-DO list in the function.
 */

@property (strong, nonatomic)  UISearchBar *searchBar;
@property (strong, nonatomic)  UITableView *tableView;
@property (strong, nonatomic) NSArray *fixedData;
@property (strong, nonatomic) NSString *dataType;
@property (strong, nonatomic) NSString *selectedName;
@property (strong, nonatomic) NSString *selectedCode;
@property (strong, nonatomic) NSString *selectedId;
@property (strong, nonatomic) NSMutableArray *keys;
@property (strong, nonatomic) id<SCStoreViewDelegate> delegate;

@end
