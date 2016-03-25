//
//  SCHomeViewController_ThemeOne.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/8/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiGlobalVar.h"
#import "UIImage+SimiCustom.h"
#import "MatrixHomeViewController.h"
#import "SCProductListViewController.h"
#import "SCCategoryViewController.h"
#import "SCThemeWorker.h"
#import "AFViewShaker.h"
@interface MatrixHomeViewController ()

@end

@implementation MatrixHomeViewController
@synthesize tableViewHome, bannerCollection, themeBannerSlider,spotCollection, cells = _cells, categoryModel, searchBarHome, searchBarBackground;
@synthesize isDidGetBanner, isDidGetCategory, isDidGetSpotProduct;


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
    
    tableViewHome = [[SimiTableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    tableViewHome.dataSource = self;
    tableViewHome.delegate = self;
    tableViewHome.bounces = YES;
    
    if (SCREEN_HEIGHT >= 568) {
        tableViewHome.scrollEnabled = NO;
    }
    
    if (SCREEN_HEIGHT > 568)
        [tableViewHome setContentInset:UIEdgeInsetsMake([SimiGlobalVar scaleValue:5], 0, [SimiGlobalVar scaleValue:5], 0)];
    else
        [tableViewHome setContentInset:UIEdgeInsetsMake(0, 0, [SimiGlobalVar scaleValue:5], 0)];
    
    tableViewHome.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tableViewHome.showsVerticalScrollIndicator = NO;
    tableViewHome.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableViewHome setContentSize:[SimiGlobalVar scaleSize:CGSizeMake(320, 495)]];
    [self.view addSubview:tableViewHome];
    //AXe added
    searchBarHome = [[UISearchBar alloc] initWithFrame:[SimiGlobalVar scaleFrame:CGRectMake(5, -33, 310, 28)]];
    searchBarHome.tintColor = THEME_SEARCH_TEXT_COLOR;
    searchBarHome.searchBarStyle = UIBarStyleBlackTranslucent;
    searchBarHome.placeholder = SCLocalizedString(@"Search");
    searchBarHome.layer.backgroundColor = [UIColor clearColor].CGColor;
    searchBarHome.layer.borderColor = [UIColor clearColor].CGColor;
    searchBarHome.layer.borderWidth=1;
    [[NSClassFromString(@"UISearchBarTextField") appearanceWhenContainedIn:[UISearchBar class], nil] setBorderStyle:UITextBorderStyleNone];
    searchBarHome.layer.borderColor=[UIColor clearColor].CGColor;
    //Gin edit
    for ( UIView * subview in [[searchBarHome.subviews objectAtIndex:0] subviews] )
    {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarTextField") ] ) {
            UITextField *searchView = (UITextField *)subview ;
            if ([[SimiGlobalVar sharedInstance] isReverseLanguage]) {
                [searchView setBorderStyle:UITextBorderStyleNone];
                [searchView.rightView setBackgroundColor:THEME_SEARCH_ICON_COLOR];
                searchView.textColor = THEME_SEARCH_TEXT_COLOR;
                [searchView.rightView setBackgroundColor:[UIColor blackColor]];
                [searchView setTextAlignment:NSTextAlignmentRight];
            }
        }
    }
    //end
    searchBarHome.delegate = self;
    searchBarHome.userInteractionEnabled = YES;
    [searchBarHome setBackgroundColor:[UIColor clearColor]];
    
    searchBarBackground = [[UIView alloc]initWithFrame:searchBarHome.frame];
    [searchBarBackground setBackgroundColor:THEME_SEARCH_BOX_BACKGROUND_COLOR];
    [self.view addSubview:searchBarBackground];
    [self.view addSubview:searchBarHome];
    [searchBarBackground setAlpha:0.9f];
    //    [searchBarHome setAlpha:0.0f];
    UISwipeGestureRecognizer* swipeDownTheView = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeTableView:)];
    [swipeDownTheView setDirection:(UISwipeGestureRecognizerDirectionDown)];
    UISwipeGestureRecognizer* swipeUpTheView = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeTableView:)];
    [swipeUpTheView setDirection:(UISwipeGestureRecognizerDirectionUp)];
    
    [tableViewHome addGestureRecognizer:swipeDownTheView];
    [tableViewHome addGestureRecognizer:swipeUpTheView];
    //End
    
    [self setCells:nil];
    [self getBanners];
    [self getHomeCategories];
    [self getSpotCollection];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self.navigationController.view addSubview:[[[SCThemeWorker sharedInstance] navigationBarPhone]leftMenuPhone].view];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCells:(NSMutableArray *)cells
{
    if (cells) {
        _cells = cells;
    }else{
        _cells = [[NSMutableArray alloc] init];
        SimiSection *section = [[SimiSection alloc] init];
        
        if (bannerCollection.count > 0) {
            SimiRow *row01 = [[SimiRow alloc]initWithIdentifier:HOME_BANNER_CELL height:[SimiGlobalVar scaleValue: 170]];
            [section addObject:row01];
        }
        
        if (_homeCategoryModelCollection.count > 0) {
            SimiRow *row02 = [[SimiRow alloc]initWithIdentifier:HOME_CATEGORY_CELL height:[SimiGlobalVar scaleValue: 220]];
            [section addObject:row02];
        }
        
        if (spotCollection.count > 0) {
            SimiRow *row03  = [[SimiRow alloc]initWithIdentifier:HOME_SPOT_CELL height:[SimiGlobalVar scaleValue:105]];
            [section addObject:row03];
        }
        
        if (!(isDidGetBanner && isDidGetCategory && isDidGetSpotProduct)) {
            SimiRow *row04 = [[SimiRow alloc]initWithIdentifier:HOME_LOADING_CELL height:[SimiGlobalVar scaleValue:100]];
            [section addObject:row04];
        }
        [_cells addObject:section];
        [tableViewHome reloadData];
    }
}

