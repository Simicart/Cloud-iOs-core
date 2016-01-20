//
//  SCProductListViewControllerPad.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/18/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SCProductListViewControllerPad.h"
#import "SCProductCollectionViewControllerPad.h"
#import "SCProductViewControllerPad.h"
#import "SimiCacheData.h"

@interface SCProductListViewControllerPad ()
@property (nonatomic, strong) NSString *keyCacheData;
@end

@implementation SCProductListViewControllerPad
@synthesize viewToolBar;
- (void)viewDidLoadBefore
{
    [self configureNavigationBarOnViewDidLoad];
    [self configureLogo];
    
    [self setToSimiView];
    paddingBottom = 40;
    paddingTop = 50;
    
    UICollectionViewLayout* layOut = [[UICollectionViewLayout alloc] init];
    _productCollectionViewControllerPad = [[SCProductCollectionViewControllerPad alloc]initWithCollectionViewLayout:layOut];
    _productCollectionViewControllerPad.delegate = self;
    [_productCollectionViewControllerPad.collectionView setFrame:self.view.frame];
    _productCollectionViewControllerPad.collectionGetProductType = self.productListGetProductType;
    if(self.spotModel){
        _productCollectionViewControllerPad.spotModel = self.spotModel;
    }
    if (self.categoryID) {
        _productCollectionViewControllerPad.categoryID = self.categoryID;
    }
    if (self.keySearchProduct) {
        _productCollectionViewControllerPad.keySearchProduct = self.keySearchProduct;
    }
    [self.view addSubview:_productCollectionViewControllerPad.collectionView];
    [self.view addSubview:self.viewToolBar];
    [self.viewToolBar setHidden:YES];
    
    self.lastContentOffset = 0;
    self.sortType = ProductCollectionSortNone;
    self.maxNumberProduct = 1000;
    self.isProductShowGrid = YES;
#pragma Set key cache Data
    
    switch (self.productListGetProductType) {
        case ProductListGetProductTypeFromCategory:
        {
            if (self.categoryID == nil || [self.categoryID isEqualToString:@""]) {
                self.keyCacheData = @"all";
            }else
            {
                self.keyCacheData = self.categoryID;
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
    if ([[SimiCacheData sharedInstance].dataListProducts valueForKey:self.keyCacheData]) {
        self.productCollectionViewControllerPad.productCollection = [[SimiProductModelCollection alloc]initWithArray:[[SimiCacheData sharedInstance].dataListProducts valueForKey:self.keyCacheData]];
        if ([[[SimiCacheData sharedInstance].dataListProductIDs valueForKey:self.keyCacheData] isKindOfClass:[NSArray class]]) {
            self.productCollectionViewControllerPad.arrayProductID = [[NSMutableArray alloc]initWithArray:[[SimiCacheData sharedInstance].dataListProductIDs valueForKey:self.keyCacheData]];
        }
        [self.productCollectionViewControllerPad.collectionView reloadData];
        [self.viewToolBar setHidden:NO];
    }
    if (_productCollectionViewControllerPad.productCollection == nil || _productCollectionViewControllerPad.productCollection.count == 0) {
        [_productCollectionViewControllerPad getProducts];
        self.isFirstTimeGetData = YES;
    }
}

- (UIView *)viewToolBar
{
    if (viewToolBar == nil) {
        CGRect frame = CGRectZero;
        frame.size.width = SCREEN_WIDTH;
        frame.size.height = [SimiGlobalVar scaleValue:paddingTop];
        frame.origin.y = 0;
        float buttonWidth = 65;
        float buttonHeight = frame.size.height;
        float iconSize = 25;
        viewToolBar = [[UIView alloc]initWithFrame:frame];
        [viewToolBar setBackgroundColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#efefef"]];
        viewToolBar.clipsToBounds = YES;
        
        self.btnSort = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - buttonWidth, 0, buttonWidth, buttonHeight)];
        [self.btnSort setImageEdgeInsets:UIEdgeInsetsMake((buttonHeight - iconSize)/2, (buttonWidth - iconSize)/2, (buttonHeight - iconSize)/2, (buttonWidth - iconSize)/2)];
        [self.btnSort setImage:[UIImage imageNamed:@"ic_sort"] forState:UIControlStateNormal];
        [self.btnSort addTarget:self action:@selector(refine:)forControlEvents:UIControlEventTouchUpInside];
        [viewToolBar addSubview:self.btnSort];
        
        self.btnFilter = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
        [self.btnFilter setImageEdgeInsets:UIEdgeInsetsMake((buttonHeight - iconSize)/2, (buttonWidth - iconSize)/2, (buttonHeight - iconSize)/2, (buttonWidth - iconSize)/2)];
        [self.btnFilter setImage:[UIImage imageNamed:@"ic_filter"] forState:UIControlStateNormal];
        [self.btnFilter addTarget:self action:@selector(filter:)forControlEvents:UIControlEventTouchUpInside];
        [self.btnFilter setHidden:YES];
        [viewToolBar addSubview:self.btnFilter];
        
        self.numberProductLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2 - buttonWidth, 0, buttonWidth * 2, buttonHeight)];
        [self.numberProductLabel setTextAlignment:NSTextAlignmentCenter];
        [self.numberProductLabel setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:18]];
        [self.numberProductLabel setTextColor:THEME_CONTENT_COLOR];
        [viewToolBar addSubview:self.numberProductLabel];
        [self.numberProductLabel setHidden:YES];
    }
    return viewToolBar;
}
#pragma Collection Delegate
- (void)startGetProductModelCollection
{
   
}
- (void)didGetProductModelCollection:(NSDictionary*)layerNavigation
{
    [self.viewToolBar setHidden:NO];
    if (self.isFirstTimeGetData && self.productListGetProductType != ProductListGetProductTypeFromSearch) {
        self.isFirstTimeGetData = NO;
        [[SimiCacheData sharedInstance].dataListProducts setObject:self.productCollectionViewControllerPad.productCollection forKey:self.keyCacheData];
        if (self.productCollectionViewControllerPad.arrayProductID) {            
            [[SimiCacheData sharedInstance].dataListProductIDs setObject:self.productCollectionViewControllerPad.arrayProductID forKey:self.keyCacheData];
        }
    }
}

