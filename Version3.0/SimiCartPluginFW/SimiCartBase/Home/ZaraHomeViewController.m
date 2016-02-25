//
//  ZThemeHomeViewController.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 4/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZaraHomeViewController.h"
#import "UIImageView+WebCache.h"
#import "SCThemeWorker.h"

@interface ZaraHomeViewController ()

@end

@implementation ZaraHomeViewController
{
    float HEIGHTBANNER, WIDTH_TABLEVIEW;
}

@synthesize tableViewHome, searchBarHome, searchBarBackground, homeCategoryModelCollection, spotCollection;

#pragma mark Main Method
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
    
    HEIGHTBANNER = [SimiGlobalVar scaleValue:218];
    WIDTH_TABLEVIEW = SCREEN_WIDTH;
    
    CGRect frame = self.view.frame;
    tableViewHome = [[SimiTableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    tableViewHome.dataSource = self;
    tableViewHome.delegate = self;
    [tableViewHome setBackgroundColor:[UIColor clearColor]];
    [tableViewHome setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    tableViewHome.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tableViewHome.showsVerticalScrollIndicator = NO;
    [tableViewHome setContentInset:UIEdgeInsetsMake([SimiGlobalVar scaleValue:38], 0, 0, 0)];
    [self.view addSubview:tableViewHome];
    
    searchBarHome = [[UISearchBar alloc] initWithFrame:[SimiGlobalVar scaleFrame:CGRectMake(5, 5, 310, 28)]];
    searchBarHome.tintColor = THEME_SEARCH_TEXT_COLOR;
    searchBarHome.searchBarStyle = UIBarStyleBlackTranslucent;
    searchBarHome.placeholder = SCLocalizedString(@"Search on All Products");
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
    [searchBarBackground setAlpha:0.9f];
    [self.view addSubview:searchBarBackground];
    [self.view addSubview:searchBarHome];
    
    [self getHomeCategories];
    [self getSpotCollection];
    [tableViewHome setHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationWillResignActive" object:nil];
    [self startLoadingData];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self.navigationController.view addSubview:[[[SCThemeWorker sharedInstance] navigationBarPhone]leftMenuPhone].view];
    [tableViewHome setFrame:self.view.bounds];
}

#pragma mark Did Get List Categories
-(void)getHomeCategories
{
    if(homeCategoryModelCollection == nil)
        homeCategoryModelCollection = [SimiCategoryModelCollection new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:DidGetHomeCategories object:homeCategoryModelCollection];
    [homeCategoryModelCollection getHomeDefaultCategories];
}
-(void)getSpotCollection{
    if(spotCollection == nil)
        spotCollection = [SimiSpotModelCollection new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:DidGetSpotCollection object:self.spotCollection];
    [spotCollection getSpotCollection];
}


-(void) didReceiveNotification:(NSNotification *)noti{
    [[NSNotificationCenter defaultCenter]removeObserverForNotification:noti];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    [self stopLoadingData];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        if([noti.name isEqualToString:DidGetHomeCategories]){
            if(homeCategoryModelCollection.count > 0){
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:DidGetCategoryCollection object:nil];
                for(SimiCategoryModel *cateModel in homeCategoryModelCollection){
                    if ([[cateModel valueForKey:@"has_children"]boolValue]) {                        
                        NSString* categoryId = [cateModel valueForKey:@"category_id"];
                        SimiCategoryModelCollection* categoryCollection = [SimiCategoryModelCollection new];
                        NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
                        [params setValue:@"50" forKey:@"limit"];
                        [params setValue:@"0" forKey:@"offset"];
                        if(categoryId && ![categoryId isEqualToString:@""])
                            [params setValue:categoryId forKey:@"filter[parent]"];
                        else
                            [params setValue:@"0" forKey:@"filter[parent][exists]"];
                        categoryCollection.parentCategoryId = categoryId;
                        [categoryCollection getCategoryCollectionWithParentId:categoryId params:params];
                    }
                }
            }
        }else if([noti.name isEqualToString:DidGetSpotCollection]){
            
        }else if([noti.name isEqualToString:DidGetCategoryCollection]){
            SimiCategoryModelCollection* categoryCollection = noti.object;
            for(SimiModel* categoryModel in homeCategoryModelCollection){
                if([[NSString stringWithFormat:@"%@",[categoryModel valueForKey:@"category_id"] ]isEqualToString:[NSString stringWithFormat:@"%@",categoryCollection.parentCategoryId]]){
                    [categoryModel addData:@{@"children_cat":categoryCollection}];
                    break;
                }
            }
        }
        [self setCellTables:nil];
        [tableViewHome setHidden:NO];
    }
}

