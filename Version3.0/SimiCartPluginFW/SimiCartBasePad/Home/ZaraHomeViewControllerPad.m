//
//  ZaraHomeViewControllerPad.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/7/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "ZaraHomeViewControllerPad.h"
#import "ZaraSection.h"
#import "SCLeftMenuViewControllerPad.h"
#import "UIImageView+WebCache.h"
#import "SCCartViewController.h"

#import "SCThemeWorker.h"


static float HEIGHTBANNER = 682;
static float WIDTH_TABLEVIEW = 1024;


@implementation ZaraHomeViewControllerPad

- (void)viewDidLoadBefore
{
    [super viewDidLoadBefore];
    [self configureLogo];
    [self configureNavigationBarOnViewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.navigationController.view addSubview:[[[SCThemeWorker sharedInstance] navigationBarPad]leftMenuPad].view];
    [self.searchBarBackground removeFromSuperview];
    [self.searchBarHome removeFromSuperview];
    [self.tableViewHome setFrame:self.view.bounds];
    [self.tableViewHome setFrame:CGRectMake(0, -32, 1024, 745)];
    self.currentSection = -1;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    ZaraSection *zThemeSection = [self.cellTables objectAtIndex:section];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH_TABLEVIEW, HEIGHTBANNER)];
    
    UIImageView *imageBanner = [[UIImageView alloc]initWithFrame:CGRectMake(10, 3,WIDTH_TABLEVIEW - 20 , HEIGHTBANNER - 12)];
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
        if([[SimiGlobalVar sharedInstance]isReverseLanguage]){
            [lblBanner setFrame:CGRectMake(SCREEN_WIDTH -  widthLabelBanner - 20,HEIGHTBANNER/2 - 6 - 10, widthLabelBanner,20)];
        }
        [view addSubview:lblBanner];
    }
    return view;
}

#pragma mark Did Get List Categories

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEIGHTBANNER;
}


#pragma mark Did Touch Banner
- (void)didTouchBanner:(id)sender
{
    UIButton *btnBanner = (UIButton *)sender;
    int currentSection = (int)btnBanner.tag;
    ZaraSection *zThemeSection = [self.cellTables objectAtIndex:currentSection];
    if ([zThemeSection.zThemeSectionContent valueForKey:isFake]) {
        return;
    }
    if (zThemeSection.hasChild) {
        SimiCategoryModelCollection * categoryModelCollection = [[SimiCategoryModelCollection alloc] init];
        SimiCategoryModel * rootCategoryModel = [[SimiCategoryModel alloc]init];
        [rootCategoryModel setObject:zThemeSection.identifier forKey:@"category_id"];
        [rootCategoryModel setObject:@"NO" forKey:@"hasChild"];
        [rootCategoryModel setObject:@"All products" forKey:@"name"];
        [categoryModelCollection addObject:rootCategoryModel];
        
        for (NSDictionary * category in (NSArray *)[zThemeSection.zThemeSectionContent objectForKey:@"children_cat"]) {
            SimiCategoryModel * categoryModel = [[SimiCategoryModel alloc]initWithDictionary:category];
            [categoryModelCollection addObject:categoryModel];
        }
        SCLeftMenuViewControllerPad * leftMenu = [[[SCThemeWorker sharedInstance] navigationBarPad]leftMenuPad];
        [leftMenu didClickShow];
        [leftMenu showCategory];
        [leftMenu updateCategoryWithModel:categoryModelCollection categoryId:zThemeSection.identifier categoryName:[zThemeSection.zThemeSectionContent objectForKey:@"category_name"]];
        
    }else
    {
        SCProductListViewControllerPad *productListViewController = [SCProductListViewControllerPad new];
        if ([[zThemeSection.zThemeSectionContent valueForKey:@"ztype"] isEqualToString:@"cat"]) {
            productListViewController.productListGetProductType = ProductListGetProductTypeFromCategory;
            productListViewController.categoryID = zThemeSection.identifier;
        }else if([[zThemeSection.zThemeSectionContent valueForKey:@"ztype"] isEqualToString:@"spot"])
        {
            productListViewController.productListGetProductType = ProductListGetProductTypeFromSpot;
            productListViewController.spotModel = zThemeSection.zThemeSectionContent;
        }
        
        [self.navigationController pushViewController:productListViewController animated:YES];
    }
    if (currentSection == self.currentSection)
        self.currentSection = -1;
    else
        self.currentSection = currentSection;
}

@end
