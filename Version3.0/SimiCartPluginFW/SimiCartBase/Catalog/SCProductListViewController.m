//
//  SCProductListViewController.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/11/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SCProductListViewController.h"
#import "SimiResponder.h"
#import "SCProductViewController.h"
#import "SimiProductModel.h"
#import "SCProductListCell.h"
#import "SCProductViewController.h"
#import "MBProgressHUD.h"
#import "SimiCacheData.h"
@interface SCProductListViewController ()
@property (nonatomic, strong) NSString *keyCacheData;
@end

@implementation SCProductListViewController

@synthesize tableViewProductCollection, productCollection, categoryID, sortType, searchBarBackground;
@synthesize viewToolBar, btnSort, btnFilter, filterViewController, filterParam;
@synthesize categoryName;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoadBefore
{
    [super viewDidLoadBefore];
    [self setToSimiView];
    paddingBottom = 40;
    paddingTop = 38;
    
    [[SimiGlobalVar sharedInstance].store setValue:@"NO" forKey:@"view_products_default"];
#pragma mark Init Product List View
    tableViewProductCollection = [[SimiTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
    [tableViewProductCollection setBackgroundColor:[UIColor clearColor]];
    tableViewProductCollection.dataSource = self;
    tableViewProductCollection.delegate = self;
    tableViewProductCollection.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin |UIViewAutoresizingFlexibleHeight;
    __weak SCProductListViewController *tempSelf = self;
    [tableViewProductCollection.infiniteScrollingView setBackgroundColor:THEME_COLOR];
    [tableViewProductCollection setSeparatorColor:THEME_LINE_COLOR];
    [tableViewProductCollection addInfiniteScrollingWithActionHandler:^{
        [tempSelf getProducts];
    }];
    [tableViewProductCollection setContentInset:UIEdgeInsetsMake([SimiGlobalVar scaleValue:paddingTop], 0, paddingBottom, 0)];
    [self.view addSubview:tableViewProductCollection];
    
#pragma mark Init Product Grid View
    UICollectionViewLayout* layOut = [[UICollectionViewLayout alloc] init];
    _productCollectionViewController = [[SCProductCollectionViewController alloc]initWithCollectionViewLayout:layOut];
    _productCollectionViewController.collectionGetProductType = self.productListGetProductType;
    _productCollectionViewController.isSearchOnAllProducts = self.isSearchOnAllProducts;
    if (self.productCollection == nil) {
        self.productCollection = [SimiProductModelCollection new];
    }
    self.productCollectionViewController.productCollection = self.productCollection;
    
    if(_spotModel){
        _productCollectionViewController.spotModel = _spotModel;
    }
    if (categoryID) {
        _productCollectionViewController.categoryID = categoryID;
    }
    if (_keySearchProduct) {
        _productCollectionViewController.keySearchProduct = _keySearchProduct;
    }
    [self.view addSubview:_productCollectionViewController.collectionView];
    self.productCollectionViewController.delegate = self;
    [_productCollectionViewController.collectionView setFrame:tableViewProductCollection.frame];
    
#pragma mark Init Search Products
    _searchProduct = [[UISearchBar alloc] initWithFrame:[SimiGlobalVar scaleFrame:CGRectMake(16, 5, 288, 28)]];
    _searchProduct.simiObjectName = @"SearchBarOnList";
    _searchProduct.delegate = self;
    if (!self.categoryName) {
        self.categoryName = SCLocalizedString(@"All products");
    }
    _searchProduct.placeholder = self.categoryName;
    _searchProduct.backgroundColor = [UIColor clearColor];
    _searchProduct.searchBarStyle = UISearchBarStyleMinimal;
    _searchProduct.layer.backgroundColor = [UIColor clearColor].CGColor;
    _searchProduct.layer.borderWidth = 1;
    _searchProduct.layer.borderColor=[UIColor clearColor].CGColor;
    _searchProduct.barTintColor = [UIColor clearColor];
    _searchProduct.translucent = YES;
    
    for ( UIView * subview in [[_searchProduct.subviews objectAtIndex:0] subviews] )
    {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarTextField") ] ) {
            [(UITextField *)subview setBorderStyle:UITextBorderStyleNone];
            if ([[SimiGlobalVar sharedInstance] isReverseLanguage]) {
                [(UITextField *)subview setTextAlignment:NSTextAlignmentRight];
            }
        }
    }
    
    searchBarBackground = [[UIView alloc]initWithFrame:_searchProduct.frame];
    [searchBarBackground setBackgroundColor:THEME_SEARCH_BOX_BACKGROUND_COLOR];
    [searchBarBackground setAlpha:0.9f];
    
    [self.view addSubview:searchBarBackground];
    [self.view addSubview:_searchProduct];
    if (self.productListGetProductType == ProductListGetProductTypeFromSearch) {
        _searchProduct.text = _keySearchProduct;
    }
    
#pragma Init View Tool Bar
    [self.view addSubview:[self viewToolBar]];
    self.lastContentOffset = 0;
    sortType = ProductCollectionSortNone;
    self.maxNumberProduct = 1000;
#pragma Set key cache Data
    switch (self.productListGetProductType) {
        case ProductListGetProductTypeFromCategory:
        {
            if (categoryID == nil || [categoryID isEqualToString:@""]) {
                self.keyCacheData = @"all";
            }else
            {
                self.keyCacheData = categoryID;
            }
        }
            break;
        case ProductListGetProductTypeFromSpot:
        {
            self.keyCacheData = [self.spotModel valueForKey:@"_id"];
            break;
        }
        default:
            break;
    }
    
#pragma mark Choose Products Show Type
    if ([[[SimiGlobalVar sharedInstance].store valueForKey:@"view_products_default"]boolValue]) {
        [tableViewProductCollection setHidden:YES];
        [tableViewProductCollection setAlpha:0];
    }else
    {
        [_productCollectionViewController.collectionView setAlpha:0];
        [_productCollectionViewController.collectionView setHidden:YES];
        if ([[SimiCacheData sharedInstance].dataListProducts valueForKey:self.keyCacheData]) {
            self.productCollection = [[SimiProductModelCollection alloc]initWithArray:[[SimiCacheData sharedInstance].dataListProducts valueForKey:self.keyCacheData]];
            if ([[[SimiCacheData sharedInstance].dataListProductIDs valueForKey:self.keyCacheData] isKindOfClass:[NSMutableArray class]]) {
                self.arrayProductsID = [[NSMutableArray alloc]initWithArray:[[SimiCacheData sharedInstance].dataListProductIDs valueForKey:self.keyCacheData]];
            }
            // End 150316
            self.productCollectionViewController.totalNumberProduct = self.maxNumberProduct;
            self.productCollectionViewController.productCollection = self.productCollection;
            [tableViewProductCollection reloadData];
        }
        if (self.productCollection == nil || self.productCollection.count == 0) {
            self.isFirstTimeGetData = YES;
            [self getProducts];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"didReceiveMemoryWarning");
    // Dispose of any resources that can be recreated.
}

- (void)refine{
    SCRefineViewController *nextController = [[SCRefineViewController alloc]init];
    [nextController setSortType:sortType];
    nextController.delegate = self;
    [UIView beginAnimations:@"View Flip" context:nil];
    [UIView setAnimationDuration: 0.5];
    [self.navigationController pushViewController:nextController animated:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
    [UIView commitAnimations];
}

- (void)getProducts{
    if (productCollection == nil) {
        productCollection = [[SimiProductModelCollection alloc] init];
    }
    self.productCollectionViewController.productCollection = self.productCollection;
    NSInteger offset = productCollection.count;
    if (offset >= self.maxNumberProduct) {
        [tableViewProductCollection.infiniteScrollingView stopAnimating];
        return;
    }
    if (filterParam == nil) {
        filterParam = @{};
    }
#pragma mark Category
    switch (self.productListGetProductType) {
        case ProductListGetProductTypeFromCategory:
        {
            if (![categoryID boolValue]) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProducts:) name:DidGetAllProducts object:productCollection];
                [productCollection getAllProductsWithOffset:offset limit:24 sortType:sortType otherParams:@{}];
            }else{
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProducts:) name:DidGetProductCollectionWithCategoryId object:productCollection];
                [productCollection getProductCollectionWithCategoryId:categoryID offset:offset limit:24 sortType:sortType otherParams:@{}];
            }
        }
            break;
