//
//  MatrixHomeViewControllerPad.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/7/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "MatrixHomeViewControllerPad.h"
#import "SCProductListViewControllerPad.h"
#import "SCProductViewControllerPad.h"
#import "SCThemeWorker.h"
#import "AFViewShaker.h"

@interface MatrixHomeViewControllerPad ()
{
    NSMutableArray *arrTemp01;
    NSMutableArray *arrTemp02;
}

@end

@implementation MatrixHomeViewControllerPad
@synthesize tableViewHome, bannerCollection,spotCollection, homeCategoryModelCollection;
@synthesize cells = _cells, viewCate01 = _viewCate01, viewCate02 = _viewCate02, viewCate03 = _viewCate03, viewAllCate = _viewAllCate;
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
    [self configureLogo];
    [self configureNavigationBarOnViewDidLoad];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return;
    }
    // Do any additional setup after loading the view.
    [self setToSimiView];
    tableViewHome = [[SimiTableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    tableViewHome.dataSource = self;
    tableViewHome.delegate = self;
    tableViewHome.scrollEnabled = NO;
    tableViewHome.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tableViewHome.showsVerticalScrollIndicator = NO;
    tableViewHome.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableViewHome];
    
    [self setCells:nil];
    [self getBanners];
    [self getHomeCategories];
    [self getSpotCollection];
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    [super viewWillAppearBefore:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self.navigationController.view addSubview:[[[SCThemeWorker sharedInstance] navigationBarPad]leftMenuPad].view];
}

- (void)setCells:(NSMutableArray *)cells
{
    if (cells) {
        _cells = cells;
    }else{
        _cells = [[NSMutableArray alloc] init];
        SimiSection *section = [[SimiSection alloc] init];
        if (self.bannerCollection.count > 0) {
            SimiRow *row01 = [[SimiRow alloc]initWithIdentifier:HOME_BANNER_CELL height:356];
            [section addObject:row01];
        }
        
        if (homeCategoryModelCollection.count > 0) {
            SimiRow *row02 = [[SimiRow alloc]initWithIdentifier:HOME_CATEGORY_CELL height:166];
            [section addObject:row02];
        }
        
        if (spotCollection.count > 0) {
            SimiRow *row03  = [[SimiRow alloc]initWithIdentifier:HOME_SPOT_CELL height:186];
            [section addObject:row03];
        }
        
        if (!(self.isDidGetBanner && self.isDidGetCategory && self.isDidGetSpotProduct)) {
            SimiRow *row04 = [[SimiRow alloc]initWithIdentifier:HOME_LOADING_CELL height:100];
            [section addObject:row04];
        }
        [_cells addObject:section];
        [tableViewHome reloadData];
    }
}