#pragma mark getData
- (void)getBanners
{
    if (self.bannerCollection == nil) {
        self.bannerCollection = [[SimiBannerModelCollection alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetBanner:) name:DidGetBanner object:self.bannerCollection];
        [self.bannerCollection getBannerCollection];
    }
}

- (void)getSpotCollection{
    if (spotCollection == nil) {
        spotCollection = [[SimiSpotModelCollection alloc] init];
    }
    [spotCollection removeAllObjects];
    [spotCollection getSpotCollection];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetSpotCollection:) name:DidGetSpotCollection object:spotCollection];
    self.isDidGetSpotProduct = NO;
}

- (void)getHomeCategories{
    if (_homeCategoryModelCollection ==nil) {
        _homeCategoryModelCollection = [[SimiCategoryModelCollection alloc]init];
    }
    [_homeCategoryModelCollection removeAllObjects];
    [_homeCategoryModelCollection getHomeDefaultCategories];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetHomeCategories:) name:DidGetHomeCategories object:_homeCategoryModelCollection];
    self.isDidGetCategory = NO;
}

#pragma mark Set Interface
- (void)setViewCategory
{
    if (_homeCategoryModelCollection.count > 0) {
        
        _viewCate01 = [[MatrixCategoryProductCell alloc]initWithFrame:[SimiGlobalVar scaleFrame:CGRectMake(0, 5, 105, 105)] isAllCate:NO];
        [_viewCate01 cusSetCateModel:[_homeCategoryModelCollection objectAtIndex:0]];
        _viewCate01.delegate =self;
        
        if (_homeCategoryModelCollection.count >1) {
        _viewCate02 = [[MatrixCategoryProductCell alloc]initWithFrame:[SimiGlobalVar scaleFrame:CGRectMake(110, 5, 210, 105)]  isAllCate:NO];
            [_viewCate02 cusSetCateModel:[_homeCategoryModelCollection objectAtIndex:1]];
        }
        _viewCate02.delegate =self;
        
        if (_homeCategoryModelCollection.count > 2) {
        _viewCate03 = [[MatrixCategoryProductCell alloc]initWithFrame:[SimiGlobalVar scaleFrame:CGRectMake(0, 115, 210, 105)] isAllCate:NO];
            [_viewCate03 cusSetCateModel:[_homeCategoryModelCollection objectAtIndex:2]];
        }
        _viewCate03.delegate =self;
        
        if (_homeCategoryModelCollection.count > 3) {
        _viewAllCate = [[MatrixCategoryProductCell alloc]initWithFrame:[SimiGlobalVar scaleFrame:CGRectMake(215, 115, 105, 105)] isAllCate:NO];
            [_viewAllCate cusSetCateModel:[_homeCategoryModelCollection objectAtIndex:3]];
        }
        _viewAllCate.delegate =self;
    }
}