#pragma mark Set Cells
- (void)setCellTables:(SimiTable *)cellTables
{
    if (cellTables) {
        _cellTables = cellTables;
    }else
    {
        _cellTables = [[SimiTable alloc]init];
        if (homeCategoryModelCollection.count > 0) {
            for (int i = 0; i < homeCategoryModelCollection.count; i++) {
                SimiModel *homeModel = [homeCategoryModelCollection objectAtIndex:i];
                [homeModel setValue:@"cat" forKey:@"type"];
                ZaraHomeViewSection *section = [[ZaraHomeViewSection alloc]initWithHeaderTitle:[homeModel valueForKey:@"name"] footerTitle:@""];
                section.identifier = [NSString stringWithFormat:@"%@",[homeModel valueForKey:@"category_id"]];
                section.isSelected = NO;
                section.hasChild = [[homeModel valueForKey:@"has_children"] boolValue];
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                    if ([homeModel valueForKey:@"phone_image"] && [[homeModel valueForKey:@"phone_image"]isKindOfClass:[NSDictionary class]]) {
                        section.bannerCategoryURL = [[homeModel valueForKey:@"phone_image"] valueForKey:@"url"];
                    }
                }else
                {
                    if ([homeModel valueForKey:@"tablet_image"] && [[homeModel valueForKey:@"tablet_image"]isKindOfClass:[NSDictionary class]]) {
                        section.bannerCategoryURL = [[homeModel valueForKey:@"tablet_image"] valueForKey:@"url"];
                    }
                }
                section.zThemeSectionContent = homeModel;
                if (section.hasChild) {
                    NSMutableArray *listCateChild = [[NSMutableArray alloc]initWithArray:[homeModel valueForKey:@"children_cat"]];
                    if (listCateChild.count > 0) {
                        ZaraHomeViewRow *simiRow = [[ZaraHomeViewRow alloc]initWithIdentifier:section.identifier  height:44];
                        simiRow.hasChild = NO;
                        simiRow.zThemeContentRow = [[NSMutableDictionary alloc]initWithDictionary:section.zThemeSectionContent];
                        [simiRow.zThemeContentRow setValue:SCLocalizedString(@"All products") forKey:@"name"];
                        [section addObject:simiRow];
                    }
                    for (int j = 0; j < listCateChild.count; j++) {
                        NSDictionary *cateChild = [listCateChild objectAtIndex:j];
                        ZaraHomeViewRow *simiRow = [[ZaraHomeViewRow alloc]initWithIdentifier:[cateChild valueForKey:@"_id"] height:44];
                        simiRow.hasChild = [[cateChild valueForKey:@"has_children"]boolValue];
                        simiRow.zThemeContentRow = [[NSMutableDictionary alloc]initWithDictionary: cateChild];
                        [section addObject:simiRow];
                    
                    }
                }
                [_cellTables addObject:section];
            }
        }
        if (spotCollection.count > 0) {            
            for (int i = 0; i < spotCollection.count; i++) {
                SimiModel *homeModel = [spotCollection objectAtIndex:i];
                [homeModel setValue:@"spot" forKey:@"type"];
                ZaraHomeViewSection *section = [[ZaraHomeViewSection alloc]initWithHeaderTitle:[homeModel valueForKey:@"name"] footerTitle:@""];
                section.identifier = [NSString stringWithFormat:@"%@",[homeModel valueForKey:@"_id"]];
                section.isSelected = NO;
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                    section.bannerCategoryURL = [[homeModel valueForKey:@"phone_image"] valueForKey:@"url"];
                }else
                    section.bannerCategoryURL = [[homeModel valueForKey:@"tablet_image"] valueForKey:@"url"];
                section.zThemeSectionContent = homeModel;
                [_cellTables addObject:section];
            }
        }
        [tableViewHome reloadData];
    }
}
#pragma mark Table View DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _cellTables.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    ZaraHomeViewSection *simiSection = [_cellTables objectAtIndex:section];
    return simiSection.isSelected?simiSection.count:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZaraHomeViewSection *zThemeSection = [_cellTables objectAtIndex:indexPath.section];
    ZaraHomeViewRow *zThemeRow = (ZaraHomeViewRow*)[zThemeSection objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELLDETAIL"];
    if (cell == nil) {
        cell = [UITableViewCell new];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    [cell.textLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
    [cell.textLabel setText:[zThemeRow.zThemeContentRow valueForKey:@"name"]];
    //  Liam Update RTL
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        [cell.textLabel setTextAlignment:NSTextAlignmentRight];
    }
    //  End RTL
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZaraHomeViewSection *simiSection = [_cellTables objectAtIndex:indexPath.section];
    ZaraHomeViewRow *simiRow = (ZaraHomeViewRow*)[simiSection objectAtIndex:indexPath.row];
    return simiRow.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEIGHTBANNER;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    ZaraHomeViewSection *zThemeSection = [_cellTables objectAtIndex:section];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH_TABLEVIEW, HEIGHTBANNER)];
    UIImageView *imageBanner = [[UIImageView alloc]initWithFrame:CGRectMake(6, 3,WIDTH_TABLEVIEW - 12 , HEIGHTBANNER - 6)];
    if ([zThemeSection.zThemeSectionContent valueForKey:isFake]) {
        [imageBanner setImage:[UIImage imageNamed:@"zara_banner"]];
    }else
        [imageBanner sd_setImageWithURL:[NSURL URLWithString:zThemeSection.bannerCategoryURL] placeholderImage:[UIImage imageNamed:@"logo"]];
    imageBanner.contentMode = UIViewContentModeScaleAspectFit;
    
    UIButton *btnBanner = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBanner setFrame:imageBanner.bounds];
    [btnBanner setBackgroundColor:[UIColor clearColor]];
    [btnBanner addTarget:self action:@selector(didTouchBanner:) forControlEvents:UIControlEventTouchUpInside];
    [btnBanner setTag:section];
    
    [view addSubview:imageBanner];
    [view addSubview:btnBanner];
    NSString *bannerTitle = [NSString stringWithFormat:@"%@",[zThemeSection.zThemeSectionContent valueForKey:@"name"]];
    if (![bannerTitle isEqualToString:@""]) {
        UILabel *lblBanner = [[UILabel alloc]initWithFrame:CGRectMake(20,HEIGHTBANNER/2 - 6 - 10, 100,20)];
        [lblBanner setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:12]];
        [lblBanner setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.7]];
        [lblBanner setText:bannerTitle];
        [lblBanner setTextAlignment:NSTextAlignmentCenter];
        float widthLabelBanner = [[lblBanner text] sizeWithAttributes:@{NSFontAttributeName:[lblBanner font]}].width;
        CGRect frame = lblBanner.frame;
        frame.size.width = widthLabelBanner + 6;
        [lblBanner setFrame:frame];
        //Gin edit
        if([[SimiGlobalVar sharedInstance]isReverseLanguage]){
            [lblBanner setFrame:CGRectMake(SCREEN_WIDTH -  widthLabelBanner - 20,HEIGHTBANNER/2 - 6 - 10, widthLabelBanner,20)];
        }
        //end
        [view addSubview:lblBanner];
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZaraHomeViewSection *zThemeSection = [_cellTables objectAtIndex:indexPath.section];
    ZaraHomeViewRow *zThemeRow = (ZaraHomeViewRow*)[zThemeSection objectAtIndex:indexPath.row];
    if (zThemeRow.hasChild) {
        SCCategoryViewController *categoryViewController = [SCCategoryViewController new];
        categoryViewController.navigationItem.title = [zThemeRow.zThemeContentRow valueForKey:@"catefory_name"];
        categoryViewController.categoryId = zThemeRow.identifier;
        categoryViewController.categoryRealName = [zThemeRow.zThemeContentRow valueForKey:@"category_name"];
        [self.navigationController pushViewController:categoryViewController animated:YES];
    }else
    {
        SCProductListViewController *productListViewController = [SCProductListViewController new];
        productListViewController.productListGetProductType = ProductListGetProductTypeFromCategory;
        productListViewController.categoryID = zThemeRow.identifier;
        if ([zThemeRow.zThemeContentRow valueForKey:@"category_real_name"]) {
            productListViewController.categoryName = [zThemeRow.zThemeContentRow valueForKey:@"category_real_name"];
        }else
            productListViewController.categoryName = [zThemeRow.zThemeContentRow valueForKey:@"category_name"];
        [self.navigationController pushViewController:productListViewController animated:YES];
    }
}

