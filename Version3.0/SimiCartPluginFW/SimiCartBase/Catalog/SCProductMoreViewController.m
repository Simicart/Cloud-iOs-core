//
//  SCProductMoreViewController.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/13/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SCProductMoreViewController.h"
#import "SCProductReviewController.h"
#import "NSString+HTML.h"
#import "SCProductRelateViewController.h"
#import "SCProductViewController.h"
#import "AFViewShaker.h"

@implementation MoreActionView

@end


@interface SCProductMoreViewController ()
{
    float paddingRightBottom;
    float sizeButton;
    float moreButtonOrgionX;
    float moreButtonOrgionY;
    float sizePlus;
    float paddingIcon;
    float widthMoreView;
}

@end

@implementation SCProductMoreViewController


-(void) viewDidAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SCProductMoreViewController-viewDidAppear" object:nil];
}

-(void) viewDidDisappear:(BOOL)animated{
[[NSNotificationCenter defaultCenter] postNotificationName:@"SCProductMoreViewController-viewDidDisappear" object:nil];
}

- (void)viewDidLoadBefore
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SCProductViewMoreController-ViewDidLoadBefore" object:nil];
    paddingRightBottom = 15;
    paddingIcon = 20;
    sizeButton = 50;
    moreButtonOrgionX = SCREEN_WIDTH - paddingRightBottom - sizeButton;
    moreButtonOrgionY = SCREEN_HEIGHT - paddingRightBottom - sizeButton -  64;
    sizePlus = 18;
    widthMoreView = sizeButton + 2 *paddingRightBottom;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        moreButtonOrgionX = SCREEN_WIDTH *2/3- paddingRightBottom - sizeButton;
        moreButtonOrgionY = SCREEN_HEIGHT *2/3 - paddingRightBottom - sizeButton;
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewDidLoadBefore];
    }else
        [super configureNavigationBarOnViewDidLoad];
    [self initPageScrollView];
    [self initBasicInfoTab];
    [self initDescriptionTab];
//    [self initTechSpecTab];
//    [self initReviewTab];
    [self initRelatedProductTab];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SCProductMoreViewController_InitTab" object:self userInfo:@{@"PageScrollView":_pageScrollView}];
    [self.view addSubview:_pageScrollView];
    [_pageScrollView generate];
    [self initMoreViewAction];
}

- (void)initPageScrollView
{
    _pageScrollView = [[LazyPageScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT -  64)];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [_pageScrollView setFrame:CGRectMake(0, 0, SCREEN_WIDTH *2/3, SCREEN_HEIGHT *2/3)];
    }
    [_pageScrollView setDelegate:self];
    [_pageScrollView initTab:NO Gap:50 TabHeight:40 VerticalDistance:5 BkColor:THEME_SECTION_COLOR];
    [_pageScrollView enableTabBottomLine:YES LineHeight:3 LineColor:THEME_LINE_COLOR LineBottomGap:0 ExtraWidth:10];
    [_pageScrollView setTitleStyle:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:20] Color:THEME_CONTENT_COLOR SelColor:THEME_COLOR];
    [_pageScrollView enableBreakLine:NO Width:1 TopMargin:0 BottomMargin:0 Color:THEME_CONTENT_COLOR];
    _pageScrollView.leftTopView = [[UIView alloc]initWithFrame:CGRectZero];
    _pageScrollView.rightTopView = [[UIView alloc]initWithFrame:CGRectZero];
    [_pageScrollView setBackgroundColor:THEME_APP_BACKGROUND_COLOR];
    // Gin edit Shaker  rung image
    AFViewShaker * viewShaker = [[AFViewShaker alloc] initWithView:[_pageScrollView getTopContentView]];
    [viewShaker shakeWithDuration:1 completion:^{}];
    //end
}

- (void)initBasicInfoTab
{
    float widthBasicInfoTab = CGRectGetWidth(self.pageScrollView.frame) - 20;
    UIScrollView *scrollView = [[UIScrollView alloc]init];
    SCProductInfoView *productInfoView = [[SCProductInfoView alloc]init];
    productInfoView.isDetailInfo = YES;
    productInfoView.variants = self.variants;
    productInfoView.variantSelectedKey = self.variantSelectedKey;
    [productInfoView setProduct:self.productModel];
    productInfoView.userInteractionEnabled = YES;
    productInfoView.frame = CGRectMake(0, 0, widthBasicInfoTab, productInfoView.heightCell);
    scrollView.frame = productInfoView.frame;
    scrollView.contentSize = CGSizeMake(CGRectGetWidth(scrollView.frame), productInfoView.heightCell+230);
    [scrollView addSubview:productInfoView];
    [_pageScrollView addTab:SCLocalizedString(@"Basic Info") View:scrollView Info:nil];
}