#pragma mark Set Interface
- (void)setViewCategory
{
    if (homeCategoryModelCollection.count > 0) {
        
        _viewCate01 = [[MatrixCategoryProductCellPad alloc]initWithFrame:CGRectMake(0, 0, 166, 166) isAllCate:NO];
        [_viewCate01 cusSetCateModel:[homeCategoryModelCollection objectAtIndex:0]];
        _viewCate01.delegate =self;
        
        _viewCate02 = [[MatrixCategoryProductCellPad alloc]initWithFrame:CGRectMake(175, 0, 332, 166) isAllCate:NO];
        if (homeCategoryModelCollection.count > 1) {
            [_viewCate02 cusSetCateModel:[homeCategoryModelCollection objectAtIndex:1]];
        }
        _viewCate02.delegate =self;
        
        _viewCate03 = [[MatrixCategoryProductCellPad alloc]initWithFrame:CGRectMake(516, 0, 332, 166) isAllCate:NO];
        if (homeCategoryModelCollection.count > 2) {
            [_viewCate03 cusSetCateModel:[homeCategoryModelCollection objectAtIndex:2]];
        }
        _viewCate03.delegate =self;
        
        _viewAllCate = [[MatrixCategoryProductCellPad alloc]initWithFrame:CGRectMake(857, 0, 167, 166) isAllCate:YES];
        if (homeCategoryModelCollection.count > 3) {
            [_viewAllCate cusSetCateModel:[homeCategoryModelCollection objectAtIndex:3]];
        }
        _viewAllCate.delegate =self;
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
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (self.bannerCollection.count > 0) {
                _carousel = [[iCarousel alloc]initWithFrame:CGRectMake(10, 0, 1004, 356)];
                [_carousel setBackgroundColor:[UIColor clearColor]];
                _carousel.type = iCarouselTypeCoverFlow2;
                _carousel.dataSource = self;
                _carousel.delegate = self;
                _carousel.scrollSpeed = 0.5;
                [cell addSubview:_carousel];
                
                _arrayImageBanner = [[NSMutableArray alloc]init];
                _arrayBannerModel = [[NSMutableArray alloc]init];
                for (SimiModel *model in self.bannerCollection) {
                    if (![[model valueForKey:isFake]boolValue]) {
                        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 670, 356)];
                        [imageView sd_setImageWithURL:[[model valueForKey:@"image"] valueForKey:@"url" ] placeholderImage:[UIImage imageNamed:@"logo"] options:0 progress:nil completed:nil];
                        [_arrayImageBanner addObject:imageView];
                        [_arrayBannerModel addObject:model];
                    }else
                    {
                        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 670, 356)];
                        [imageView setImage:[UIImage imageNamed:@"default_banner"]];
                        [_arrayImageBanner addObject:imageView];
                        [_arrayBannerModel addObject:model];
                    }
                }
                if (self.arrayImageBanner.count >= 3)
                    [_carousel scrollToItemAtIndex:1 animated:NO];
                [_carousel reloadData];
                if (self.bannerCollection.count == 1)
                    _carousel.scrollEnabled = NO;
            }
        } else if ([simiRow.identifier isEqualToString:HOME_CATEGORY_CELL])
        {
            [self setViewCategory];
            [cell addSubview:_viewCate01];
            [cell addSubview:_viewCate02];
            [cell addSubview:_viewCate03];
            [cell addSubview:_viewAllCate];
            [_viewCate01.slideShow start];
            [_viewCate02.slideShow start];
            [_viewCate03.slideShow start];
            [_viewAllCate.slideShow start];
        } else if ([simiRow.identifier isEqualToString:HOME_SPOT_CELL])
        {
            UIScrollView *scrViewSpot = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 9, cell.frame.size.width, 168)];
            scrViewSpot.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleWidth;
            scrViewSpot.showsHorizontalScrollIndicator = NO;
            int widthDistanceTwoCell = 9;
            float sizeCell = 167.7;
            int widthScrollViewContent = 0;
            for (int i = 0; i < spotCollection.count; i++) {
                MatrixSpotProductCellPad *spotCell = [[MatrixSpotProductCellPad alloc]initWithFrame:CGRectMake(i*(sizeCell*2 + widthDistanceTwoCell), 0, sizeCell*2, sizeCell)];
                spotCell.delegate = self;
                [spotCell cusSetSpotModel:[spotCollection objectAtIndex:i]];
                widthScrollViewContent += (sizeCell*2 + widthDistanceTwoCell);
                [spotCell.slideShow start];
                [scrViewSpot addSubview:spotCell];
            }
            
            [scrViewSpot setContentSize:CGSizeMake(widthScrollViewContent, sizeCell)];
            [scrViewSpot setBackgroundColor:[UIColor clearColor]];
            [cell addSubview:scrViewSpot];
            // Gin edit Shaker  rung image
            if( spotCollection.count > 0){
                AFViewShaker * viewShaker = [[AFViewShaker alloc] initWithView:cell];
                [viewShaker shakeWithDuration:1 completion:^{
                }];
            }
            //end
        }else if ([simiRow.identifier isEqualToString:HOME_LOADING_CELL])
        {
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
        }
    }
    return cell;
}

#pragma mark Category Delegate
- (void)didSelectCateGoryWithCateModel:(SimiCategoryModel *)cateModel
{
    SCProductListViewControllerPad *gridViewController = [[SCProductListViewControllerPad alloc]init];
    gridViewController.productListGetProductType = ProductListGetProductTypeFromCategory;
    if(cateModel != nil)
    {
        gridViewController.categoryID = [cateModel valueForKey:@"category_id"];
        gridViewController.productListGetProductType = ProductListGetProductTypeFromCategory;
        [self.navigationController pushViewController:gridViewController animated:YES];
    }
}

#pragma mark SpotProduct Delegate
- (void)didSelectedSpotProductWithSpotProductModel:(SimiModel *)spotModel
{
    SCProductListViewControllerPad *gridViewController = [[SCProductListViewControllerPad alloc]init];
    gridViewController.productListGetProductType = ProductListGetProductTypeFromSpot;
    gridViewController.spotModel = spotModel;
    [self.navigationController pushViewController:gridViewController animated:NO];
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
    if ([[NSString stringWithFormat:@"%@",[banner valueForKey:@"type"]] isEqualToString:@"2"]) {
        SCProductListViewControllerPad* nextController = [SCProductListViewControllerPad new];
        nextController.productListGetProductType = ProductListGetProductTypeFromCategory;
        nextController.categoryID = [banner valueForKey:@"category_id"];
        [self.navigationController pushViewController:nextController animated:YES];
    }else if([[NSString stringWithFormat:@"%@",[banner valueForKey:@"type"]] isEqualToString:@"1"]){
        SCProductViewControllerPad *nextController = [SCProductViewControllerPad new];
        [nextController setFirstProductID:[banner valueForKey:@"product_id"]];
        [nextController setArrayProductsID:[[NSMutableArray alloc]initWithArray:@[nextController.firstProductID]]];
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