#pragma mark Recieve Data
- (void)didGetBanner:(NSNotification*)noti
{
    if ([noti.name isEqualToString:DidGetBanner]) {
        isDidGetBanner = YES;
        [self removeObserverForNotification:noti];
        SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
        if ([responder.status isEqualToString:@"SUCCESS"]) {
            if (self.bannerCollection.count == 0 && [DEMO_MODE boolValue]) {
                SimiModel *model =[SimiModel new];
                [model setValue:@"YES" forKey:isFake];
                [self.bannerCollection addObject:model];
            }
            [self setCells:nil];
        }
    }
}

- (void)didGetHomeCategories:(NSNotification*)noti
{
        isDidGetCategory = YES;
        [self removeObserverForNotification:noti];
        SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
        if ([responder.status isEqualToString:@"SUCCESS"]) {
            if (self.homeCategoryModelCollection.count < 5 && [DEMO_MODE boolValue]) {
                for (int i = (int)self.homeCategoryModelCollection.count - 1; i < 4; i++) {
                    SimiModel *cateModel = [SimiModel new];
                    [cateModel setValue:@"YES" forKey:isFake];
                    [cateModel setValue:[NSString stringWithFormat:@"Category %d",i] forKey:@"category_name"];
                    if (i == 0 || i == 3) {
                        [cateModel setValue:@"matrix_category_one" forKey:@"image"];
                    }else
                        [cateModel setValue:@"matrix_category_two" forKey:@"image"];
                    [self.homeCategoryModelCollection addObject:cateModel];
                }
            }
            [self setCells:nil];
        }
}

- (void)didGetSpotCollection:(NSNotification*)noti
{
        isDidGetSpotProduct = YES;
        [self removeObserverForNotification:noti];
        SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
        if ([responder.status isEqualToString:@"SUCCESS"]) {
            if (self.spotCollection.count == 0 && [DEMO_MODE boolValue]) {
                for (int i = 0; i < 4; i++) {
                    SimiModel *spotModel = [SimiModel new];
                    [spotModel setValue:@"YES" forKey:isFake];
                    [spotModel setValue:[NSString stringWithFormat:@"Spot %d",i] forKey:@"spot_name"];
                    [spotModel setValue:@"matrix_spot" forKey:@"image"];
                    [self.spotCollection addObject:spotModel];
                }
            }
            [self setCells:nil];
        }
}

#pragma mark Banner Slider
- (void)tapInBanner:(UITapGestureRecognizer *)recognizer{
    if (bannerCollection.count > 0) {
        NSInteger offset = themeBannerSlider.currentIndex % bannerCollection.count;
        id banner = [bannerCollection objectAtIndex:offset];
        //king 150419
        if ([[NSString stringWithFormat:@"%@",[banner valueForKey:@"type"]] isEqualToString:@"2"]) {
            if(categoryModel == nil) categoryModel = [SimiCategoryModel new];
            [categoryModel getCategoryWithId:[banner valueForKey:@"category_id"]];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:DidGetCategory object:categoryModel];
            [self startLoadingData];
            
            
        }else if([[NSString stringWithFormat:@"%@",[banner valueForKey:@"type"]]isEqualToString:@"1"]){
            SCProductViewController *nextController = [SCProductViewController new];
            [nextController setProductId:[banner valueForKey:@"product_id"]];
            [self.navigationController pushViewController:nextController animated:YES];
        }else{
            if (![[banner valueForKey:@"url"] isKindOfClass:[NSNull class]] && [banner valueForKey:@"url"] != nil){
                if ([[[banner valueForKey:@"url"] lowercaseString] rangeOfString:@"http"].location != NSNotFound) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[banner valueForKey:@"url"]]];
                }
            }
        }
    }
}