#pragma mark Search
        case ProductListGetProductTypeFromSearch:
        {
            if (self.keySearchProduct && ![self.keySearchProduct isEqualToString:@""] ) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProducts:) name:DidSearchProducts object:self.productCollection];
                if ([self.categoryID isEqualToString:@""] || self.isSearchOnAllProducts || self.categoryID == nil) {
                    [self.productCollection searchOnAllProductsWithKey:self.keySearchProduct offset:offset limit:24 sortType:self.sortType otherParams:@{}];
                }else{
                    [self.productCollection searchProductsWithKey:self.keySearchProduct offset:offset limit:24 categoryId:categoryID sortType:self.sortType otherParams:@{}];
                }
            }
        }
            break;
#pragma mark Spot Product
        case ProductListGetProductTypeFromSpot:
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProducts:) name:DidGetAllProducts object:productCollection];
            switch ([[self.spotModel valueForKey:@"type"] integerValue]) {
#pragma mark  Best Seller
                case 1:
                {
                     [self.productCollection getAllProductsWithOffset:offset limit:20 sortType:ProductCollectionSortNone otherParams:@{@"group-type":@"best-sellers"}];
                }
                    break;
#pragma mark Newly Update
                case 2:
                {
                    [productCollection getAllProductsWithOffset:offset limit:20 sortType:ProductCollectionSortNone otherParams:@{@"order":@"updated_at",@"dir":@"desc"}];
                }
                    break;
#pragma mark Recently Added
                case 3:
                {
                    [productCollection getAllProductsWithOffset:offset limit:20 sortType:ProductCollectionSortNone otherParams:@{@"order":@"created_at",@"dir":@"desc"}];
                }
                    break;
#pragma mark Custom
                case 4:
                {
                    NSString *stringIds = @"";
                    if ([[self.spotModel valueForKey:@"products"] isKindOfClass:[NSMutableArray class]]) {
                        NSMutableArray *arrayIds = [[NSMutableArray alloc]initWithArray:[self.spotModel valueForKey:@"products"]];
                        for (int j =0; j < arrayIds.count; j++) {
                            if (j!= 0) {
                                stringIds = [NSString stringWithFormat:@"%@,%@",stringIds,[arrayIds objectAtIndex:j]];
                            }else
                                stringIds = [NSString stringWithFormat:@"%@",[arrayIds objectAtIndex:j]];
                        }
                    }
                                        
                    [productCollection getAllProductsWithOffset:offset limit:20 sortType:ProductCollectionSortNone otherParams:@{@"ids":stringIds}];
                }
                    break;
                default:
                    break;
            }
        }
            break;
            
        default:
        {
            if (![categoryID boolValue]) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProducts:) name:DidGetAllProducts object:productCollection];
                [productCollection getAllProductsWithOffset:offset limit:10 sortType:sortType otherParams:@{}];
            }else{
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProducts:) name:DidGetProductCollectionWithCategoryId object:productCollection];
                [productCollection getProductCollectionWithCategoryId:categoryID offset:offset limit:10 sortType:sortType otherParams:@{}];
            }
        }
            break;
    }
    
    [_btnChangeLayout setEnabled:NO];
    [tableViewProductCollection.infiniteScrollingView startAnimating];
}

