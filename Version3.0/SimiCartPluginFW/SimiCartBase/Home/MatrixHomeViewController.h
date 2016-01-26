//
//  SCHomeViewController_ThemeOne.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/8/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimiCartBundle.h"
#import "SimiBannerModelCollection.h"
#import "SimiTableView.h"
#import "SimiCategoryModel.h"
#import "SimiProductModel.h"
#import "MatrixSlideShow.h"
#import "MatrixCategoryProductCell.h"
#import "MatrixSpotProductCell.h"
#import "SCHomeViewController.h"
#import "SimiCategoryModelCollection.h"

@interface MatrixHomeViewController:SimiViewController <UITableViewDataSource, UITableViewDelegate, MatrixCategoryProductCell_Delegate, MatrixSpotProductCell_Delegate, UISearchBarDelegate, UIScrollViewDelegate>


@property (strong, nonatomic) SimiSpotModelCollection *spotCollection;
@property (strong, nonatomic) SimiCategoryModelCollection* homeCategoryModelCollection;
@property (strong, nonatomic) MatrixSlideShow *themeBannerSlider;
//Axe added
@property (strong, nonatomic) UISearchBar *searchBarHome;
@property (strong, nonatomic) UIView *searchBarBackground;
@property (strong, nonatomic) NSString *keySearch;
@property (strong, nonatomic) UIImageView *imageFog;
//
@property (strong, nonatomic) MatrixCategoryProductCell *viewCate01;
@property (strong, nonatomic) MatrixCategoryProductCell *viewCate02;
@property (strong, nonatomic) MatrixCategoryProductCell *viewCate03;
@property (strong, nonatomic) MatrixCategoryProductCell *viewAllCate;
@property (strong, nonatomic) NSMutableArray *cells;
@property (strong, nonatomic) SimiBannerModelCollection *bannerCollection;
@property (strong, nonatomic) SimiCategoryModel* categoryModel;
@property (strong, nonatomic) SimiTableView *tableViewHome;

- (void)getBanners;
- (void)setViewCategory;
- (void)getSpotCollection;
- (void)getHomeCategories;

@property (nonatomic) BOOL isDidGetBanner;
@property (nonatomic) BOOL isDidGetCategory;
@property (nonatomic) BOOL isDidGetSpotProduct;
@end