- (void)selectedProduct:(NSString*)productID_
{
    SCProductViewControllerPad *productViewController = [SCProductViewControllerPad new];
    productViewController.arrayProductsID = self.productCollectionViewControllerPad.arrayProductID;
    productViewController.firstProductID = productID_;
    [self.navigationController pushViewController:productViewController animated:YES];
}
- (void)numberProductChange:(int)numberProduct
{
    [self.numberProductLabel setText:[NSString stringWithFormat:@"%d %@(s)", numberProduct, SCLocalizedString(@"Product")]];
    [self.numberProductLabel setHidden:NO];
}

- (void)setHideViewToolBar:(BOOL)isHide
{
    if (isHide) {
        CGRect frame = viewToolBar.frame;
        frame.size.height = 0;
        [UIView animateWithDuration:0.3 animations:^{
            [viewToolBar setFrame:frame];
        } completion:^(BOOL finished) {
        }];
    }else
    {
        CGRect frame = viewToolBar.frame;
        frame.size.height = [SimiGlobalVar scaleValue:paddingTop];
        [UIView animateWithDuration:0.3 animations:^{
            [viewToolBar setFrame:frame];
        } completion:^(BOOL finished) {
        }];
    }
}
#pragma mark Action
- (void)refine:(id)sender{
    UIButton* senderButton = (UIButton*)sender;
    
    SCRefineViewController *nextController = [[SCRefineViewController alloc]init];
    [nextController setSortType:self.sortType];
    nextController.delegate = self;
    
    if (_popController == nil) {
        //The color picker popover is not showing. Show it.
        _popController = [[UIPopoverController alloc] initWithContentViewController:nextController];
        if(SIMI_SYSTEM_IOS >= 7.0)
            [_popController setBackgroundColor:THEME_APP_BACKGROUND_COLOR];
        [_popController setDelegate:self];
        [_popController presentPopoverFromRect:senderButton.bounds inView:senderButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    } else {
        //The color picker popover is showing. Hide it.
        [_popController dismissPopoverAnimated:YES];
        _popController = nil;
    }
}

- (void)filter:(id)sender
{
    UIButton* senderButton = (UIButton*)sender;
    if (_popController == nil) {
        _popController = [[UIPopoverController alloc]initWithContentViewController:self.filterViewController];
        _popController.delegate = self;
        if (SIMI_SYSTEM_IOS > 7.0){
            [_popController setBackgroundColor:THEME_APP_BACKGROUND_COLOR];
        }
        [_popController presentPopoverFromRect:senderButton.bounds inView:senderButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }else
    {
        [_popController dismissPopoverAnimated:YES];
        _popController = nil;
    }
}

#pragma mark UIPopover Controller Delegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    _popController = nil;
}

#pragma mark Filter Delegate
- (void)filterWithParam:(NSMutableDictionary *)param
{
    [_popController dismissPopoverAnimated:YES];
    [self.productCollectionViewControllerPad setFilterParam:param];
    [self.productCollectionViewControllerPad.productCollection removeAllObjects];
    [self.productCollectionViewControllerPad.collectionView reloadData];
    [self.productCollectionViewControllerPad getProducts];
}

#pragma mark Refine
- (void)didRefineWithSortType:(ProductCollectionSortType)type{
    [_popController dismissPopoverAnimated:YES];
    if (type != self.sortType) {
        self.sortType = type;
        self.productCollectionViewControllerPad.sortType = type;
        [self.productCollectionViewControllerPad.productCollection removeAllObjects];
        [self.productCollectionViewControllerPad.collectionView reloadData];
        [self.productCollectionViewControllerPad getProducts];
    }
}
@end