- (void)didGetProducts:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        self.maxNumberProduct = (int)[productCollection.productIDs count];
        if (self.maxNumberProduct < 5) {
            [self setHideViewToolBar:NO];
        }
        self.productCollectionViewController.totalNumberProduct = self.maxNumberProduct;
        self.arrayProductsID = productCollection.productIDs;
        if (filterViewController == nil) {
            filterViewController = [SCFilterViewController new];
        }
        // End 150316
        [tableViewProductCollection reloadData];
        if (self.isFirstTimeGetData && self.productListGetProductType != ProductListGetProductTypeFromSearch) {
            self.isFirstTimeGetData = NO;
            [[SimiCacheData sharedInstance].dataListProducts setObject:[productCollection mutableCopy] forKey:self.keyCacheData];
            if (self.arrayProductsID) {
                [[SimiCacheData sharedInstance].dataListProductIDs setObject:[self.arrayProductsID mutableCopy] forKey:self.keyCacheData];
            }
        }
        // Show toat number products
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeText;
        hud.labelText = [NSString stringWithFormat:@"%d %@(s)",self.maxNumberProduct, SCLocalizedString(@"Product")];
        hud.margin = 10.f;
        hud.yOffset = -(CGRectGetHeight(self.view.bounds)/2 - 20 - [SimiGlobalVar scaleValue:100]);
        hud.removeFromSuperViewOnHide = YES;
        
        [hud hide:YES afterDelay:0.5];
    }
    [tableViewProductCollection.infiniteScrollingView stopAnimating];
    [_btnChangeLayout setEnabled:YES];
    [self stopLoadingData];
    if ([(NSMutableArray*)[filterViewController.filterContent valueForKey:@"layer_state"] count] > 0 || [(NSMutableArray*)[filterViewController.filterContent valueForKey:@"layer_filter"] count] > 0) {
        [btnFilter setHidden:NO];
    }
    [self removeObserverForNotification:noti];
}

