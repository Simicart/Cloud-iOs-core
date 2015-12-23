//
//  SCHomeViewControllerPad.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/7/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SCHomeViewControllerPad.h"
#import "SCThemeWorker.h"
#import "SCProductViewControllerPad.h"
#import "AFViewShaker.h"
@interface SCHomeViewControllerPad (){
    //Gin edit
    BOOL boolShakerCate,boolShakerSport;
    //end
}

@end

@implementation SCHomeViewControllerPad

@synthesize cells = _cells;


- (void)viewDidLoadBefore
{
    [self configureLogo];
    [self configureNavigationBarOnViewDidLoad];
    [self setToSimiView];
    //Gin edit
    boolShakerCate = NO;
    boolShakerSport = NO;
    countNumberSpotDidGetData = 0;
    //end
    [[UITableView appearanceWhenContainedIn:[self class], nil] setSeparatorInset:UIEdgeInsetsZero];
    
    self.tableViewHome = [[SimiTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
    self.tableViewHome.dataSource = self;
    self.tableViewHome.delegate = self;
    self.tableViewHome.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableViewHome.showsVerticalScrollIndicator = NO;
    [self.tableViewHome setBackgroundColor:[UIColor clearColor]];
    if (SIMI_SYSTEM_IOS >= 9.0 ) {
         self.tableViewHome.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [self.tableViewHome setContentInset:UIEdgeInsetsMake([SimiGlobalVar scaleValue:38], 0, 0, 0)];
    [self.tableViewHome setSeparatorColor:[UIColor clearColor]];
    [self.view addSubview:self.tableViewHome];
    
    [self setCells:nil];
    [self getBanners];
    [self getHomeCategories];
    [self getSpotCollection];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationWillResignActive" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:SDWebImageDownloadStopNotification object:nil];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [self.navigationController.view addSubview:[[[SCThemeWorker sharedInstance] navigationBarPad]leftMenuPad].view];
    [super viewDidAppear:animated];
}

#pragma mark setCells
- (void)setCells:(NSMutableArray *)cells{
    if (cells) {
        _cells = cells;
    }else{
        _cells = [[NSMutableArray alloc] init];
        SimiSection *section = [[SimiSection alloc] init];
        if (self.bannerCollection.count > 0) {
            SimiRow *row = [[SimiRow alloc] init];
            row.identifier = HOME_BANNER_CELL;
            row.height = 356;
            [section addRow:row];
        }
        if (self.homeCategoryModelCollection.count > 0) {
            SimiRow *row = [[SimiRow alloc] init];
            row.identifier = HOME_CATEGORY_CELL;
            row.height = 290;
            [section addRow:row];
        }
        
        if (self.spotCollection.count > 0 && self.spotArray.count > 0) {
            for (int i = 0; i < self.spotArray.count; i++) {
                SimiProductModelCollection *spotProductModelCollection = (SimiProductModelCollection*)[self.spotArray objectAtIndex:i];
                if (spotProductModelCollection.count > 0) {
                    SimiRow *row = [[SimiRow alloc] init];
                    row.identifier = HOME_SPOT_CELL;
                    row.height = [SimiGlobalVar scaleValue:330];
                    [section addRow:row];
                    row.data = [[NSMutableDictionary alloc]initWithDictionary:@{@"data":spotProductModelCollection}];
                }
            }
        }
        if (!(self.isDidGetHomeCategory && self.isDidGetSpotProducts && self.isDidGetBanner && (countNumberSpotDidGetData == self.spotCollection.count))) {
            SimiRow *row = [[SimiRow alloc] init];
            row.identifier = HOME_LOADING_CELL;
            row.height = 290;
            [section addRow:row];
        }else
            [[NSNotificationCenter defaultCenter]postNotificationName:@"DidGetAllDataAtHome" object:nil];
        [_cells addObject:section];
    }
    [self.tableViewHome reloadData];
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
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (self.bannerCollection.count > 0) {
                _carousel = [[iCarousel alloc]initWithFrame:CGRectMake(10, 0, 1004, 356)];
                [_carousel setBackgroundColor:[UIColor clearColor]];
                _carousel.type = iCarouselTypeCoverFlow2;
                _carousel.dataSource = self;
                _carousel.delegate = self;
                _carousel.scrollSpeed = 0.5;
                if (self.arrayImageBanner.count >= 3)
                    [_carousel scrollToItemAtIndex:1 animated:NO];
                [cell addSubview:_carousel];
                
                _arrayImageBanner = [[NSMutableArray alloc]init];
                _arrayBannerModel = [[NSMutableArray alloc]init];
                for (SimiModel *model in self.bannerCollection) {
                    if (![[model valueForKey:isFake]boolValue]) {
                        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 670, 356)];
                        if ([model valueForKey:@"image"] && [[model valueForKey:@"image"] valueForKey:@"url"]) {
                            [imageView sd_setImageWithURL:[[model valueForKey:@"image"] valueForKey:@"url"] placeholderImage:[UIImage imageNamed:@"logo"] options:0 progress:nil completed:nil];
                            [_arrayImageBanner addObject:imageView];
                            [_arrayBannerModel addObject:model];
                        }
                    }else
                    {
                         UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 670, 356)];
                        [imageView setImage:[UIImage imageNamed:@"default_banner"]];
                         [_arrayImageBanner addObject:imageView];
                        [_arrayBannerModel addObject:model];
                    }
                }
                [_carousel reloadData];
                if (self.bannerCollection.count == 1)
                    _carousel.scrollEnabled = NO;
            }
        }
    }
    else if ([simiRow.identifier isEqualToString:HOME_CATEGORY_CELL]) {
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if (self.categoryCollectionView ==nil) {
                UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
                flowLayout.itemSize = [SimiGlobalVar scaleSize:CGSizeMake(220, 280)];
                flowLayout.minimumLineSpacing = [SimiGlobalVar scaleValue:10];
                flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
                self.categoryCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 280) collectionViewLayout:flowLayout];
                [self.categoryCollectionView setCollectionViewLayout:flowLayout animated:YES];
                [self.categoryCollectionView setBackgroundColor:[UIColor clearColor]];
                self.categoryCollectionView.simiObjectName = HOME_CATEGORY_COLLECTION_VIEW;
                [self.categoryCollectionView setDelegate:self];
                [self.categoryCollectionView setDataSource:self];
                self.categoryCollectionView.showsHorizontalScrollIndicator = NO;
                [self.categoryCollectionView setContentInset:UIEdgeInsetsMake(0, 10, 0, 10)];
            }
            
            [cell addSubview:self.categoryCollectionView];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        // Gin edit Shaker  rung image
        if(self.homeCategoryModelCollection.count > 0&&(boolShakerCate == NO)){
            AFViewShaker * viewShaker = [[AFViewShaker alloc] initWithView:self.categoryCollectionView];
            [viewShaker shakeWithDuration:1 completion:^{
            }];
            boolShakerCate = YES;
        }
        //end
    }
    
    else if ([simiRow.identifier isEqualToString:HOME_SPOT_CELL]){
        SimiProductModelCollection *spotProductModelCollection = (SimiProductModelCollection*)[simiRow.data valueForKey:@"data"];
        NSString *cellIdentifier = [NSString stringWithFormat:@"%@%@",HOME_SPOT_CELL,spotProductModelCollection.simiObjectIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UILabel *label = [[UILabel alloc]initWithFrame: CGRectMake(10, 20,SCREEN_WIDTH - 30, 22)];
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                label.frame = CGRectMake(20, 20,SCREEN_WIDTH - 30, 22);
                [label setTextAlignment:NSTextAlignmentRight];
            }
            label.text = [SCLocalizedString(spotProductModelCollection.simiObjectName) uppercaseString];
            label.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:25];
            [label setTextColor:THEME_CONTENT_COLOR];
            
            UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
            flowLayout.itemSize = [SimiGlobalVar scaleSize:CGSizeMake(200, 280)];
            flowLayout.minimumLineSpacing = [SimiGlobalVar scaleValue:10];
            flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            UICollectionView *spotProductCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 60, SCREEN_WIDTH, 280) collectionViewLayout:flowLayout];
            [spotProductCollectionView setCollectionViewLayout:flowLayout animated:YES];
            spotProductCollectionView.simiObjectIdentifier = spotProductModelCollection;
            [spotProductCollectionView setBackgroundColor:[UIColor clearColor]];
            spotProductCollectionView.simiObjectName = HOME_SPOT_CELL;
            [spotProductCollectionView setDelegate:self];
            [spotProductCollectionView setDataSource:self];
            spotProductCollectionView.showsHorizontalScrollIndicator = NO;
            [spotProductCollectionView setContentInset:UIEdgeInsetsMake(0, 10, 0, 10)];
            
            [cell addSubview:spotProductCollectionView];
            [cell addSubview:label];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            // Gin edit Shaker  rung image
            if( self.spotCollection.count > 0&&(boolShakerSport == NO)){
                AFViewShaker * viewShaker = [[AFViewShaker alloc] initWithView:spotProductCollectionView];
                [viewShaker shakeWithDuration:1 completion:^{
                }];
                boolShakerSport = YES;
            }
            //end
        }
    }else if ([simiRow.identifier isEqualToString:HOME_LOADING_CELL])
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, cell.frame.size.width/2 - 100, 320, 100)];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        imageView.image = [UIImage imageNamed:@"logo"];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        CGRect frame = imageView.frame;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.origin.y + frame.size.height - 30, frame.size.width, 30)];
        label.text = [NSString stringWithFormat:@"%@...", SCLocalizedString(@"Loading")];
        label.textColor = THEME_COLOR;
        label.textAlignment = NSTextAlignmentCenter;
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [cell addSubview:imageView];
        [cell addSubview:label];
    } else{
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
    [cell setBackgroundColor:[UIColor clearColor]];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedHomeCell-After" object:cell userInfo:@{@"indexPath": indexPath, @"controller":self}];
    return cell;
}

