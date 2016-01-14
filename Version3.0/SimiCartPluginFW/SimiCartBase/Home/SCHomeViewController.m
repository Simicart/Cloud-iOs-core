
//  SCHomeViewController.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/3/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SCHomeViewController.h"
#import "SimiResponder.h"
#import "SimiSection.h"
#import "SCProductViewController.h"
#import "SCCategoryViewController.h"
#import "SCProductListViewController.h"
#import "SCHomeCategoryCollectionViewCell.h"
#import "SCThemeWorker.h"
#import "AFViewShaker.h"

@interface SCHomeViewController ()
{
    BOOL boolShaker;
}
@end

@implementation SCHomeViewController

@synthesize searchBarHome, imageViewLogo, tableViewHome, bannerSlider;
@synthesize bannerCollection, spotCollection, homeCategoryModelCollection, categoryCollectionView ;
@synthesize spotArray;
@synthesize searchBarBackground;


- (void)viewDidLoadBefore
{
    [super viewDidLoadBefore];
//    [self sendEmail];
    [self setToSimiView];
    //Gin edit
    boolShaker = NO;
    countNumberSpotDidGetData = 0;
    //end
    [[UITableView appearanceWhenContainedIn:[self class], nil] setSeparatorInset:UIEdgeInsetsZero];
    
    tableViewHome = [[SimiTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
    tableViewHome.dataSource = self;
    tableViewHome.delegate = self;
    tableViewHome.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tableViewHome.showsVerticalScrollIndicator = NO;
    [tableViewHome setContentInset:UIEdgeInsetsMake([SimiGlobalVar scaleValue:38], 0, 0, 0)];
    [tableViewHome setBackgroundColor:[UIColor clearColor]];
    [tableViewHome setSeparatorColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#e8e8e8"]];
    [self.view addSubview:tableViewHome];
    
    
    searchBarHome = [[UISearchBar alloc] initWithFrame:[SimiGlobalVar scaleFrame:CGRectMake(5, 5, 310, 28)]];
    searchBarHome.tintColor = THEME_SEARCH_TEXT_COLOR;
    searchBarHome.searchBarStyle = UIBarStyleBlackTranslucent;
    searchBarHome.placeholder = SCLocalizedString(@"Search on All Products");
    searchBarHome.layer.backgroundColor = [UIColor clearColor].CGColor;
    searchBarHome.layer.borderColor = [UIColor clearColor].CGColor;
    searchBarHome.layer.borderWidth = 1;
    [[NSClassFromString(@"UISearchBarTextField") appearanceWhenContainedIn:[UISearchBar class], nil] setBorderStyle:UITextBorderStyleNone];
    searchBarHome.layer.borderColor=[UIColor clearColor].CGColor;
    searchBarHome.delegate = self;
    for ( UIView * subview in [[searchBarHome.subviews objectAtIndex:0] subviews] )
    {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarTextField") ] ) {
            UITextField *searchView = (UITextField *)subview;
            [searchView setBorderStyle:UITextBorderStyleNone];
            [searchView.rightView setBackgroundColor:THEME_SEARCH_ICON_COLOR];
            searchView.textColor = THEME_SEARCH_TEXT_COLOR;
            [searchView setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Search" attributes:@{NSForegroundColorAttributeName: THEME_SEARCH_TEXT_COLOR}]];
            if ([[SimiGlobalVar sharedInstance] isReverseLanguage]) {
                [searchView setTextAlignment:NSTextAlignmentRight];
            }
        }
    }
    [searchBarHome setBackgroundColor:[UIColor clearColor]];
    
    searchBarBackground = [[UIView alloc]initWithFrame:searchBarHome.frame];
    [searchBarBackground setBackgroundColor:THEME_SEARCH_BOX_BACKGROUND_COLOR];
    [searchBarBackground setAlpha:0.9f];
    
    [self.view addSubview:searchBarBackground];
    [self.view addSubview:searchBarHome];
    
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

- (void)viewWillAppearBefore:(BOOL)animated{
    [tableViewHome deselectRowAtIndexPath:[tableViewHome indexPathForSelectedRow] animated:YES];
    [super viewWillAppearBefore:animated];
}

- (void)setCells:(NSMutableArray *)cells{
    if (cells) {
        _cells = cells;
    }else{
        _cells = [[NSMutableArray alloc] init];
        SimiSection *section = [[SimiSection alloc] init];
        if (bannerCollection.count > 0) {
            SimiRow *row = [[SimiRow alloc] init];
            row.identifier = HOME_BANNER_CELL;
            row.height = [SimiGlobalVar scaleValue:170];
            [section addRow:row];
        }
        
        if (homeCategoryModelCollection.count > 0) {
            SimiRow *row = [[SimiRow alloc] init];
            row.identifier = HOME_CATEGORY_CELL;
            row.height = [SimiGlobalVar scaleValue:177];
            [section addRow:row];
        }
        
        if (spotCollection.count > 0 && spotArray.count > 0) {
            for (int i = 0; i < spotArray.count; i++) {
                SimiProductModelCollection *spotProductModelCollection = (SimiProductModelCollection*)[spotArray objectAtIndex:i];
                if (spotProductModelCollection.count > 0) {
                    SimiRow *row = [[SimiRow alloc] init];
                    row.identifier = HOME_SPOT_CELL;
                    row.height = [SimiGlobalVar scaleValue:177];
                    [section addRow:row];
                    row.data = [[NSMutableDictionary alloc]initWithDictionary:@{@"data":spotProductModelCollection}];
                }
            }
        }
        if (!(self.isDidGetHomeCategory && self.isDidGetBanner && self.isDidGetSpotProducts && (countNumberSpotDidGetData == self.spotCollection.count))) {
            SimiRow *row = [[SimiRow alloc] init];
            row.identifier = HOME_LOADING_CELL;
            row.height = [SimiGlobalVar scaleValue:177];
            [section addRow:row];
        }
        [_cells addObject:section];
    }
    [tableViewHome reloadData];
}

#pragma mark Get Data
- (void)getBanners{
    if (bannerCollection == nil) {
        bannerCollection = [[SimiBannerModelCollection alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetBanner:) name:DidGetBanner object:bannerCollection];
        [bannerCollection getBannerCollection];
        self.isDidGetBanner = NO;
    }
}

- (void)getSpotCollection{
    if (spotCollection == nil) {
        spotCollection = [[SimiSpotModelCollection alloc] init];
    }
    [spotCollection removeAllObjects];
    [spotCollection getSpotCollection];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetSpotCollection:) name:DidGetSpotCollection object:spotCollection];
    self.isDidGetSpotProducts = NO;
}

- (void)getHomeCategories{
    if (homeCategoryModelCollection ==nil) {
        homeCategoryModelCollection = [[SimiCategoryModelCollection alloc]init];
    }
    [homeCategoryModelCollection removeAllObjects];
    [homeCategoryModelCollection getHomeDefaultCategories];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetHomeCategories:) name:DidGetHomeCategories object:homeCategoryModelCollection];
    self.isDidGetHomeCategory = NO;
}