#pragma mark Refine
- (void)didRefineWithSortType:(ProductCollectionSortType)type{
    if (type != sortType) {
        sortType = type;
        [productCollection removeAllObjects];
        [tableViewProductCollection reloadData];
        [self.productCollectionViewController.collectionView reloadData];
        [self.productCollectionViewController setSortType:sortType];
        if (_isProductShowGrid) {
            [self.productCollectionViewController getProducts];
        }else
            [self getProducts];
    }
}

#pragma mark Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([tableView isEqual:tableViewProductCollection]) {
        return productCollection.count;
    }else
        return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:tableViewProductCollection]) {
        if (SIMI_SYSTEM_IOS >=8) {
            return [SimiGlobalVar scaleValue:105];
        }else{
            // May start edited 20151022
            return [SimiGlobalVar scaleValue:119];
             //May end 20151022
        }
       
    }else
        return [SimiGlobalVar scaleValue:45];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:tableViewProductCollection]) {
        //Init cell
        NSInteger row = indexPath.row;
        SimiProductModel *product = [productCollection objectAtIndex:row];
        [product setValue:[NSString stringWithFormat:@"%ld. %@", (long)row+1, [product valueForKey:@"name"]] forKey:@"cell_product_name"];
        NSString *productListIdentifier = [NSString stringWithFormat:@"ProductListIdentifier_%@",[product valueForKey:@"_id"]];
        SCProductListCell *cell = [tableView dequeueReusableCellWithIdentifier:productListIdentifier];
        if (cell == nil) {
            cell = [[SCProductListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:productListIdentifier product:product];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedProductListCell-After" object:cell userInfo:@{@"indexPath": indexPath}];
        [cell setBackgroundColor:[UIColor clearColor]];
        return cell;
    }else
    {
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [cell.textLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:14]];
        if (indexPath.row == 0) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", SCLocalizedString(@"Search on"),self.categoryName];
            if (!_isSearchOnAllProducts) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }else
                cell.accessoryType = UITableViewCellAccessoryNone;
        }else
        {
            cell.textLabel.text = SCLocalizedString(@"Search on All Products");
            if (_isSearchOnAllProducts) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }else
                cell.accessoryType = UITableViewCellAccessoryNone;
        }
        [cell setTintColor:[UIColor orangeColor]];
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:tableViewProductCollection]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectProductListCellAtIndexPath" object:tableView userInfo:@{@"indexPath": indexPath}];
        if (self.isDiscontinue) {
            self.isDiscontinue = NO;
            return;
        }
        SimiProductModel *product = [productCollection objectAtIndex:indexPath.row];
        SCProductViewController *productViewController = [SCProductViewController new];
        productViewController.arrayProductsID = self.arrayProductsID;
        productViewController.firstProductID = [product valueForKey:@"_id"];
        [self.navigationController pushViewController:productViewController animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }else
    {
        if (indexPath.row == 0) {
            self.isSearchOnAllProducts = NO;
        }else
            self.isSearchOnAllProducts = YES;
        self.keySearchProduct = self.searchProduct.text;
        if (![self.keySearchProduct isEqualToString:@""] && self.keySearchProduct) {
            [self searchBarSearchButtonClicked:self.searchProduct];
        }
        [_tableViewSearchOption deselectRowAtIndexPath:indexPath animated:YES];
        [_tableViewSearchOption reloadData];
    }
}

