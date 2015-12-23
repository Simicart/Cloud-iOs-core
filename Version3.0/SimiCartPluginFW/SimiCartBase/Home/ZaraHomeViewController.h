//
//  ZaraHomeViewController.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/3/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//
#import "SimiCartBundle.h"
#import "SimiTable.h"
#import "SCCategoryViewController.h"
#import "SCProductListViewController.h"
#import "ZaraHomeViewSection.h"
#import "ZaraHomeViewRow.h"
#import "SCHomeViewController.h"

@interface ZaraHomeViewController : SimiViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UISearchBarDelegate>

@property (strong, nonatomic) SimiSpotModelCollection *spotCollection;
@property (strong, nonatomic) SimiCategoryModelCollection *homeCategoryModelCollection;
@property (nonatomic, strong) SimiTable *cellTables;
@property (nonatomic, strong) NSMutableArray *currentRowsAllow; // Save indexPaths row is showing
@property (nonatomic, strong) UIImageView *searchImage;
@property (strong, nonatomic) SimiTableView *tableViewHome;
@property (strong, nonatomic) UISearchBar *searchBarHome;
@property (strong, nonatomic) NSString *keySearch;
@property (strong, nonatomic) UIImageView *imageFog;
@property (strong, nonatomic) UIView *searchBarBackground;

- (void)getSpotCollection;
- (void)getHomeCategories;
- (void)didReceiveNotification:(NSNotification *)noti;
@end