#pragma mark Did Touch Banner
- (void)didTouchBanner:(id)sender
{
    UIButton *btnBanner = (UIButton *)sender;
    int currentSection = (int)btnBanner.tag;
    ZaraHomeViewSection *zThemeSection = [_cellTables objectAtIndex:currentSection];
    if ([zThemeSection.zThemeSectionContent valueForKey:isFake]) {
        return;
    }
    // Change other section to unselect
    for (int i = 0; i < _cellTables.count; i++) {
        if (i != currentSection) {
            ZaraHomeViewSection *section = [_cellTables objectAtIndex:i];
            section.isSelected = NO;
        }
    }
    
    if (self.currentRowsAllow.count > 0) {
        NSIndexPath *indexPath = [self.currentRowsAllow objectAtIndex:0];
        if (indexPath.section != currentSection) {
            [self.tableViewHome beginUpdates];
            [self.tableViewHome deleteRowsAtIndexPaths:self.currentRowsAllow withRowAnimation:UITableViewRowAnimationFade];
            [self.tableViewHome endUpdates];
            [self.currentRowsAllow removeAllObjects];
        }
    }
    if (zThemeSection.hasChild) {
        //  if section has childs, it will be showed childs category
        zThemeSection.isSelected = !zThemeSection.isSelected;
        if (zThemeSection.isSelected) {
            self.currentRowsAllow = [NSMutableArray new];
            for (int i = 0; i < zThemeSection.count; i++) {
                NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:currentSection];
                [self.currentRowsAllow addObject:path];
            }
            [self.tableViewHome beginUpdates];
            [self.tableViewHome insertRowsAtIndexPaths:self.currentRowsAllow withRowAnimation:UITableViewRowAnimationFade];
            [self.tableViewHome endUpdates];
        }else
        {
            if (self.currentRowsAllow.count > 0) {
                [self.tableViewHome beginUpdates];
                [self.tableViewHome deleteRowsAtIndexPaths:self.currentRowsAllow withRowAnimation:UITableViewRowAnimationFade];
                [self.tableViewHome endUpdates];
                [self.currentRowsAllow removeAllObjects];
            }
        }
        [self.tableViewHome setContentOffset:CGPointMake(0, currentSection*HEIGHTBANNER - 39) animated:YES];
    }else
    {
        //  if section hasn't no child, it will be redirect list product screen
        SCProductListViewController *productListViewController = [SCProductListViewController new];
        if ([[zThemeSection.zThemeSectionContent valueForKey:@"type"] isEqualToString:@"cat"]) {
            productListViewController.productListGetProductType = ProductListGetProductTypeFromCategory;
            productListViewController.categoryID = zThemeSection.identifier;
        }else
        {
            productListViewController.productListGetProductType = ProductListGetProductTypeFromSpot;
            productListViewController.spotModel = zThemeSection.zThemeSectionContent;
        }
        
        [self.navigationController pushViewController:productListViewController animated:YES];
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
{
    [searchBarHome resignFirstResponder];
    [_imageFog removeFromSuperview];
    searchBarHome.text = @"";
}


@end