#pragma  mark Filter
// Liam ADD 20150313
- (UIView *)viewToolBar
{
    if (viewToolBar == nil) {
        CGRect frame = CGRectZero;
        frame.size.width = SCREEN_WIDTH;
        frame.size.height = 40;
        frame.origin.y = SCREEN_HEIGHT - frame.size.height - 24;
        float buttonWidth = 65;
        float buttonHeight = frame.size.height;
        float iconSize = 25;
        viewToolBar = [[UIView alloc]initWithFrame:frame];
        [viewToolBar setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.8]];
        
        _btnChangeLayout = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
        [_btnChangeLayout setImageEdgeInsets:UIEdgeInsetsMake((buttonHeight - iconSize)/2, (buttonWidth - iconSize)/2, (buttonHeight - iconSize)/2, (buttonWidth - iconSize)/2)];
        if ([[[SimiGlobalVar sharedInstance].store valueForKey:@"view_products_default"] boolValue]) {
            [_btnChangeLayout setImage:[UIImage imageNamed:@"ic_list"] forState:UIControlStateNormal];
            _isProductShowGrid = YES;
        }else
            [_btnChangeLayout setImage:[UIImage imageNamed:@"ic_grib"] forState:UIControlStateNormal];
        [_btnChangeLayout addTarget:self action:@selector(changeLayoutListView) forControlEvents:UIControlEventTouchUpInside];
        if(SIMI_SYSTEM_IOS >= 8)
            [viewToolBar addSubview:_btnChangeLayout];
        
        btnSort = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - buttonWidth, 0, buttonWidth, buttonHeight)];
        [btnSort setImageEdgeInsets:UIEdgeInsetsMake((buttonHeight - iconSize)/2, (buttonWidth - iconSize)/2, (buttonHeight - iconSize)/2, (buttonWidth - iconSize)/2)];
        [btnSort setImage:[UIImage imageNamed:@"ic_sort"] forState:UIControlStateNormal];
        [btnSort addTarget:self action:@selector(refine)forControlEvents:UIControlEventTouchUpInside];
        [viewToolBar addSubview:btnSort];
        
        btnFilter = [[UIButton alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - buttonWidth)/2, 0, buttonWidth, buttonHeight)];
        [btnFilter setImageEdgeInsets:UIEdgeInsetsMake((buttonHeight - iconSize)/2, (buttonWidth - iconSize)/2, (buttonHeight - iconSize)/2, (buttonWidth - iconSize)/2)];
        [btnFilter setImage:[UIImage imageNamed:@"ic_filter"] forState:UIControlStateNormal];
        [btnFilter addTarget:self action:@selector(filter)forControlEvents:UIControlEventTouchUpInside];
        [btnFilter setHidden:YES];
        [viewToolBar addSubview:btnFilter];
    }
    return viewToolBar;
}

