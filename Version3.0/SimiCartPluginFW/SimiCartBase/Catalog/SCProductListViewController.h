//
//  SCProductListViewController.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/11/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiViewController.h"
#import "SimiTableView.h"
#import "SimiProductModelCollection.h"
#import "SCRefineViewController.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "ILTranslucentView.h"
#import "SCFilterViewController.h"
#import "SCProductCollectionViewController.h"

@interface SCProductListViewController : SimiViewController<UITableViewDataSource, UITableViewDelegate, RefineViewDelegate, SCFilterViewControllerDelegate, UISearchBarDelegate, SCProductCollectionViewController_Delegate, UIScrollViewDelegate>
{
    float paddingTop;
    float paddingBottom;
}
/*
 The function tableView cellForRowAtIndexPath raise notification name: "InitializedProductListCell-After" after created a cell.
 The function tableView didSelectRowAtIndexPath raise notification name: "DidSelectProductListCellAtIndexPath" before TO-DO list in the function.
 */

@property (strong, nonatomic) SimiTableView *tableViewProductCollection;
@property (strong, nonatomic) SimiProductModelCollection *productCollection;
@property (nonatomic) ProductCollectionSortType sortType;
@property (strong, nonatomic) SCFilterViewController *filterViewController;
@property (nonatomic) ProductListGetProductType productListGetProductType;
@property (nonatomic, strong) SCProductCollectionViewController *productCollectionViewController;

@property (strong, nonatomic) UIView *viewToolBar;
@property (strong, nonatomic) NSString *categoryID;
@property (strong, nonatomic) UIButton *btnSort;
@property (strong, nonatomic) UIButton *btnFilter;
@property (strong, nonatomic) UIButton *btnChangeLayout;
@property (strong, nonatomic) NSDictionary *filterParam;
@property (nonatomic, strong) NSString *categoryName;
@property (nonatomic) BOOL isProductShowGrid;
@property (nonatomic, strong) NSMutableArray *arrayProductsID;
@property (nonatomic) float lastContentOffset;
@property (nonatomic) int maxNumberProduct;

@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) UISearchBar *searchProduct;
@property (nonatomic, strong) UIImageView *imageFogWhenSearch;
@property (nonatomic, strong) UITableView *tableViewSearchOption;
@property (strong, nonatomic) UIView *searchBarBackground;
@property (nonatomic, strong) NSString *keySearchProduct;
@property (nonatomic) BOOL isSearchOnAllProducts;

//Axe added
@property (nonatomic, strong) NSDictionary* spotModel;

@property (nonatomic) BOOL isFirstTimeGetData;

- (void)getProducts;
- (void)didGetProducts:(NSNotification *)noti;
@end