- (void)getBestSellerProducts:(SimiModel*) spotModel
{
    SimiProductModelCollection* bestSellerProductModelCollection = [SimiProductModelCollection new];
    bestSellerProductModelCollection.simiObjectIdentifier = [spotModel valueForKey:@"_id"];
    bestSellerProductModelCollection.simiObjectName = [spotModel valueForKey:@"name"];
    [spotArray addObject:bestSellerProductModelCollection];
//    [bestSellerProductModelCollection getAllProductsWithOffset:0 limit:20 sortType:ProductCollectionSortNone otherParams:@{@"group-type":@"best-sellers"}];
    [bestSellerProductModelCollection getAllProductsWithOffset:0 limit:100 sortType:ProductCollectionSortNone otherParams:@{@"filter[type]":@"configurable"}];
}
- (void)getNewlyUpdatedProducts:(SimiModel*) spotModel
{
    SimiProductModelCollection *newlyUpdatedProductModelCollection = [SimiProductModelCollection new];
    newlyUpdatedProductModelCollection.simiObjectIdentifier = [spotModel valueForKey:@"_id"];
    newlyUpdatedProductModelCollection.simiObjectName = [spotModel valueForKey:@"name"];
    [spotArray addObject:newlyUpdatedProductModelCollection];
    [newlyUpdatedProductModelCollection getAllProductsWithOffset:0 limit:20 sortType:ProductCollectionSortNone otherParams:@{@"order":@"updated_at",@"dir":@"desc"}];
}
- (void)getRecentAddedProducts:(SimiModel*) spotModel
{
    SimiProductModelCollection *recentAddedProductModelCollection = [SimiProductModelCollection new];
    recentAddedProductModelCollection.simiObjectIdentifier = [spotModel valueForKey:@"_id"];
    recentAddedProductModelCollection.simiObjectName = [spotModel valueForKey:@"name"];
    [spotArray addObject:recentAddedProductModelCollection];
    [recentAddedProductModelCollection getAllProductsWithOffset:0 limit:20 sortType:ProductCollectionSortNone otherParams:@{@"order":@"created_at",@"dir":@"desc"}];
}
- (void)getFeatureProducts:(SimiModel*) spotModel
{
  
    SimiProductModelCollection *featureProductModelCollection = [SimiProductModelCollection new];
    featureProductModelCollection.simiObjectIdentifier = [spotModel valueForKey:@"_id"];
    featureProductModelCollection.simiObjectName = [spotModel valueForKey:@"name"];
    [spotArray addObject:featureProductModelCollection];
    NSString *stringIds = @"";
    for (int i = 0;i < self.spotCollection.count; i++) {
        SimiModel *model = [self.spotCollection objectAtIndex:i];
        if ([[model valueForKey:@"type"]intValue] == 4) {
            if ([[model valueForKey:@"products"] isKindOfClass:[NSMutableArray class]]) {
                NSMutableArray *arrayIds = [[NSMutableArray alloc]initWithArray:[model valueForKey:@"products"]];
                for (int j =0; j < arrayIds.count; j++) {
                    if (j!= 0) {
                        stringIds = [NSString stringWithFormat:@"%@,%@",stringIds,[arrayIds objectAtIndex:j]];
                    }else
                        stringIds = [NSString stringWithFormat:@"%@",[arrayIds objectAtIndex:j]];
                }
            }
        }
    }
    [featureProductModelCollection getAllProductsWithOffset:0 limit:20 sortType:ProductCollectionSortNone otherParams:@{@"ids":stringIds}];
}