- (void)filter
{
    if (filterViewController == nil) {
        filterViewController = [SCFilterViewController new];
    }
    filterViewController.delegate = self;
    [UIView beginAnimations:@"View Flip" context:nil];
    [UIView setAnimationDuration: 0.5];
    [self.navigationController pushViewController:filterViewController animated:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
    [UIView commitAnimations];
}

#pragma mark ProductCollection View Delegate
- (void)startGetProductModelCollection
{
    [_btnChangeLayout setEnabled:NO];
}
- (void)didGetProductModelCollection:(NSDictionary*)layerNavigation
{
    [_btnChangeLayout setEnabled:YES];
}

- (void)selectedProduct:(NSString*)productID_
{
    SCProductViewController *productViewController = [SCProductViewController new];
    if (self.arrayProductsID == nil) {
        self.arrayProductsID = self.productCollectionViewController.arrayProductID;
    }
    productViewController.arrayProductsID = self.arrayProductsID;
    productViewController.firstProductID = productID_;
    [self.navigationController pushViewController:productViewController animated:YES];
}
- (void)numberProductChange:(int)numberProduct
{
    // Show toat number products
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = [NSString stringWithFormat:@"%d %@(s)",numberProduct, SCLocalizedString(@"Product")];
    hud.margin = 10.f;
    hud.yOffset = -(CGRectGetHeight(self.view.bounds)/2 - 20 - [SimiGlobalVar scaleValue:100]);
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:0.5];
}

- (void)setHideViewToolBar:(BOOL)isHide
{
    if (isHide) {
        CGRect frame = viewToolBar.frame;
        frame.origin.y = SCREEN_HEIGHT - CGRectGetHeight(frame) - 24;
        [UIView animateWithDuration:0.3 animations:^{
            [viewToolBar setFrame:frame];
        } completion:^(BOOL finished) {
        }];
    }else
    {
        CGRect frame = viewToolBar.frame;
        frame.origin.y = SCREEN_HEIGHT - CGRectGetHeight(frame) - 64;
        [UIView animateWithDuration:0.3 animations:^{
            [viewToolBar setFrame:frame];
        } completion:^(BOOL finished) {
        }];
    }
}

#pragma mark SCFilter Delegate
- (void)filterWithParam:(NSMutableDictionary *)param
{
    [productCollection removeAllObjects];
    filterParam = param;
    _productCollectionViewController.filterParam = param;
    [tableViewProductCollection reloadData];
    [_productCollectionViewController.collectionView reloadData];
    self.maxNumberProduct = 1000;
    if (_isProductShowGrid) {
        [_productCollectionViewController getProducts];
    }else
        [self getProducts];
}
// End 20150317

#pragma mark Change Layout
- (void)changeLayoutListView
{
    [_btnChangeLayout setEnabled:NO];
    if (!_isProductShowGrid) {
        [_productCollectionViewController.collectionView reloadData];
        [UIView animateWithDuration:0.5 animations:^{
            [tableViewProductCollection setAlpha:0];
        } completion:^(BOOL finished) {
            [tableViewProductCollection setHidden:YES];
            [_productCollectionViewController.collectionView setHidden:NO];
            [UIView animateWithDuration:0.5 animations:^{
                [_productCollectionViewController.collectionView setAlpha:1];
            } completion:^(BOOL finished) {
                [_btnChangeLayout setEnabled:YES];
            }];
        }];
        [_btnChangeLayout setImage:[UIImage imageNamed:@"ic_list"] forState:UIControlStateNormal];
    }else
    {
        [tableViewProductCollection reloadData];
        [UIView animateWithDuration:0.5 animations:^{
            [_productCollectionViewController.collectionView setAlpha:0];
        } completion:^(BOOL finished) {
             [_productCollectionViewController.collectionView setHidden:YES];
            [tableViewProductCollection setHidden:NO];
            [UIView animateWithDuration:0.5 animations:^{
                [tableViewProductCollection setAlpha:1];
            } completion:^(BOOL finished) {
                [_btnChangeLayout setEnabled:YES];
            }];
        }];
        [_btnChangeLayout setImage:[UIImage imageNamed:@"ic_grib"] forState:UIControlStateNormal];
    }
    _isProductShowGrid = !_isProductShowGrid;
}