- (void)initDescriptionTab
{
    if ([[self.productModel valueForKeyPath:@"description"] length] > 0) {
        CGRect frame = _pageScrollView.frame;
        UIWebView *webView = [[UIWebView alloc] initWithFrame:frame];
        [webView loadHTMLString:[NSString stringWithFormat:@"<span style=\"font-family: %@; font-size: %i\">%@</span>",
                                 @"ProximaNova-Light", 16,[self.productModel valueForKeyPath:@"description"]] baseURL:nil];
        webView.contentMode = UIViewContentModeScaleAspectFit;
        webView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_pageScrollView addTab:SCLocalizedString(@"Description") View:webView Info:nil];
    }
}

- (void)initTechSpecTab
{
    // Product Techs Spec
    if ([[self.productModel valueForKeyPath:@"attributes"] count] > 0) {
        CGRect frame = _pageScrollView.frame;
        UIWebView *webView = [[UIWebView alloc] initWithFrame:frame];
        [webView loadHTMLString:[NSString stringWithFormat:@"<body style=\"font-family: %@; font-size: %i\">%@</body>",
                                 @"ProximaNova-Light", 16,[self convertToHTMLString:[self.productModel valueForKeyPath:@"attributes"]]] baseURL:nil];
        
        webView.contentMode = UIViewContentModeScaleAspectFit;
        webView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_pageScrollView addTab:SCLocalizedString(@"Tech Specs") View:webView Info:nil];
    }
}

- (void)initReviewTab
{
    //  Product Review
    if ([[self.productModel valueForKey:@"reviews"] count] > 0) {
        SCProductReviewController *reviewDetailController = [SCProductReviewController new];
        reviewDetailController.delegate = self;
        [self addChildViewController:reviewDetailController];
        reviewDetailController.product = self.productModel;
        [_pageScrollView addTab:SCLocalizedString(@"Review") View:reviewDetailController.view Info:nil];
    }
}

- (void)initRelatedProductTab
{
    // Relate Products
    if ([self.productModel valueForKey:@"related_products"] && [[self.productModel valueForKey:@"related_products"] isKindOfClass:[NSArray class]]) {
        NSMutableArray *arrayRelateds = [[NSMutableArray alloc]initWithArray:[self.productModel valueForKey:@"related_products"]];
        NSString *stringIds = @"";
        for (int j = 0; j < arrayRelateds.count; j++) {
            if (j!= 0) {
                stringIds = [NSString stringWithFormat:@"%@,%@",stringIds,[[arrayRelateds objectAtIndex:j] valueForKey:@"_id"]];
            }else
                stringIds = [NSString stringWithFormat:@"%@",[[arrayRelateds objectAtIndex:j] valueForKey:@"_id"]];
        }
        if (arrayRelateds.count > 0) {
            SCProductRelateViewController *relateViewController = [SCProductRelateViewController new];
            relateViewController.relateProductCollection = [self.productModel valueForKey:@"related_products"];
            relateViewController.productListGetProductType = ProductListGetProductTypeFromRelateProduct;
            relateViewController.stringIds = stringIds;
            relateViewController.delegate = self;
            [self addChildViewController:relateViewController];
            [_pageScrollView addTab:SCLocalizedString(@"Related Products") View:relateViewController.view Info:nil];
        }
        
    }
}

- (void)initMoreViewAction
{
    _buttonMoreAction = [[UIButton alloc]initWithFrame:CGRectMake(moreButtonOrgionX, moreButtonOrgionY, sizeButton, sizeButton)];
    [_buttonMoreAction addTarget:self action:@selector(didTouchMoreAction) forControlEvents:UIControlEventTouchUpInside];
    [_buttonMoreAction setBackgroundColor:THEME_COLOR];
    [_buttonMoreAction.layer setCornerRadius:sizeButton/2.0f];
    [_buttonMoreAction.layer setShadowOffset:CGSizeMake(1, 1)];
    [_buttonMoreAction.layer setShadowRadius:2];
    _buttonMoreAction.layer.shadowOpacity = 0.5;
    [_buttonMoreAction setImage:[UIImage imageNamed:@"ic_cong"] forState:UIControlStateNormal];
    [_buttonMoreAction setImageEdgeInsets:UIEdgeInsetsMake((sizeButton - sizePlus)/2, (sizeButton - sizePlus)/2, (sizeButton - sizePlus)/2, (sizeButton - sizePlus)/2)];
    
    CGRect frame = _buttonMoreAction.frame;
    frame.size.height = 0;
    frame.size.width += paddingRightBottom *2;
    frame.origin.x -=  paddingRightBottom;
    
    _viewMoreAction = [[MoreActionView alloc]initWithFrame:frame];
    [_viewMoreAction setBackgroundColor:[UIColor clearColor]];
    _viewMoreAction.arrayIcon = [NSMutableArray new];
    _viewMoreAction.clipsToBounds = YES;
    
    _buttonShare = [UIButton new];
    [_buttonShare setImage:[UIImage imageNamed:@"ic_share"] forState:UIControlStateNormal];
    [_buttonShare setImageEdgeInsets:UIEdgeInsetsMake(9, 9, 9, 9)];
    [_buttonShare.layer setCornerRadius:sizeButton/2.0f];
    [_buttonShare.layer setShadowOffset:CGSizeMake(1, 1)];
    [_buttonShare.layer setShadowRadius:2];
    _buttonShare.layer.shadowOpacity = 0.5;
    [_buttonShare setBackgroundColor:THEME_APP_BACKGROUND_COLOR];
    [_buttonShare addTarget:self action:@selector(didTouchShare) forControlEvents:UIControlEventTouchUpInside];
    _viewMoreAction.numberIcon += 1;
    [_viewMoreAction.arrayIcon addObject:_buttonShare];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SCProductMoreViewController_InitViewMoreAction" object:_viewMoreAction];
    _viewMoreAction.heightMoreView = (paddingIcon + sizeButton) * (_viewMoreAction.arrayIcon.count) + paddingIcon;
    if (_viewMoreAction.arrayIcon.count > 0) {
        [self setInterFaceViewMore];
        [self.view addSubview:_viewMoreAction];
        [self.view addSubview:_buttonMoreAction];
    }
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewWillAppearBefore:YES];
    }
}