#pragma mark UICollectionView DataSources

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (collectionView.simiObjectName == HOME_CATEGORY_COLLECTION_VIEW) {
        [collectionView registerClass:[SCHomeCategoryCollectionViewCellPad class] forCellWithReuseIdentifier:HOME_CATEGORY_COLLECTION_VIEW_CELL];
        SCHomeCategoryCollectionViewCellPad *categoryViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:HOME_CATEGORY_COLLECTION_VIEW_CELL forIndexPath:indexPath];
        categoryViewCell.category = [self.homeCategoryModelCollection objectAtIndex:indexPath.row];
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
        [productViewCell.nameLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:16]];
        [productViewCell.nameLabel setFrame:CGRectMake(productViewCell.nameLabel.frame.origin.x, productViewCell.nameLabel.frame.origin.y , productViewCell.nameLabel.frame.size.width, 18)];
        [productViewCell.priceLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:16]];
        [productViewCell.priceLabel setFrame:CGRectMake(productViewCell.priceLabel.frame.origin.x, productViewCell.priceLabel.frame.origin.y + 7, productViewCell.priceLabel.frame.size.width, 18)];
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
            SCProductViewControllerPad *nextController = [[SCProductViewControllerPad alloc]init];
            [nextController setFirstProductID:cell.productID];
            [nextController setArrayProductsID:spotProductModelCollection.productIDs];
            [self.navigationController pushViewController:nextController animated:YES];
        }
    }
    
    if (collectionView.simiObjectName == HOME_CATEGORY_COLLECTION_VIEW) {
        SCHomeCategoryCollectionViewCellPad *cell = (SCHomeCategoryCollectionViewCellPad *)[collectionView cellForItemAtIndexPath:indexPath];
        if (cell.category != nil && ![[cell.category valueForKey:isFake]boolValue]) {
            SCProductListViewControllerPad *nextController = [[SCProductListViewControllerPad alloc]init];
            [nextController setCategoryID:cell.categoryID];
            nextController.productListGetProductType = ProductListGetProductTypeFromCategory;
            [self.navigationController pushViewController:nextController animated:YES];
        }
    }
}

#pragma mark iCaroucel DataSource
- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    return [_arrayImageBanner objectAtIndex:index];
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [_arrayImageBanner count];
}

#pragma mark iCaroucel Delegate
- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    id banner = [_arrayBannerModel objectAtIndex:index];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"DidClickBanner" object:banner];
    if ([[banner valueForKey:@"type"] isEqualToString:@"2"]) {
        SCProductListViewControllerPad* nextController = [SCProductListViewControllerPad new];
        nextController.categoryID = [banner valueForKey:@"categoryID"];
        [self.navigationController pushViewController:nextController animated:YES];
    }else if([[banner valueForKey:@"type"] isEqualToString:@"1"]){
        SCProductViewControllerPad *nextController = [SCProductViewControllerPad new];
        [nextController setProductId:[banner valueForKey:@"productID"]];
        [self.navigationController pushViewController:nextController animated:YES];
    }else{
        if (![[banner valueForKey:@"url"] isKindOfClass:[NSNull class]] && [banner valueForKey:@"url"] != nil){
            if ([[[banner valueForKey:@"url"] lowercaseString] rangeOfString:@"http"].location != NSNotFound) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[banner valueForKey:@"url"]]];
            }
        }
    }
}


@end