- (void)didGetBanner:(NSNotification *)noti{
    if ([noti.name isEqualToString:DidGetBanner]) {
        [self removeObserverForNotification:noti];
        self.isDidGetBanner = YES;
        SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
        if (self.bannerCollection.count == 0 && [DEMO_MODE boolValue]) {
            SimiModel *model =[SimiModel new];
            [model setValue:@"YES" forKey:isFake];
            [self.bannerCollection addObject:model];
        }
        if ([responder.status isEqualToString:@"SUCCESS"]) {
            [self setCells:nil];
        }
    }
}

- (void)didGetSpotCollection:(NSNotification *)noti{
    if ([noti.name isEqualToString:DidGetSpotCollection]) {
        [self removeObserverForNotification:noti];
        self.isDidGetSpotProducts = YES;
        SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
        if(self.spotCollection.count == 0 && [DEMO_MODE boolValue])
        {
            NSMutableDictionary *spotData = [NSMutableDictionary new];
            NSMutableArray *spotProducts = [NSMutableArray new];
            for (int i = 1; i < 10; i++) {
                SimiProductModel *productModel = [SimiProductModel new];
                [productModel setValue:@"YES" forKey:isFake];
                [productModel setValue:[NSString stringWithFormat:@"Product %d",i] forKey:@"product_name"];
                [spotProducts addObject:productModel];
            }
            [spotData setObject:spotProducts forKey:@"data"];
            [spotData setValue:@"Feature Products" forKey:@"title"];
            [self.spotCollection addObject:spotData];
        }
        if ([responder.status isEqualToString:@"SUCCESS"]) {
            if (self.spotCollection.count > 0) {
                [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetSpotProducts:) name:DidGetAllProducts object:nil];
                spotArray = [NSMutableArray new];
                for (int i = 0; i < self.spotCollection.count; i++) {
                    SimiModel *model = [self.spotCollection objectAtIndex:i];
                    int spotType = [[model valueForKey:@"type"]intValue];
                    switch (spotType) {
                        case 1:
                        {
                            [self getBestSellerProducts:model];
                        }
                            break;
                        case 2:
                        {
                            [self getNewlyUpdatedProducts:model];
                        }
                            break;
                        case 3:
                        {
                            [self getRecentAddedProducts:model];
                        }
                            break;
                        case 4:
                        {
                            [self getFeatureProducts:model];
                        }
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }
}


- (void)didGetHomeCategories:(NSNotification *)noti{
    if ([noti.name isEqualToString:@"DidGetHomeCategories"]) {
        [self removeObserverForNotification:noti];
        self.isDidGetHomeCategory = YES;
        SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
        if ([responder.status isEqualToString:@"SUCCESS"]) {
            if (self.homeCategoryModelCollection.count == 0 && [DEMO_MODE boolValue]) {
                for (int i = 1; i < 10; i++) {
                    SimiModel *cateModel = [SimiModel new];
                    [cateModel setValue:@"YES" forKey:isFake];
                    [cateModel setValue:[NSString stringWithFormat:@"Category %d",i] forKey:@"category_name"];
                    [cateModel setValue:@"" forKey:@"category_image"];
                    [self.homeCategoryModelCollection addObject:cateModel];
                }
            }
            [self setCells:nil];
        }
    }
}

- (void)didGetSpotProducts:(NSNotification*)noti
{
    if ([noti.name isEqualToString:DidGetAllProducts]) {
        countNumberSpotDidGetData += 1;
        [self setCells:nil];
    }
}

#pragma mark Table View Data Source
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
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:simiRow.identifier];
    if ([simiRow.identifier isEqualToString:HOME_BANNER_CELL]){
        if (cell == nil) {
            cell = [tableView dequeueReusableCellWithIdentifier:simiRow.identifier];
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setBackgroundColor:[UIColor clearColor]];
            if (bannerSlider == nil) {
                bannerSlider = [[KASlideShow alloc] initWithFrame:[SimiGlobalVar scaleFrame:CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, 170)]];
                UITapGestureRecognizer *tapGestureRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapInBanner:)];
                [bannerSlider addGestureRecognizer:tapGestureRecog];
                [bannerSlider setImagesContentMode:UIViewContentModeScaleAspectFit];
                [bannerSlider setDelay:3];
                [bannerSlider setTransitionDuration:0.5];
                [bannerSlider setTransitionType:KASlideShowTransitionSlide];
                bannerSlider.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                [cell addSubview:bannerSlider];
            }
            if (bannerCollection.count > 0) {
                [bannerSlider addGesture:KASlideShowGestureSwipe];
            }
            for (SimiModel *model in bannerCollection) {
                if (![[model valueForKey:isFake]boolValue]) {
                    [bannerSlider addImagePath:[[model valueForKey:@"image"]valueForKey:@"url"]];
                }else
                {
                    bannerSlider.useImages = YES;
                    [bannerSlider addImage:[UIImage imageNamed:@"default_banner"]];
                }
            }
            [bannerSlider start];
        }
    }
    else if ([simiRow.identifier isEqualToString:HOME_CATEGORY_CELL]) {
        if (cell == nil) {
            cell = [tableView dequeueReusableCellWithIdentifier:simiRow.identifier];
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setBackgroundColor:[UIColor clearColor]];
            UILabel *label = [[UILabel alloc]initWithFrame: [SimiGlobalVar scaleFrame:CGRectMake(5, 10, cell.frame.size.width - 30, [SimiGlobalVar scaleValue:10])]];
            //gin edit
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                [label setFrame:[SimiGlobalVar scaleFrame:CGRectMake(25, 10, cell.frame.size.width - 30,[SimiGlobalVar scaleValue:10])]];
                [label setTextAlignment:NSTextAlignmentRight];
            }
            //end
            label.text = [SCLocalizedString(@"Category") uppercaseString];
            label.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE-2];
            label.textColor = THEME_CONTENT_COLOR;
            
            if (categoryCollectionView ==nil) {
                
                UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
                flowLayout.itemSize = [SimiGlobalVar scaleSize:CGSizeMake(110, 147)];
                flowLayout.minimumLineSpacing = [SimiGlobalVar scaleValue:5];
                flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
                categoryCollectionView = [[UICollectionView alloc] initWithFrame:[SimiGlobalVar scaleFrame:CGRectMake(0, 30, 320, 147)] collectionViewLayout:flowLayout];
                [categoryCollectionView setCollectionViewLayout:flowLayout animated:YES];
                [categoryCollectionView setBackgroundColor:[UIColor clearColor]];
                categoryCollectionView.simiObjectName = HOME_CATEGORY_COLLECTION_VIEW;
                [categoryCollectionView setDelegate:self];
                [categoryCollectionView setDataSource:self];
                categoryCollectionView.showsHorizontalScrollIndicator = NO;
                [categoryCollectionView setContentInset:UIEdgeInsetsMake(0, [SimiGlobalVar scaleValue:5], 0, [SimiGlobalVar scaleValue:5])];
            }
            
            [cell addSubview:categoryCollectionView];
            [cell addSubview:label];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            // Gin edit Shaker  rung image
            if( homeCategoryModelCollection.count > 0){
                AFViewShaker * viewShaker = [[AFViewShaker alloc] initWithView:categoryCollectionView];
                [viewShaker shakeWithDuration:1 completion:^{}];
            }
            //end
        }
    }
    else if ([simiRow.identifier isEqualToString:HOME_SPOT_CELL]){
        SimiProductModelCollection *spotProductModelCollection = (SimiProductModelCollection*)[simiRow.data valueForKey:@"data"];
        NSString *cellIdentifier = [NSString stringWithFormat:@"%@%@",HOME_SPOT_CELL,spotProductModelCollection.simiObjectIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setBackgroundColor:[UIColor clearColor]];
            UILabel *label = [[UILabel alloc]initWithFrame: [SimiGlobalVar scaleFrame:CGRectMake(5, 10, cell.frame.size.width - 30, [SimiGlobalVar scaleValue:10])]];
            //gin edit
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                [label setFrame:[SimiGlobalVar scaleFrame:CGRectMake(25, 10, cell.frame.size.width - 30,[SimiGlobalVar scaleValue:10])]];
                [label setTextAlignment:NSTextAlignmentRight];
            }
            //end
            label.text = [SCLocalizedString(spotProductModelCollection.simiObjectName) uppercaseString];
            label.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE-2];
            label.textColor = THEME_CONTENT_COLOR;
            
            UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
            flowLayout.itemSize = [SimiGlobalVar scaleSize:CGSizeMake(100, 147)];
            flowLayout.minimumLineSpacing = [SimiGlobalVar scaleValue:5];
            flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            UICollectionView *spotProductCollectionView = [[UICollectionView alloc] initWithFrame:[SimiGlobalVar scaleFrame:CGRectMake(0, 30, 320, 147)] collectionViewLayout:flowLayout];
            [spotProductCollectionView setCollectionViewLayout:flowLayout animated:YES];
            [spotProductCollectionView setBackgroundColor:[UIColor clearColor]];
            spotProductCollectionView.simiObjectName = HOME_SPOT_CELL;
            spotProductCollectionView.simiObjectIdentifier = spotProductModelCollection;
            [spotProductCollectionView setDelegate:self];
            [spotProductCollectionView setDataSource:self];
            spotProductCollectionView.showsHorizontalScrollIndicator = NO;
            [spotProductCollectionView setContentInset:UIEdgeInsetsMake(0, [SimiGlobalVar scaleValue:5], 0, [SimiGlobalVar scaleValue:5])];
            [cell addSubview:spotProductCollectionView];
            [cell addSubview:label];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            // Gin edit Shaker  rung image
            if(( spotCollection.count > 0) && (boolShaker == NO)){
                AFViewShaker * viewShaker = [[AFViewShaker alloc] initWithView:spotProductCollectionView];
                [viewShaker shakeWithDuration:1 completion:^{
                    boolShaker = YES;
                }];
            }
            //end
        }
    }else if ([simiRow.identifier isEqualToString:HOME_LOADING_CELL]){
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
            [cell setBackgroundColor:[UIColor clearColor]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UIImageView *imageView = [[UIImageView alloc] initWithFrame: [SimiGlobalVar scaleFrame:CGRectMake(0, cell.frame.size.width/2 - 100, 320, 100)]];
            imageView.image = [UIImage imageNamed:@"logo.png"];
            [imageView setContentMode:UIViewContentModeScaleAspectFit];
            CGRect frame = imageView.frame;
            UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(0, frame.origin.y + frame.size.height - [SimiGlobalVar scaleValue:30], frame.size.width, [SimiGlobalVar scaleValue:30])];
            label.text = [NSString stringWithFormat:@"%@...", SCLocalizedString(@"Loading")];
            label.textColor = THEME_COLOR;
            label.textAlignment = NSTextAlignmentCenter;
            [cell addSubview:imageView];
            [cell addSubview:label];
        }
    }else{
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:HOME_DEFAULT_CELL];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    cell.textLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
    cell.detailTextLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
    cell.textLabel.textColor = THEME_TEXT_COLOR;
    cell.detailTextLabel.textColor = THEME_LIGHT_TEXT_COLOR;

    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedHomeCell-After" object:cell userInfo:@{@"indexPath": indexPath, @"controller":self}];
    return cell;
}