#pragma mark Scroll Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float maxScroll = productCollection.count * [SimiGlobalVar scaleValue:105] - (SCREEN_HEIGHT - 64);
    if (scrollView.contentOffset.y > -[SimiGlobalVar scaleValue:38] && scrollView.contentOffset.y < maxScroll) {
        if (self.lastContentOffset > scrollView.contentOffset.y)
        {
            CGRect frame = viewToolBar.frame;
            frame.origin.y = SCREEN_HEIGHT - CGRectGetHeight(frame) - 24;
            [UIView animateWithDuration:0.3 animations:^{
                [viewToolBar setFrame:frame];
            } completion:^(BOOL finished) {
            }];
        }
        else if (self.lastContentOffset < scrollView.contentOffset.y)
        {
            CGRect frame = viewToolBar.frame;
            frame.origin.y = SCREEN_HEIGHT - CGRectGetHeight(frame) - 64;
            [UIView animateWithDuration:0.3 animations:^{
                [viewToolBar setFrame:frame];
            } completion:^(BOOL finished) {
            }];
        }
    }
    
    self.lastContentOffset = scrollView.contentOffset.y;
}

#pragma mark Search Bar Delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    _keySearchProduct = searchBar.text;
    [_searchView removeFromSuperview];
    if (self.productListGetProductType == ProductListGetProductTypeFromSearch) {
        [self.productCollection removeAllObjects];
        self.productCollectionViewController.isSearchOnAllProducts = self.isSearchOnAllProducts;
        self.productCollectionViewController.keySearchProduct = _keySearchProduct;
        self.maxNumberProduct = 1000;
        if (_isProductShowGrid) {
            [self.productCollectionViewController.collectionView reloadData];
            [self.productCollectionViewController getProducts];
        }else
        {
            [tableViewProductCollection reloadData];
            [self getProducts];
        }
    }else
    {
        searchBar.text = @"";
        SCProductListViewController *searchViewController = [SCProductListViewController new];
        searchViewController.productListGetProductType = ProductListGetProductTypeFromSearch;
        searchViewController.categoryID = self.categoryID;
        searchViewController.spotModel = self.spotModel;
        searchViewController.keySearchProduct = _keySearchProduct;
        searchViewController.categoryName = self.categoryName;
        searchViewController.isSearchOnAllProducts = self.isSearchOnAllProducts;
        [self.navigationController pushViewController:searchViewController animated:YES];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if (_searchView == nil) {
        _searchView = [[UIView alloc]initWithFrame:self.view.bounds];
        [_searchView setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.95]];
        
        CGRect imageFogFrame = _searchView.bounds;
        imageFogFrame.origin.y += [SimiGlobalVar scaleValue:35] + [SimiGlobalVar scaleValue:45] * 2;
        imageFogFrame.size.height -= imageFogFrame.origin.y;
        _imageFogWhenSearch = [[UIImageView alloc]initWithFrame:imageFogFrame];
        [_imageFogWhenSearch setBackgroundColor:[UIColor clearColor]];
        [_imageFogWhenSearch setUserInteractionEnabled:YES];
        [_searchView addSubview:_imageFogWhenSearch];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapImageFog)];
        [_imageFogWhenSearch addGestureRecognizer:tapGestureRecognizer];
        if (![self.categoryID isEqualToString:@""] && self.categoryID) {
            if (_tableViewSearchOption == nil) {
                CGRect frame = _imageFogWhenSearch.bounds;
                frame.origin.y += [SimiGlobalVar scaleValue:35];
                frame.size.height = [SimiGlobalVar scaleValue:45] * 2;
                _tableViewSearchOption = [[UITableView alloc]initWithFrame:frame style:UITableViewStylePlain];
                _tableViewSearchOption.delegate = self;
                _tableViewSearchOption.dataSource = self;
                _tableViewSearchOption.scrollEnabled = NO;
                [_tableViewSearchOption setUserInteractionEnabled:YES];
                [_searchView addSubview:_tableViewSearchOption];
            }
        }
    }
    [self.view addSubview:_searchView];
    [self.view bringSubviewToFront:searchBarBackground];
    [self.view bringSubviewToFront:_searchProduct];
    if (self.productListGetProductType == ProductListGetProductTypeFromSearch) {
        _searchProduct.text = _keySearchProduct;
    }
    return YES;
}

