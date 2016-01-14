//
//  SCHomeViewController.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/3/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiViewController.h"
#import "SimiTableView.h"
#import "SCLoginViewController.h"
#import "SCAccountViewController.h"
#import "SimiProductModelCollection.h"
#import "KASlideShow.h"
#import "SCWebViewController.h"
#import "SimiBannerModelCollection.h"
#import "SCHomeSpotProductCell.h"
#import "SimiSpotModelCollection.h"
#import "SimiCategoryModelCollection.h"
#import "SimiCategoryModel.h"
#import "SKPSMTPMessage.h"

static NSString *isFake = @"isFake";
static NSString *HOME_BANNER_CELL   = @"HomeCellBanner";
static NSString *HOME_CATEGORY_CELL = @"HomeCategoryCell";
static NSString *HOME_DEFAULT_CELL  = @"HomeCellDefault";
static NSString *HOME_LOADING_CELL  = @"HomeCellLoading";
static NSString *HOME_SPOT_CELL = @"HOME_SPOT_CELL";


static NSString *HOME_CATEGORY_COLLECTION_VIEW  = @"HomeCategoryCollectionView";
static NSString *HOME_CATEGORY_COLLECTION_VIEW_CELL = @"HomeCategoryCollectionViewCell";
static NSString *HOME_SPOT_PRODUCT_COLLECTION_VIEW = @"HomeSpotProductCollectionView";
static NSString *HOME_SPOT_PRODUCT_COLLECTION_CELL = @"HomeSpotProductCollectionViewCell";

@interface SCHomeViewController : SimiViewController<UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, SKPSMTPMessageDelegate>
{
    int countNumberSpotDidGetData;
}

/*
 The function tableView cellForRowAtIndexPath raise notification name: "InitializedHomeCell-After" after created a cell.
 The function tableView didSelectRowAtIndexPath raise notification name: "DidSelectHomeCellAtIndexPath" before TO-DO list in the function.
 */

@property (strong, nonatomic) SimiTableView *tableViewHome;
@property (strong, nonatomic) UIImageView *imageViewLogo;
@property (strong, nonatomic) SimiBannerModelCollection *bannerCollection;
@property (strong, nonatomic) SimiSpotModelCollection *spotCollection;
@property (strong, nonatomic) SimiCategoryModelCollection *homeCategoryModelCollection;
@property (strong, nonatomic) SimiCategoryModel *categoryModel;
@property (strong, nonatomic) KASlideShow *bannerSlider;
@property (strong, nonatomic) NSMutableArray *cells;
@property (strong, nonatomic) UISearchBar *searchBarHome;
@property (strong, nonatomic) NSString *keySearch;
@property (strong, nonatomic) UIImageView *imageFog;
@property (strong, nonatomic) UIView *searchBarBackground;
@property (strong, nonatomic) UICollectionView * categoryCollectionView;
@property (strong, nonatomic) NSMutableArray *spotArray;


//  Check xem Data đã trả về hay chưa.
@property (nonatomic) BOOL isDidGetBanner;
@property (nonatomic) BOOL isDidGetHomeCategory;
@property (nonatomic) BOOL isDidGetSpotProducts;


- (void)getBanners;
- (void)getSpotCollection;
- (void)getHomeCategories;
- (void)getBestSellerProducts:(SimiModel*) spotModel;
- (void)getNewlyUpdatedProducts:(SimiModel*) spotModel;
- (void)getRecentAddedProducts:(SimiModel*) spotModel;
- (void)getFeatureProducts:(SimiModel*) spotModel;

@end