#pragma mark Table View Delegates

// To make full width tableView Separating Lines
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
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


#pragma mark UICollectionView DataSources
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return  1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView.simiObjectName == HOME_CATEGORY_COLLECTION_VIEW) {
        return [homeCategoryModelCollection count];
    }
    if (collectionView.simiObjectName == HOME_SPOT_CELL) {
        SimiProductModelCollection *spotProductModelCollection = (SimiProductModelCollection *)collectionView.simiObjectIdentifier;
        return spotProductModelCollection.count;
    }
    return 0;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView.simiObjectName == HOME_CATEGORY_COLLECTION_VIEW) {
        [collectionView registerClass:[SCHomeCategoryCollectionViewCell class] forCellWithReuseIdentifier:HOME_CATEGORY_COLLECTION_VIEW_CELL];
        SCHomeCategoryCollectionViewCell *categoryViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:HOME_CATEGORY_COLLECTION_VIEW_CELL forIndexPath:indexPath];
        categoryViewCell.category = [homeCategoryModelCollection objectAtIndex:indexPath.row];
        CGSize cellSize = [(UICollectionViewFlowLayout *)collectionView.collectionViewLayout itemSize];
        [categoryViewCell setFrame:CGRectMake(categoryViewCell.frame.origin.x, categoryViewCell.frame.origin.y, cellSize.width, cellSize.height)];
        return categoryViewCell;
    }
    if (collectionView.simiObjectName == HOME_SPOT_CELL) {
        SimiProductModelCollection *spotProductModelCollection = (SimiProductModelCollection *) collectionView.simiObjectIdentifier;
        SimiProductModel *productModel = [spotProductModelCollection objectAtIndex:indexPath.row];
        NSString *cellIdentifier =  [NSString stringWithFormat:@"%@%@",HOME_SPOT_CELL,[productModel valueForKey:@"_id"]];
        [collectionView registerClass:[SCHomeSpotProductCell class] forCellWithReuseIdentifier:cellIdentifier];
        SCHomeSpotProductCell *productViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        productViewCell.product = productModel;
        CGSize cellSize = [(UICollectionViewFlowLayout *)collectionView.collectionViewLayout itemSize];
        [productViewCell setFrame:CGRectMake(productViewCell.frame.origin.x, productViewCell.frame.origin.y, cellSize.width, cellSize.height)];
        return productViewCell;
    }
    return [UICollectionViewCell new];
}