- (void)setInterFaceViewMore
{
    for (int i = 0; i < _viewMoreAction.arrayIcon.count; i++) {
        UIButton *button = (UIButton*)[_viewMoreAction.arrayIcon objectAtIndex:i];
        [button setFrame:CGRectMake(paddingRightBottom,_viewMoreAction.heightMoreView - (i + 1) * (sizeButton + paddingIcon),sizeButton , sizeButton)];
        [_viewMoreAction addSubview:button];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SCProductMoreViewController-AfterInitViewMore" object:_viewMoreAction userInfo:@{@"productModel":self.productModel,@"controller":self}];
}

- (void)didTouchShare
{
    NSURL *productURL = [NSURL URLWithString:@"https://simicart.com"];
    
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[productURL]
                                      applicationActivities:nil];
    [self.navigationController presentViewController:activityViewController
                                            animated:YES
                                          completion:^{
                                              // ...
                                          }];
}

- (void)didTouchMoreAction
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SCProductMoreViewController-BeforeTouchMoreAction" object:self];
    if (!_viewMoreAction.isShowViewMoreAction) {
        [UIView animateWithDuration:0.15 animations:^{
            CGRect frame = _viewMoreAction.frame;
            frame.origin.y -= _viewMoreAction.heightMoreView;
            frame.size.height = _viewMoreAction.heightMoreView;
            [_viewMoreAction setFrame:frame];
            [_buttonMoreAction setTransform:CGAffineTransformMakeRotation(M_PI_4)];
        } completion:^(BOOL finished) {
            
        }];
    }else
    {
        CGRect frame = _viewMoreAction.frame;
        frame.origin.y += _viewMoreAction.heightMoreView;
        frame.size.height = 0;
        [UIView animateWithDuration:0.15 animations:^{
            [_buttonMoreAction setTransform:CGAffineTransformMakeRotation(0)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.15 animations:^{
                [_viewMoreAction setFrame:frame];
            } completion:^(BOOL finished) {
            }];
        }];
    }
    
    _viewMoreAction.isShowViewMoreAction = !_viewMoreAction.isShowViewMoreAction;
}

- (void)LazyPageScrollViewPageChange:(LazyPageScrollView *)pageScrollView Index:(NSInteger)index PreIndex:(NSInteger)preIndex
{
    
}

- (void)LazyPageScrollViewEdgeSwipe:(LazyPageScrollView *)pageScrollView Left:(BOOL)bLeft
{
    
}
- (NSString *)convertToHTMLString:(NSArray *)arr{
    NSString *str = @"";
    for (NSDictionary *dict in arr) {
        str = [NSString stringWithFormat:@"%@<b>%@</b></br>", str, [dict valueForKeyPath:@"title"]];
        str = [NSString stringWithFormat:@"%@%@</br></br>", str, [dict valueForKeyPath:@"value"]];
        str = [NSString stringWithFormat:@"<span style=\"font-family: %@; font-size: %i\">%@</span>",
               @"Helvetica",
               14,
               str];
    }
    return str;
}

#pragma mark Review Delegate
- (void)didSelectReviewDetail:(UIViewController *)viewController
{
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark Relate Delegate
- (void)didSelectRelatedProductWithFirstProductID:(NSString *)productID arrayProductID:(NSMutableArray *)arrayProductID
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        SCProductViewController *productViewController = [SCProductViewController new];
        productViewController.firstProductID = productID;
        productViewController.arrayProductsID = arrayProductID;
        [self.navigationController pushViewController:productViewController animated:YES];
    }else
        [self.delegate didSelectRelateProductWithProductID:productID arrayProduct:arrayProductID];
}
@end