#pragma mark TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _cells.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    SimiSection *simiSection = [_cells objectAtIndex:section];
    return simiSection.rows.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    return simiRow.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    cell = [tableView dequeueReusableCellWithIdentifier:simiRow.identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([simiRow.identifier isEqualToString:HOME_BANNER_CELL]) {
            if (bannerCollection.count > 0) {
                if (themeBannerSlider == nil) {
                    themeBannerSlider = [[MatrixSlideShow alloc] initWithFrame:CGRectMake(0, cell.frame.origin.y, SCREEN_WIDTH, [SimiGlobalVar scaleValue:169])];
                    UITapGestureRecognizer *tapGestureRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapInBanner:)];
                    [themeBannerSlider addGestureRecognizer:tapGestureRecog];
                    [themeBannerSlider setImagesContentMode:UIViewContentModeScaleAspectFill];
                    [themeBannerSlider setDelay:3];
                    [themeBannerSlider setTransitionDuration:0.5];
                    [themeBannerSlider setTransitionType:SCTheme01SlideShowTransitionSlide];
                    themeBannerSlider.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    [cell addSubview:themeBannerSlider];
                    
                    if (bannerCollection.count > 1) {
                        [themeBannerSlider addGesture:SCTheme01SlideShowGestureSwipe];
                    }
                    for (SimiModel *model in bannerCollection) {
                        [themeBannerSlider addImagePath:[[model valueForKey:@"image"] valueForKey:@"url" ]];
                    }
                    if (bannerCollection.count > 1) {
                        [themeBannerSlider start];
                    }
                }
            }
        } else if ([simiRow.identifier isEqualToString:HOME_CATEGORY_CELL])
        {
            [self setViewCategory];
            if(_viewCate01){
                [cell addSubview:_viewCate01];
                [_viewCate01.slideShow start];
            }
            if(_viewCate02){
                [cell addSubview:_viewCate02];
                [_viewCate02.slideShow start];
            }
            if(_viewCate03){
                [cell addSubview:_viewCate03];
                [_viewCate03.slideShow start];
            }
            if(_viewAllCate){
                [cell addSubview:_viewAllCate];
                [_viewAllCate.slideShow start];
            }
            
        } else if ([simiRow.identifier isEqualToString:HOME_SPOT_CELL])
        {
            UIScrollView *scrViewSpot = [[UIScrollView alloc]initWithFrame:CGRectMake(0, [SimiGlobalVar scaleValue:5], SCREEN_WIDTH, [SimiGlobalVar scaleValue:104])];
            scrViewSpot.showsHorizontalScrollIndicator = NO;
            int widthDistanceTwoCell = [SimiGlobalVar scaleValue:4];
            int sizeCell = [SimiGlobalVar scaleValue:104];
            int widthScrollViewContent = 0;
            for (int i = 0; i < spotCollection.count; i++) {
                MatrixSpotProductCell *spotCell = [[MatrixSpotProductCell alloc]initWithFrame:CGRectMake(i*(sizeCell + widthDistanceTwoCell), 0, sizeCell, sizeCell)];
                spotCell.delegate = self;
                [spotCell cusSetSpotModel:[spotCollection objectAtIndex:i]];
                widthScrollViewContent += (sizeCell + widthDistanceTwoCell);
                [spotCell.slideShow start];
                [scrViewSpot addSubview:spotCell];
            }
            [scrViewSpot setContentSize:CGSizeMake(widthScrollViewContent, sizeCell)];
            [scrViewSpot setBackgroundColor:[UIColor clearColor]];
            [cell addSubview:scrViewSpot];
            // Gin edit Shaker  rung image
            if( spotCollection.count > 0){
                AFViewShaker * viewShaker = [[AFViewShaker alloc] initWithView:scrViewSpot];
                [viewShaker shakeWithDuration:1 completion:^{
                }];
            }
            //end
        }else if ([simiRow.identifier isEqualToString:HOME_LOADING_CELL]){
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, [SimiGlobalVar scaleValue:100])];
            imageView.image = [UIImage imageNamed:@"logo.png"];
            [imageView setContentMode:UIViewContentModeScaleAspectFit];
            CGRect frame = imageView.frame;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.origin.y + frame.size.height - [SimiGlobalVar scaleValue:30], frame.size.width, [SimiGlobalVar scaleValue:30])];
            label.text = [NSString stringWithFormat:@"%@...", SCLocalizedString(@"Loading")];
            label.textColor = THEME_COLOR;
            label.textAlignment = NSTextAlignmentCenter;
            [cell addSubview:imageView];
            [cell addSubview:label];
        }
        // End 150319
    }
    return cell;
}

#pragma mark SpotProduct Delegate
- (void)didSelectedSpotProductWithSpotProductModel:(SimiModel *)spotModel
{
    SCProductListViewController *productListViewController = [[SCProductListViewController alloc]init];
    productListViewController.productListGetProductType = ProductListGetProductTypeFromSpot;
    productListViewController.spotModel = spotModel;
    [self.navigationController pushViewController:productListViewController animated:YES];
}