#pragma mark UICollectionView Delegates

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView.simiObjectName == HOME_SPOT_CELL) {
        SimiProductModelCollection *spotProductModelCollection = (SimiProductModelCollection*)collectionView.simiObjectIdentifier;
        SCHomeSpotProductCell *cell = (SCHomeSpotProductCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if (cell.product != nil && ![[cell.product valueForKey:isFake]boolValue]) {
            SCProductViewController *nextController = [[SCProductViewController alloc]init];
            [nextController setFirstProductID:cell.productID];
            [nextController setArrayProductsID:spotProductModelCollection.productIDs];
            [self.navigationController pushViewController:nextController animated:YES];
        }
    }
    
    if (collectionView.simiObjectName == HOME_CATEGORY_COLLECTION_VIEW) {
        SCHomeCategoryCollectionViewCell *cell = (SCHomeCategoryCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if (cell.category != nil && cell.categoryID != nil && ![cell.categoryID isEqualToString:@""]) {
            if ([[cell.category valueForKey:@"has_children"]boolValue]) {
                SCCategoryViewController *nextController = [[SCCategoryViewController alloc]init];
                [nextController setCategoryId:cell.categoryID];
                [nextController setCategoryRealName:cell.name];
                [self.navigationController pushViewController:nextController animated:YES];
            }else
            {
                SCProductListViewController *productListViewController = [SCProductListViewController new];
                productListViewController.productListGetProductType = ProductListGetProductTypeFromCategory;
                productListViewController.categoryID = cell.categoryID;
                productListViewController.categoryName = cell.name;
                [self.navigationController pushViewController:productListViewController animated:YES];
            }
        }
    }
}

#pragma mark Banner Slider
- (void)tapInBanner:(UITapGestureRecognizer *)recognizer{
    if (bannerCollection.count > 0) {
        NSInteger offset = bannerSlider.currentIndex % bannerCollection.count;
        id banner = [bannerCollection objectAtIndex:offset];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"DidClickBanner" object:banner];
        if ([[NSString stringWithFormat:@"%@",[banner valueForKey:@"type"]] isEqualToString:@"2"]) {
            if(_categoryModel == nil) _categoryModel = [SimiCategoryModel new];
            [_categoryModel getCategoryWithId:[banner valueForKey:@"category_id"]];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:DidGetCategory object:_categoryModel];
            [self startLoadingData];
            
            
        }else if([[NSString stringWithFormat:@"%@",[banner valueForKey:@"type"]]isEqualToString:@"1"]){
            SCProductViewController *nextController = [SCProductViewController new];
            [nextController setProductId:[banner valueForKey:@"product_id"]];
            [self.navigationController pushViewController:nextController animated:YES];
        }else {
            if (![[banner valueForKey:@"url"] isKindOfClass:[NSNull class]] && [banner valueForKey:@"url"] != nil){
                if ([[[banner valueForKey:@"url"] lowercaseString] rangeOfString:@"http"].location != NSNotFound) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[banner valueForKey:@"url"]]];
                }
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
        [_imageFog setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.5]];
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
{
    [searchBarHome resignFirstResponder];
    [_imageFog removeFromSuperview];
    searchBarHome.text = @"";
}