- (void)didTapImageFog
{
    [_searchProduct resignFirstResponder];
    [_searchView removeFromSuperview];
    _searchProduct.text = @"";
}

- (void)didTouchSearchAllButton:(id)sender
{
    [_searchProduct resignFirstResponder];
    _keySearchProduct = _searchProduct.text;
    [_imageFogWhenSearch removeFromSuperview];
    if ([_keySearchProduct isEqualToString:@""]) {
        return;
    }
    if (self.productListGetProductType != ProductListGetProductTypeFromSearch) {
        _searchProduct.text = @"";
        SCProductListViewController *searchViewController = [SCProductListViewController new];
        searchViewController.productListGetProductType = ProductListGetProductTypeFromSearch;
        searchViewController.categoryID = self.categoryID;
        searchViewController.spotModel = self.spotModel;
        searchViewController.keySearchProduct = _keySearchProduct;
        searchViewController.isSearchOnAllProducts = YES;
        searchViewController.categoryName = self.categoryName;
        [self.navigationController pushViewController:searchViewController animated:YES];
    }else
    {
        [self.productCollection removeAllObjects];
        self.isSearchOnAllProducts = YES;
        self.productCollectionViewController.isSearchOnAllProducts = self.isSearchOnAllProducts;
        if (_isProductShowGrid) {
            [self.productCollectionViewController.collectionView reloadData];
            [self.productCollectionViewController getProducts];
        }else
        {
            [tableViewProductCollection reloadData];
            [self getProducts];
        }
    }
        
}

#pragma mark Get Spot Product
//Axe copy from home default
- (void)getBestSellerProducts
{
   
}
- (void)getMostViewProducts
{
//    SimiProductModelCollection *newlyUpdatedProductModelCollection = [SimiProductModelCollection new];
//    newlyUpdatedProductModelCollection.simiObjectIdentifier = [spotModel valueForKey:@"_id"];
//    newlyUpdatedProductModelCollection.simiObjectName = [spotModel valueForKey:@"name"];
    //    [spotArray addObject:newlyUpdatedProductModelCollection];
    
}
- (void)getRecentAddedProducts
{
//    SimiProductModelCollection *recentAddedProductModelCollection = [SimiProductModelCollection new];
//    recentAddedProductModelCollection.simiObjectIdentifier = [spotModel valueForKey:@"_id"];
//    recentAddedProductModelCollection.simiObjectName = [spotModel valueForKey:@"name"];
    //    [spotArray addObject:recentAddedProductModelCollection];
    [productCollection getAllProductsWithOffset:0 limit:20 sortType:ProductCollectionSortNone otherParams:@{@"order":@"created_at",@"dir":@"desc",@"filter[status]":@"1"}];
}
- (void)getFeatureProducts
{
    
    NSString *stringIds = @"";
//    for (int i = 0;i < self.spotProductsCollection.count; i++) {
//        SimiModel *model = [self.spotProductsCollection objectAtIndex:i];
        if ([[self.spotModel valueForKey:@"type"]intValue] == 4) {
            if ([[self.spotModel valueForKey:@"products"] isKindOfClass:[NSMutableArray class]]) {
                NSMutableArray *arrayIds = [[NSMutableArray alloc]initWithArray:[self.spotModel valueForKey:@"products"]];
                for (int j =0; j < arrayIds.count; j++) {
                    if (j!= 0) {
                        stringIds = [NSString stringWithFormat:@"%@,%@",stringIds,[arrayIds objectAtIndex:j]];
                    }else
                        stringIds = [NSString stringWithFormat:@"%@",[arrayIds objectAtIndex:j]];
                }
            }
        }
//    }
    [productCollection getAllProductsWithOffset:0 limit:20 sortType:ProductCollectionSortNone otherParams:@{@"ids":stringIds,@"filter[status]":@"1"}];
}


@end