#pragma mark Category Delegate
- (void)didSelectCateGoryWithCateModel:(SimiCategoryModel *)cateModel
{
    if(cateModel != nil)
    {
        if([[cateModel valueForKey:@"has_children"]boolValue])
        {
            SCCategoryViewController *categoryController = [[SCCategoryViewController alloc]init];
            categoryController.categoryId = [cateModel valueForKey:@"category_id"];
            categoryController.categoryRealName = [cateModel valueForKey:@"name"];
            [self.navigationController pushViewController:categoryController animated:YES];
        }else
        {
            SCProductListViewController *productListViewController = [[SCProductListViewController alloc]init];
            productListViewController.productListGetProductType = ProductListGetProductTypeFromCategory;
            productListViewController.categoryID = [cateModel valueForKey:@"category_id"];
            productListViewController.categoryName = [cateModel valueForKey:@"name"];
            [self.navigationController pushViewController:productListViewController animated:YES];
        }
    }
}

-(void) didReceiveNotification:(NSNotification *)noti{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:noti.name object:nil];
    [self stopLoadingData];
    SimiResponder* responder = [noti.userInfo valueForKey:@"responder"];
    if([responder.status isEqualToString:@"SUCCESS"]){
        if([noti.name isEqualToString:DidGetCategory]){
            if ([[categoryModel valueForKey:@"has_children"]boolValue]) {
                SCCategoryViewController* nextController = [SCCategoryViewController new];
                nextController.categoryId = [categoryModel valueForKey:@"_id"];
                nextController.navigationItem.title = [[categoryModel valueForKey:@"name"] uppercaseString];
                [self.navigationController pushViewController:nextController animated:YES];
            }else{
                SCProductListViewController *nextController = [[SCProductListViewController alloc]init];;
                nextController.categoryID = [categoryModel valueForKey:@"_id"];
                nextController.categoryName = [categoryModel valueForKey:@"name"];
                nextController.navigationItem.title = [[categoryModel valueForKey:@"name"] uppercaseString];
                [self.navigationController pushViewController:nextController animated:YES];
            }
            
        }
    }
}
#pragma mark Search Bar Delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [_imageFog removeFromSuperview];
    _keySearch = searchBar.text;
    searchBar.text = @"";
    SCProductListViewController *productListViewController = [SCProductListViewController new];
    productListViewController.productListGetProductType = ProductListGetProductTypeFromSearch;
    productListViewController.keySearchProduct = _keySearch;
    [self.navigationController pushViewController:productListViewController animated:YES];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if (_imageFog == nil) {
        _imageFog = [[UIImageView alloc]initWithFrame:self.view.bounds];
        [_imageFog setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.3]];
        [_imageFog setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapImageFog)];
        [_imageFog addGestureRecognizer:tapGestureRecognizer];
    }
    [self.view addSubview:_imageFog];
    [self.view bringSubviewToFront:searchBarBackground];
    [self.view bringSubviewToFront:searchBarHome];
    return YES;
}

- (void)didTapImageFog
{   CGRect searchBarFrame = searchBarHome.frame;
    searchBarFrame.origin.y = [SimiGlobalVar scaleValue:-33];
    searchBarHome.frame = searchBarFrame;
    [UIView animateWithDuration:0.3 animations:^{
        searchBarBackground.frame = searchBarFrame;
        [searchBarHome resignFirstResponder];
        [_imageFog removeFromSuperview];
        searchBarHome.text = @"";
    }];
}


- (void)swipeTableView:(UISwipeGestureRecognizer *)recognizer {
    
    CGRect searchBarFrame = searchBarHome.frame;
    //    if (recognizer.direction == UISwipeGestureRecognizerDirectionDown) {
    searchBarFrame.origin.y = [SimiGlobalVar scaleValue:5];
    searchBarHome.frame = searchBarFrame;
    searchBarBackground.frame = searchBarFrame;
    [self searchBarShouldBeginEditing:searchBarHome];
    [UIView animateWithDuration:0.3 animations:^{
        [searchBarHome becomeFirstResponder];
    }];
    //    }
    //    else if (recognizer.direction == UISwipeGestureRecognizerDirectionUp){
    ////
    //    }
    //    else {
    //        location.x += 220.0;
    //    }
    
    
}
@end