-(void) didReceiveNotification:(NSNotification *)noti{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:noti.name object:nil];
    [self stopLoadingData];
    SimiResponder* responder = [noti.userInfo valueForKey:@"responder"];
    if([responder.status isEqualToString:@"SUCCESS"]){
        if([noti.name isEqualToString:DidGetCategory]){
            if ([[_categoryModel valueForKey:@"has_children"]boolValue]) {
                SCCategoryViewController* nextController = [SCCategoryViewController new];
                nextController.categoryId = [_categoryModel valueForKey:@"_id"];
                nextController.navigationItem.title = [[_categoryModel valueForKey:@"name"] uppercaseString];
                [self.navigationController pushViewController:nextController animated:YES];
            }else{
                SCProductListViewController *nextController = [[SCProductListViewController alloc]init];;
                nextController.categoryID = [_categoryModel valueForKey:@"_id"];
                nextController.categoryName = [_categoryModel valueForKey:@"name"];
                nextController.navigationItem.title = [[_categoryModel valueForKey:@"name"] uppercaseString];
                [self.navigationController pushViewController:nextController animated:YES];
            }
            
        }
    }
}
-(void)sendEmail {
    
    
    // create soft wait overlay so the user knows whats going on in the background.
    //    [self createWaitOverlay];
    
    //the guts of the message.
    SKPSMTPMessage *testMsg = [[SKPSMTPMessage alloc] init];
    testMsg.fromEmail = @"itpro1211@gmail.com";
    testMsg.toEmail = @"axe@simicart.com";
    testMsg.relayHost = @"smtp.gmail.com";
    testMsg.requiresAuth = YES;
    testMsg.login = @"itpro1211@gmail.com";
    testMsg.pass = @"trung1211";
    testMsg.subject = @"This is the email subject line";
    testMsg.wantsSecure = YES; // smtp.gmail.com doesn't work without TLS!
    
    
    
    // Only do this for self-signed certs!
    // testMsg.validateSSLChain = NO;
    testMsg.delegate = self;
    
    //email contents
    NSString * bodyMessage = [NSString stringWithFormat:@"This is the body of the email. You can put anything in here that you want."];
    
    
    NSDictionary *plainPart = [NSDictionary dictionaryWithObjectsAndKeys:@"text/plain",kSKPSMTPPartContentTypeKey,
                               bodyMessage ,kSKPSMTPPartMessageKey,@"8bit",kSKPSMTPPartContentTransferEncodingKey,nil];
    
    testMsg.parts = [NSArray arrayWithObjects:plainPart,nil];
    
    [testMsg send];
    
}
#pragma mark SKPSMTPMessage Delegate
-(void)messageSent:(SKPSMTPMessage *)message{
    NSLog(@"sent");
}
-(void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error{
    NSLog(@"fault: %@",error);
}


@end
