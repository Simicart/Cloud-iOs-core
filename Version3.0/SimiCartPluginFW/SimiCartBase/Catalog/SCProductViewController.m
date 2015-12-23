//
//  SCProductViewController.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/12/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SCProductViewController.h"

@interface SCProductViewController ()
{
    SimiCartModel *cartModel;
}
@end

@implementation SCProductViewController
@synthesize viewToolBar, hadCurrentProductModel;
@synthesize numberOfRequired;
@synthesize product, optionPopoverController;
@synthesize lblRegularPrice, lblSpecialPrice;
#pragma mark Init
- (void)viewDidLoadBefore
{
    heightViewAction = 50;
    heightNavigation = 64;
    widthLongButton = 310;
    widthShortButton = 145;
    paddingEdge = 5;
    spaceBetweenButton = 20;
    heightButton = 40;
    heightShadow = 1.5;
    cornerRadius = 4;
    
    [super viewDidLoadBefore];
    self.arrayProductsView = [NSMutableArray new];
    self.heightScrollView = CGRectGetHeight(self.view.frame) - heightNavigation;
    self.widthScrollView = CGRectGetWidth(self.view.frame);
    
    self.scrollViewProducts = [[UIScrollView alloc]initWithFrame:self.view.frame];
    [self.scrollViewProducts setContentSize:CGSizeMake(self.widthScrollView * self.arrayProductsID.count, self.heightScrollView)];
    [self.scrollViewProducts setBackgroundColor:[UIColor clearColor]];
    [self.scrollViewProducts setDelegate:self];
    if(self.firstProductID == nil || [self.firstProductID isEqualToString:@""])
    {
        self.firstProductID = self.productId;
        self.arrayProductsID = [[NSMutableArray alloc]initWithArray:@[self.productId]];
    }
    
    if (self.arrayProductsID == nil) {
        self.arrayProductsID = [[NSMutableArray alloc]initWithArray:@[self.firstProductID]];
    }
    for (int i = 0; i < self.arrayProductsID.count; i++) {
        SCProductView *productView = [[SCProductView alloc]initWithFrame:CGRectMake(self.widthScrollView *i, 0, self.widthScrollView, self.heightScrollView) productID:[self.arrayProductsID objectAtIndex:i]];
        productView.frameParentView = self.view.frame;
        productView.delegate = self;
        [self.arrayProductsView addObject:productView];
        [self.scrollViewProducts addSubview:productView];
    }
    for (int i = 0; i < self.arrayProductsID.count; i++) {
        if([[self.arrayProductsID objectAtIndex:i] isEqualToString:self.firstProductID])
        {
            self.currentIndexProductOnArray = i;
            break;
        }
    }
    [self.scrollViewProducts setPagingEnabled:YES];
    [self.scrollViewProducts setContentOffset:CGPointMake(self.currentIndexProductOnArray*self.widthScrollView, 0) animated:NO];
    for (int i = self.currentIndexProductOnArray - 1; i <= self.currentIndexProductOnArray + 1; i++) {
        if (i >= 0 && i < self.arrayProductsID.count) {
            SCProductView *currentShowProduct = (SCProductView*)[self.arrayProductsView objectAtIndex:i];
            if (!currentShowProduct.isGotProduct) {
                [currentShowProduct getProductDetail];
            }
        }
    }
    [self.view addSubview:self.scrollViewProducts];
    
    [self viewToolBar];
    [self.view addSubview: viewToolBar];
    [self initViewAction];
    self.currentImageProduct = [UIImageView new];
    
    self.isFirtLoadProduct = YES;
    [self.viewToolBar setHidden:YES];
    [self.viewAction setHidden:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZThemeProductViewController_DidLoadBefore" object:self userInfo:@{@"viewAction": self.viewAction, @"view":self.view}];
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    [super viewWillAppearBefore:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (void)initViewAction
{
    self.viewAction = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - heightNavigation - heightViewAction, CGRectGetWidth(self.view.frame), heightViewAction)];
    [self.viewAction setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.viewAction];
    
    self.buttonAddToCart = [[UIButton alloc]initWithFrame:CGRectMake([SimiGlobalVar scaleValue:(paddingEdge + widthShortButton + spaceBetweenButton)], 0, [SimiGlobalVar scaleValue:widthShortButton], heightButton)];
    [self.buttonAddToCart addTarget:self action:@selector(addToCart) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonAddToCart setTitle:SCLocalizedString(@"Add To Cart") forState:UIControlStateNormal];
    [self.buttonAddToCart setTitleColor:THEME_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
    self.buttonAddToCart.backgroundColor = THEME_BUTTON_BACKGROUND_COLOR;
    self.buttonAddToCart.layer.masksToBounds = YES;
    self.buttonAddToCart.layer.cornerRadius = cornerRadius;
    
    CGRect frame = self.buttonAddToCart.frame;
    frame.size.height += heightShadow;
    self.imageShadowAddToCart = [[UIImageView alloc]initWithFrame:frame];
    [self.imageShadowAddToCart setBackgroundColor:[[SimiGlobalVar sharedInstance] darkerColorForColor:self.buttonAddToCart.backgroundColor]];
    self.imageShadowAddToCart.layer.cornerRadius = cornerRadius;
    [self.viewAction addSubview:self.imageShadowAddToCart];
    [self.viewAction addSubview:self.buttonAddToCart];
    
    
    self.buttonSelectOption = [[UIButton alloc]initWithFrame:CGRectMake([SimiGlobalVar scaleValue:paddingEdge], 0, [ SimiGlobalVar scaleValue:widthShortButton], heightButton)];
    [self.buttonSelectOption addTarget:self action:@selector(buttonSelectOptionTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonSelectOption setTitle:SCLocalizedString(@"Option") forState:UIControlStateNormal];
    [self.buttonSelectOption setTitleColor:THEME_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
    self.buttonSelectOption.backgroundColor = [UIColor grayColor];
    self.buttonSelectOption.layer.masksToBounds = YES;
    self.buttonSelectOption.layer.cornerRadius = cornerRadius;
    
    frame = self.buttonSelectOption.frame;
    frame.size.height += heightShadow;
    self.imageShadowSelectOption = [[UIImageView alloc]initWithFrame:frame];
    [self.imageShadowSelectOption setBackgroundColor:[[SimiGlobalVar sharedInstance] darkerColorForColor:self.buttonSelectOption.backgroundColor]];
    self.imageShadowSelectOption.layer.cornerRadius = cornerRadius;
    [self.viewAction addSubview:self.imageShadowSelectOption];
    [self.viewAction addSubview:self.buttonSelectOption];
}

- (UIView *)viewToolBar
{
    if(viewToolBar == nil)
    {
        int priceFontSize = 14;
        float paddingLeft = 10;
        float paddingTop = 5;
        CGRect frame = self.view.frame;
        frame.size.height = 50;
        viewToolBar = [[UIView alloc]initWithFrame:frame];
        viewToolBar.backgroundColor = [[SimiGlobalVar sharedInstance]colorWithHexString:@"#eeeeee" alpha:0.9];
        
        _labelProductName = [[UILabel alloc]initWithFrame:CGRectMake(paddingLeft, paddingTop, [SimiGlobalVar scaleValue:250], 20)];
        [_labelProductName setTextColor:THEME_CONTENT_COLOR];
        [_labelProductName setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:priceFontSize]];
        [viewToolBar addSubview:_labelProductName];
        
        lblRegularPrice = [UILabel new];
        lblRegularPrice.textColor = THEME_PRICE_COLOR;
        [lblRegularPrice setBackgroundColor:[UIColor clearColor]];
        [lblRegularPrice setFont:[UIFont fontWithName:THEME_FONT_NAME size:priceFontSize]];
        [viewToolBar addSubview:lblRegularPrice];
        
        lblSpecialPrice = [UILabel new];
        lblSpecialPrice.textColor = THEME_PRICE_COLOR;
        [lblSpecialPrice setBackgroundColor:[UIColor clearColor]];
        [lblSpecialPrice setFont:[UIFont fontWithName:THEME_FONT_NAME size:priceFontSize]];
        [viewToolBar addSubview:lblSpecialPrice];
        
        _crossLine = [UIView new];
        [_crossLine setBackgroundColor:THEME_PRICE_COLOR];
        [lblRegularPrice addSubview:_crossLine];
        
        _moreInfoImage = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 62, (CGRectGetHeight(viewToolBar.frame) - 20)/2, 20 ,20 )];
        [_moreInfoImage setImage:[UIImage imageNamed:@"ic_more"]];
        [viewToolBar addSubview:_moreInfoImage];
        
        _moreLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 42, paddingTop, 40, 40)];
        [_moreLabel setText:SCLocalizedString(@"More")];
        [_moreLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:priceFontSize]];
        [viewToolBar addSubview:_moreLabel];
        
        _detailButon = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 60, paddingTop, 60, 40)];
        [_detailButon setBackgroundColor:[UIColor clearColor]];
        [_detailButon addTarget:self action:@selector(didTouchDetailButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [viewToolBar addSubview:_detailButon];
    }
    return viewToolBar;
}

#pragma mark Convert Action
- (void)processingOptions
{
    self.hasOption = NO;
    switch (product.productType) {
#pragma mark Configurable
        case ProductTypeConfigurable:
        {
            if ([product valueForKey:@"variations"]) {
                self.variantsAllKey = [[NSMutableArray alloc]initWithArray:[product valueForKey:@"variations"]];
            }
            if ([product valueForKey:@"variants_attribute"]) {
                self.variantOptions = [NSMutableArray new];
                NSMutableArray *variantsAttribute = [[NSMutableArray alloc]initWithArray:[product valueForKey:@"variants_attribute"]];
                for (int i = 0; i <variantsAttribute.count; i++) {
                    NSMutableDictionary *variantAttribute = (NSMutableDictionary*)[variantsAttribute objectAtIndex:i];
                    if ([variantAttribute valueForKey:@"values"]) {
                        NSMutableArray *arrayValue = [[NSMutableArray alloc]initWithArray:[variantAttribute valueForKey:@"values"]];
                        for (int j = 0; j < arrayValue.count; j++) {
                            ProductOptionModel *optionModel = [[ProductOptionModel alloc]initWithDictionary:@{@"title":[arrayValue objectAtIndex:j]}];
                            optionModel.variantAttributeKey = [variantAttribute valueForKey:@"_id"];
                            optionModel.variantAttributeTitle = [variantAttribute valueForKey:@"name"];
                            optionModel.title = [arrayValue objectAtIndex:j];
                            optionModel.dependIds = [NSMutableArray new];
                            [self.variantOptions addObject:optionModel];
                        }
                    }
                }
            }
            if ([product valueForKey:@"variants"]) {
                self.variants = [[NSMutableArray alloc]initWithArray:[product valueForKey:@"variants"]];
                for (int i = 0; i < self.variants.count; i++) {
                    NSMutableDictionary *variant = [[NSMutableDictionary alloc]initWithDictionary:[self.variants objectAtIndex:i]];
                    for (int j = 0; j < self.variantOptions.count; j++) {
                        ProductOptionModel *option = (ProductOptionModel*)[self.variantOptions objectAtIndex:j];
                        if ([[variant objectForKey:option.variantAttributeKey] isEqualToString:option.title]) {
                            [option.dependIds addObject:[variant objectForKey:@"_id"]];
                        }
                    }
                }
            }
            
            if ([product valueForKey:@"customs"]) {
                self.customs = [[NSMutableArray alloc]initWithArray:[product valueForKey:@"customs"]];
                self.customOptions = [NSMutableDictionary new];
                if (self.customs.count > 0) {
                    for (int i = 0; i < self.customs.count; i++) {
                        NSMutableDictionary *custom = [self.customs objectAtIndex:i];
                        if ([custom valueForKey:@"values"]) {
                            NSMutableArray *values = [[NSMutableArray alloc]initWithArray:[custom valueForKey:@"values"]];
                            NSMutableArray *options = [NSMutableArray new];
                            if (values.count > 0) {
                                for (int j = 0; j < values.count; j++) {
                                    ProductOptionModel *optionModel = [[ProductOptionModel alloc]initWithDictionary:[values objectAtIndex:j]];
                                    [options addObject:optionModel];
                                }
                            }
                            [self.customOptions setObject:options forKey:[custom valueForKey:@"_id"]];
                        }
                    }
                }
            }
            if (self.variantsAllKey.count > 0) {
                self.hasOption = YES;
            }
        }
            break;
#pragma mark Simple
        case ProductTypeSimple:
        {
            if ([product valueForKey:@"customs"]) {
                self.customs = [[NSMutableArray alloc]initWithArray:[product valueForKey:@"customs"]];
                self.customOptions = [NSMutableDictionary new];
                if (self.customs.count > 0) {
                    self.hasOption = YES;
                    for (int i = 0; i < self.customs.count; i++) {
                        NSMutableDictionary *custom = [self.customs objectAtIndex:i];
                        if ([custom valueForKey:@"values"]) {
                            NSMutableArray *values = [[NSMutableArray alloc]initWithArray:[custom valueForKey:@"values"]];
                            NSMutableArray *options = [NSMutableArray new];
                            if (values.count > 0) {
                                for (int j = 0; j < values.count; j++) {
                                    ProductOptionModel *optionModel = [[ProductOptionModel alloc]initWithDictionary:[values objectAtIndex:j]];
                                    [options addObject:optionModel];
                                }
                            }
                            [self.customOptions setObject:options forKey:[custom valueForKey:@"_id"]];
                        }
                    }
                }
            }
        }
            break;
#pragma mark Bundle
        case ProductTypeBundle:
        {
            if ([self.product valueForKey:@"bundle_items"]) {
                self.bundleItems = [[NSMutableArray alloc]initWithArray:[product valueForKey:@"bundle_items"]];
                self.bundleOptions = [NSMutableDictionary new];
                if (self.bundleItems.count > 0) {
                    self.hasOption = YES;
                    for (int i = 0; i < self.bundleItems.count; i++) {
                        NSMutableDictionary *bundleItem = [self.bundleItems objectAtIndex:i];
                        if ([bundleItem valueForKey:@"values"]) {
                            NSMutableArray *values = [[NSMutableArray alloc]initWithArray:[bundleItem valueForKey:@"values"]];
                            NSMutableArray *options = [NSMutableArray new];
                            if (values.count > 0) {
                                for (int j = 0; j < values.count; j++) {
                                    ProductOptionModel *optionModel = [[ProductOptionModel alloc]initWithDictionary:[values objectAtIndex:j]];
                                    [options addObject:optionModel];
                                }
                            }
                            [self.bundleOptions setObject:options forKey:[bundleItem valueForKey:@"_id"]];
                        }
                    }
                }
            }
        }
            break;
#pragma mark Grouped
        case ProductTypeGrouped:
        {
            if ([self.product valueForKey:@"group_items"]) {
                self.groupItems = [[NSMutableArray alloc]initWithArray:[product valueForKey:@"group_items"]];
                self.groupOptions = [NSMutableArray new];
                if (self.groupItems.count > 0) {
                    self.hasOption = YES;
                    for (int i = 0; i < self.groupItems.count; i++) {
                        NSMutableDictionary *groupItem = [self.groupItems objectAtIndex:i];
                        ProductOptionModel *optionModel = [[ProductOptionModel alloc]initWithDictionary:groupItem];
                        if ([optionModel valueForKey:@"default_qty"] && [[optionModel valueForKey:@"default_qty"]intValue] > 0) {
                            [optionModel setValue:[optionModel valueForKey:@"default_qty"] forKey:@"option_qty"];
                            optionModel.isSelected = YES;
                        }else
                            [optionModel setValue:@"0" forKey:@"option_qty"];
                        [self.groupOptions addObject:optionModel];
                    }
                }
            }
            [self configSelectedOption];
        }
            break;
        default:
            break;
    }
}

- (NSInteger)countNumberOfRequired{
    NSInteger count = 0;
    if (self.customs > 0) {
        for (NSMutableDictionary* custom in self.customs) {
            if ([[custom valueForKey:is_required]boolValue]) {
                count++;
            }
        }
    }
    if (self.bundleItems) {
        for (NSMutableDictionary* bundleItem in self.bundleItems) {
            if ([[bundleItem valueForKey:is_required]boolValue]) {
                count++;
            }
        }
    }
    return count;
}

- (BOOL)isCheckedAllRequiredOptions{
    NSInteger count = 0;
    BOOL checked = YES;
    for (NSMutableDictionary* custom in self.customs) {
        if ([[custom valueForKey:is_required]boolValue] && [[custom valueForKey:is_selected]boolValue]) {
            count++;
        }
    }
    for (NSMutableDictionary* bundleItem in self.bundleItems) {
        if ([[bundleItem valueForKey:is_required]boolValue] && [[bundleItem valueForKey:is_selected]boolValue]) {
            count++;
        }
    }
    if (count < self.numberOfRequired){
        checked = NO;
    }
    return checked;
}

#pragma mark UIScroll View Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZThemeProductViewController_BeginChangeProduct" object:self];
    [self configureProductViewWithStatus:NO];
    self.currentIndexProductOnArray = self.scrollViewProducts.contentOffset.x/self.widthScrollView;
    for (int i = self.currentIndexProductOnArray - 1; i <= self.currentIndexProductOnArray + 1; i++) {
        if (i >= 0 && i < self.arrayProductsID.count) {
            SCProductView *currentShowProduct = (SCProductView*)[self.arrayProductsView objectAtIndex:i];
            if (!currentShowProduct.isGotProduct) {
                [currentShowProduct getProductDetail];
            }
        }
    }
    
    SCProductView *productView = [_arrayProductsView objectAtIndex:self.currentIndexProductOnArray];
    self.variantSelectedKey = @"";
    if (productView.isDidGetProduct) {
        [self setProduct:productView.productModel];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZThemeProductViewController_DidChangeProduct" object:self];
}

#pragma mark Action Touch Button
- (void)didTouchDetailButton:(id)sender
{
    if (hadCurrentProductModel) {
        SCProductMoreViewController *moreViewController = [SCProductMoreViewController new];
        moreViewController.productModel = self.product;
        moreViewController.variantSelectedKey = self.variantSelectedKey;
        moreViewController.variants = self.variants;
        [self.navigationController pushViewController:moreViewController animated:YES];
    }
}

- (void)didTouchShareButton
{
    NSURL *productURL = [NSURL URLWithString:@"Hello"];
    if ([product valueForKey:@"product_url"]) {
        productURL = [NSURL URLWithString:[product valueForKey:@"product_url"]];
    }
    
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[productURL]
                                      applicationActivities:nil];
    [self.navigationController presentViewController:activityViewController
                                            animated:YES
                                          completion:^{
                                              // ...
                                          }];
}

#pragma mark ZThemeProductView Delegate
- (void)didGetProductDetailWithProductID:(NSString *)productID
{
    SCProductView *productView = [_arrayProductsView objectAtIndex:self.currentIndexProductOnArray];
    if ([productView.productID isEqualToString:productID]) {
        if (self.isFirtLoadProduct) {
            [self.viewToolBar setHidden:NO];
            [self.viewAction setHidden:NO];
            self.isFirtLoadProduct = NO;
        }
        [self setProduct:productView.productModel];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ZThemeProductViewController_DidGetProduct" object:self];
    }
}

- (void)touchImage
{
    self.isShowOnlyImage = !self.isShowOnlyImage;
    if (self.isShowOnlyImage) {
        [viewToolBar setHidden:YES];
        [_viewAction setHidden:YES];
    }else
    {
        [viewToolBar setHidden:NO];
        [_viewAction setHidden:NO];
    }
}

#pragma mark Set Data
- (void)setProduct:(SimiProductModel *)product_
{
    if (product_ != nil) {
        product = product_;
        [self configureProductViewWithStatus:YES];
        [_labelProductName setText:[product valueForKey:@"name"]];
        NSMutableArray *arrayImage = [product valueForKey:@"images"];
        if (arrayImage.count > 0) {
            [self.currentImageProduct sd_setImageWithURL:[[arrayImage objectAtIndex:0] valueForKey:@"url"]];
        }
        self.variantSelectedKey = @"";
        [self setPrice];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"ZThemeProductViewController_DidSetNewProductModel" object:self userInfo:@{@"productmodel":product}];
    }
}

- (void)setPrice
{
    self.lblRegularPrice.hidden = YES;
    self.lblSpecialPrice.hidden = YES;
    self.crossLine.hidden = YES;
    float priceRegular = 0.00;
    float priceSpecial = 0.00;
    float paddingLeft = 10;
    float paddingTop = 25;
    switch (product.productType) {
#pragma mark Bundle
        case ProductTypeBundle:
        {
#pragma mark Fixed
            if ([[product valueForKey:@"sale_price_type"]boolValue]) {
                [self setNormalPrice];
#pragma mark Dynamic
            }else
            {
                if ([self.product valueForKey:@"total_option_price"]) {
                    priceRegular += [[self.product valueForKey:@"total_option_price"] floatValue];
                }
                [lblRegularPrice setFrame:CGRectMake(paddingLeft, paddingTop, 250, 20)];
                [lblRegularPrice setText:[[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:priceRegular]]];
                [lblRegularPrice setHidden:NO];
            }
        }
            break;
#pragma mark Configurable
        case ProductTypeConfigurable:
        {
            if (![self.variantSelectedKey isEqualToString:@""] && self.variantSelectedKey != nil) {
                for (NSMutableDictionary *variant in self.variants) {
                    if ([[variant valueForKey:@"_id"] isEqualToString:self.variantSelectedKey]) {
                        if ([variant valueForKey:@"price_include_tax"] && DISPLAY_PRICES_INSHOP) {
                            [lblRegularPrice setFrame:CGRectMake(paddingLeft, paddingTop, 250, 20)];
                            if ([self.product valueForKey:@"total_option_price"]) {
                                priceRegular += [[self.product valueForKey:@"total_option_price"] floatValue];
                            }
                            priceRegular += [[variant valueForKey:@"price_include_tax"] floatValue];
                            [lblRegularPrice setText:[[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:priceRegular]]];
                            [lblRegularPrice setHidden:NO];
                            
                            if ([product valueForKey:@"sale_price_include_tax"]) {
                                NSString *salePriceInclude = [NSString stringWithFormat:@"%@",[variant valueForKey:@"sale_price_include_tax"]];
                                if (!([salePriceInclude floatValue] == [[variant valueForKey:@"price_include_tax"] floatValue])) {
                                    CGFloat priceWidth = [self.lblRegularPrice.text sizeWithAttributes:@{NSFontAttributeName:[self.lblRegularPrice font]}].width;
                                    [self.crossLine setFrame:CGRectMake(0, CGRectGetHeight(lblRegularPrice.frame)/2, priceWidth, 1)];
                                    [self.crossLine setHidden:NO];
                                    
                                    [lblSpecialPrice setFrame:CGRectMake([SimiGlobalVar scaleValue:85], paddingTop,[SimiGlobalVar scaleValue:80], 20)];
                                    if ([self.product valueForKey:@"total_option_price"]) {
                                        priceSpecial += [[self.product valueForKey:@"total_option_price"] floatValue];
                                    }
                                    
                                    priceSpecial += [[variant valueForKey:@"sale_price_include_tax"] floatValue];
                                    [lblSpecialPrice setText:[[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:priceSpecial]]];
                                    [lblSpecialPrice setHidden:NO];
                                }
                            }
                            //  Liam Update RTL
                            if([[SimiGlobalVar sharedInstance]isReverseLanguage])
                            {
                            }
                            //  End RTL
                            return;
                        }
                        
                        if ([variant valueForKey:@"price"]) {
                            [lblRegularPrice setFrame:CGRectMake(paddingLeft, paddingTop, 250, 20)];
                            if ([self.product valueForKey:@"total_option_price"]) {
                                priceRegular += [[self.product valueForKey:@"total_option_price"] floatValue];
                            }
                            priceRegular += [[variant valueForKey:@"price"] floatValue];
                            [lblRegularPrice setText:[[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:priceRegular]]];
                            [lblRegularPrice setHidden:NO];
                            
                            if ([variant valueForKey:@"sale_price"]) {
                                NSString *salePriceInclude = [NSString stringWithFormat:@"%@",[variant valueForKey:@"sale_price"]];
                                if (!([salePriceInclude floatValue] == [[variant valueForKey:@"price"] floatValue])) {
                                    CGFloat priceWidth = [self.lblRegularPrice.text sizeWithAttributes:@{NSFontAttributeName:[self.lblRegularPrice font]}].width;
                                    [self.crossLine setFrame:CGRectMake(0, CGRectGetHeight(lblRegularPrice.frame)/2, priceWidth, 1)];
                                    [self.crossLine setHidden:NO];
                                    
                                    [lblSpecialPrice setFrame:CGRectMake([SimiGlobalVar scaleValue:85], paddingTop,[SimiGlobalVar scaleValue:80], 20)];
                                    if ([self.product valueForKey:@"total_option_price"]) {
                                        priceSpecial += [[self.product valueForKey:@"total_option_price"] floatValue];
                                    }
                                    
                                    priceSpecial += [[variant valueForKey:@"sale_price"] floatValue];
                                    [lblSpecialPrice setText:[[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:priceSpecial]]];
                                    [lblSpecialPrice setHidden:NO];
                                }
                            }
                            //  Liam Update RTL
                            if([[SimiGlobalVar sharedInstance]isReverseLanguage])
                            {
                            }
                            //  End RTL
                            return;
                        }
                    }
                }
            }else
            {
                [self setNormalPrice];
            }
        }
            break;
#pragma mark Simple
        case ProductTypeSimple:
        {
            [self setNormalPrice];
        }
            break;
#pragma mark Grouped
        case ProductTypeGrouped:
        {
            [self setNormalPrice];
        }
            break;
        default:
            break;
    }
}

- (void)setNormalPrice
{
    self.lblRegularPrice.hidden = YES;
    self.lblSpecialPrice.hidden = YES;
    self.crossLine.hidden = YES;
    float priceRegular = 0.00;
    float priceSpecial = 0.00;
    float paddingLeft = 10;
    float paddingTop = 25;
    
    if ([product valueForKey:@"price_include_tax"] && DISPLAY_PRICES_INSHOP) {
        [lblRegularPrice setFrame:CGRectMake(paddingLeft, paddingTop, 250, 20)];
        if ([self.product valueForKey:@"total_option_price"]) {
            priceRegular += [[self.product valueForKey:@"total_option_price"] floatValue];
        }
        priceRegular += [[product valueForKey:@"price_include_tax"] floatValue];
        [lblRegularPrice setText:[[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:priceRegular]]];
        [lblRegularPrice setHidden:NO];
        
        if ([product valueForKey:@"sale_price_include_tax"]) {
            NSString *salePriceInclude = [NSString stringWithFormat:@"%@",[product valueForKey:@"sale_price_include_tax"]];
            if (!([salePriceInclude floatValue] == [[product valueForKey:@"price_include_tax"] floatValue])) {
                CGFloat priceWidth = [self.lblRegularPrice.text sizeWithAttributes:@{NSFontAttributeName:[self.lblRegularPrice font]}].width;
                [self.crossLine setFrame:CGRectMake(0, CGRectGetHeight(lblRegularPrice.frame)/2, priceWidth, 1)];
                [self.crossLine setHidden:NO];
                
                [lblSpecialPrice setFrame:CGRectMake([SimiGlobalVar scaleValue:85], paddingTop,[SimiGlobalVar scaleValue:80], 20)];
                if ([self.product valueForKey:@"total_option_price"]) {
                    priceSpecial += [[self.product valueForKey:@"total_option_price"] floatValue];
                }
                
                priceSpecial += [[product valueForKey:@"sale_price_include_tax"] floatValue];
                [lblSpecialPrice setText:[[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:priceSpecial]]];
                [lblSpecialPrice setHidden:NO];
            }
        }
        //  Liam Update RTL
        if([[SimiGlobalVar sharedInstance]isReverseLanguage])
        {
        }
        //  End RTL
        return;
    }
    
    if ([product valueForKey:@"price"]) {
        [lblRegularPrice setFrame:CGRectMake(paddingLeft, paddingTop, 250, 20)];
        if ([self.product valueForKey:@"total_option_price"]) {
            priceRegular += [[self.product valueForKey:@"total_option_price"] floatValue];
        }
        priceRegular += [[product valueForKey:@"price"] floatValue];
        [lblRegularPrice setText:[[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:priceRegular]]];
        [lblRegularPrice setHidden:NO];
        
        if ([product valueForKey:@"sale_price"]) {
            NSString *salePriceInclude = [NSString stringWithFormat:@"%@",[product valueForKey:@"sale_price"]];
            if (!([salePriceInclude floatValue] == [[product valueForKey:@"price"] floatValue])) {
                CGFloat priceWidth = [self.lblRegularPrice.text sizeWithAttributes:@{NSFontAttributeName:[self.lblRegularPrice font]}].width;
                [self.crossLine setFrame:CGRectMake(0, CGRectGetHeight(lblRegularPrice.frame)/2, priceWidth, 1)];
                [self.crossLine setHidden:NO];
                
                [lblSpecialPrice setFrame:CGRectMake([SimiGlobalVar scaleValue:85], paddingTop,[SimiGlobalVar scaleValue:80], 20)];
                if ([self.product valueForKey:@"total_option_price"]) {
                    priceSpecial += [[self.product valueForKey:@"total_option_price"] floatValue];
                }
                
                priceSpecial += [[product valueForKey:@"sale_price"] floatValue];
                [lblSpecialPrice setText:[[SimiFormatter sharedInstance]priceByLocalizeNumber:[NSNumber numberWithFloat:priceSpecial]]];
                [lblSpecialPrice setHidden:NO];
            }
        }
        //  Liam Update RTL
        if([[SimiGlobalVar sharedInstance]isReverseLanguage])
        {
        }
        //  End RTL
        return;
    }
}

#pragma mark Configure Interface
- (void)configureProductViewWithStatus:(BOOL)isStatus // Yes: had ProductModel
{
    [self.product setValue:@"YES" forKey:@"manage_stock"];
    if (isStatus) {
        [self changeStateActionButtonWithState:YES];
        self.hadCurrentProductModel = YES;
        [self processingOptions];
        self.selectedOptionPrice = [NSMutableDictionary new];
        numberOfRequired = [self countNumberOfRequired];
        if (self.hasOption) {
            if (CGRectGetWidth(self.buttonAddToCart.frame) != [SimiGlobalVar scaleValue:widthShortButton]) {
                [UIView animateWithDuration:0.2
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     [self.buttonAddToCart setFrame:CGRectMake([SimiGlobalVar scaleValue:(paddingEdge + spaceBetweenButton + widthShortButton)], 0, [SimiGlobalVar scaleValue:widthShortButton], heightButton)];
                                     CGRect frame = self.buttonAddToCart.frame;
                                     frame.origin.y += heightShadow;
                                     [self.imageShadowAddToCart setFrame:frame];
                                 }
                                 completion:^(BOOL finished) {
                                 }];
                [UIView animateWithDuration:0.2
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     [self.buttonSelectOption setHidden:NO];
                                     [self.buttonSelectOption setFrame:CGRectMake([SimiGlobalVar scaleValue:paddingEdge], 0, [SimiGlobalVar scaleValue:widthShortButton], heightButton)];
                                     [self.imageShadowSelectOption setHidden:NO];
                                     CGRect frame = self.buttonSelectOption.frame;
                                     frame.origin.y += heightShadow;
                                     [self.imageShadowSelectOption setFrame:frame];
                                 }
                                 completion:^(BOOL finished) {
                                 }];
            }
        }else
        {
            [self.buttonSelectOption setHidden:YES];
            [self.imageShadowSelectOption setHidden:YES];
            if (CGRectGetWidth(self.buttonAddToCart.frame) != [SimiGlobalVar scaleValue:310]) {
                [UIView animateWithDuration:0.2
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     [self.buttonAddToCart setFrame:CGRectMake([SimiGlobalVar scaleValue:paddingEdge], 0, [SimiGlobalVar scaleValue:widthLongButton], heightButton)];
                                     CGRect frame = self.buttonAddToCart.frame;
                                     frame.origin.y += heightShadow;
                                     [self.imageShadowAddToCart setFrame:frame];
                                 }
                                 completion:^(BOOL finished) {
                                 }];
            }
        }
        
        [self.buttonAddToCart setTitle:SCLocalizedString(@"Add To Cart") forState:UIControlStateNormal];
        if (![[product valueForKey:@"manage_stock"]boolValue]) {
            [self.buttonAddToCart setTitle:SCLocalizedString(@"Out Stock") forState:UIControlStateNormal];
            [self.buttonAddToCart setEnabled:NO];
            [self.buttonAddToCart setAlpha:0.5];
            self.imageShadowAddToCart.alpha = 0.5;
            [self.buttonSelectOption setEnabled:NO];
        }
    }else
    {
        [self changeStateActionButtonWithState:NO];
    }
}

#pragma mark Selection & Add To Cart
- (void)addToCart
{
    BOOL canCheckOut = NO;
    switch (self.product.productType) {
        case ProductTypeBundle:
        {
            if ((self.bundleOptions.count > 0 && [self isCheckedAllRequiredOptions])) {
                canCheckOut = YES;
            }
        }
            break;
        case ProductTypeGrouped:
        {
            int count = 0;
            if (self.groupOptions > 0) {
                for (ProductOptionModel *groupItem in self.groupOptions) {
                    if (groupItem.isSelected) {
                        count += [[groupItem valueForKey:@"option_qty"]intValue];
                    }
                }
            }
            if (count > 0) {
                canCheckOut = YES;
            }
        }
            break;
        case ProductTypeConfigurable:
        {
            if (![self.variantSelectedKey isEqualToString:@""] && self.variantSelectedKey != nil && ((self.customOptions.count > 0 && [self isCheckedAllRequiredOptions]) || (self.customOptions.count == 0))) {
                canCheckOut = YES;
            }
        }
            break;
        case ProductTypeSimple:
        {
            if ((self.customOptions.count > 0 && [self isCheckedAllRequiredOptions]) || (self.customOptions.count == 0)) {
                canCheckOut = YES;
            }
        }
            break;
        default:
            break;
    }
    if (canCheckOut) {
        //Create animation
        UIImageView *thumnailView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 100, 300, 400)];
        thumnailView.image = self.currentImageProduct.image;
        [thumnailView setContentMode:UIViewContentModeScaleAspectFit];
        [self.view addSubview:thumnailView];
        [UIView animateWithDuration:0.6
                              delay:0
                            options:UIViewAnimationOptionAllowAnimatedContent
                         animations:^{
                             thumnailView.frame = CGRectMake(260, 0, 60, 90);
                             thumnailView.transform = CGAffineTransformMakeRotation(140);
                         }
                         completion:^(BOOL finished){
                             [thumnailView removeFromSuperview];
                         }];
        [self startLoadingData];
        if ([SimiGlobalVar sharedInstance].quoteId == nil || [[SimiGlobalVar sharedInstance].quoteId isEqualToString:@""]) {
            cartModel = [SimiCartModel new];
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didCreateNewQuote:) name:DidCreateNewQuote object:cartModel];
            [cartModel createNewQuote];
        }else
        {
            [self addProductToCart];
        }
        return;
    }else{
        [self buttonSelectOptionTouch:self.buttonSelectOption];
        _isOpenOptionFromAddToCart = YES;
    }
}

- (void)buttonSelectOptionTouch:(id)sender
{
    if (_optionViewController == nil) {
        _optionViewController = [SCProductOptionViewController new];
        _optionViewController.tableViewOption.showsVerticalScrollIndicator = NO;
        _optionViewController.delegate = self;
    }
    _optionViewController.variants = self.variants;
    _optionViewController.variantsAllKey = self.variantsAllKey;
    _optionViewController.variantOptions = self.variantOptions;
    _optionViewController.product = self.product;
    _optionViewController.selectedOptionPrice = self.selectedOptionPrice;
    _optionViewController.variantSelectedKey = self.variantSelectedKey;
    
    _optionViewController.customOptions = self.customOptions;
    _optionViewController.customs = self.customs;
    
    _optionViewController.bundleItems = self.bundleItems;
    _optionViewController.bundleOptions = self.bundleOptions;
    
    _optionViewController.groupOptions = self.groupOptions;
    
    NSInteger count = self.variantsAllKey.count + self.customs.count + self. bundleItems.count + self.groupOptions.count;
    float heightPopup = count * 50 + 200;
    if (heightPopup > (SCREEN_HEIGHT - heightNavigation - heightViewAction - CGRectGetHeight(viewToolBar.frame) - 30)) {
        heightPopup = SCREEN_HEIGHT - heightNavigation - heightViewAction - CGRectGetHeight(self.viewAction.frame) - 30;
    }
    
    if (optionPopoverController == nil)
    {
        UIView *btn = (UIView *)sender;
        optionPopoverController = [[WYPopoverController alloc] initWithContentViewController:_optionViewController];
        optionPopoverController.delegate = self;
        optionPopoverController.passthroughViews = @[btn];
        optionPopoverController.popoverLayoutMargins = UIEdgeInsetsMake(10, 10, 10, 10);
        optionPopoverController.wantsDefaultContentAppearance = NO;
        [optionPopoverController setPopoverContentSize:CGSizeMake(SCREEN_WIDTH - 20, heightPopup)];
        optionPopoverController.noDismissWhenTouchBackgroud = YES;
        [optionPopoverController presentPopoverFromRect:btn.bounds
                                                 inView:btn
                               permittedArrowDirections:WYPopoverArrowDirectionDown
                                               animated:YES
                                                options:WYPopoverAnimationOptionFadeWithScale];
    }
    [self changeStateActionButtonWithState:NO];
}

- (void)close:(id)sender
{
    [optionPopoverController dismissPopoverAnimated:YES completion:^{
        [self sortPopupControllerDidDismissPopover:optionPopoverController];
    }];
}

#pragma mark - WYPopoverControllerDelegate
- (void)popoverControllerDidPresentPopover:(WYPopoverController *)controller
{
    
}

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    [self sortPopupControllerDidDismissPopover:optionPopoverController];
    return YES;
}

- (void)sortPopupControllerDidDismissPopover:(WYPopoverController *)controller
{
    if (controller == optionPopoverController)
    {
        optionPopoverController.delegate = nil;
        optionPopoverController = nil;
    }
}

- (BOOL)popoverControllerShouldIgnoreKeyboardBounds:(WYPopoverController *)popoverController
{
    return YES;
}

- (void)popoverController:(WYPopoverController *)popoverController willTranslatePopoverWithYOffset:(float *)value
{
    // keyboard is shown and the popover will be moved up by 163 pixels for example ( *value = 163 )
    *value = 0; // set value to 0 if you want to avoid the popover to be moved
}

#pragma mark Option Delegate
- (void)cancelButtonTouch
{
    [self close:nil];
    self.variantSelectedKey = @"";
    self.selectedOptionPrice = [NSMutableDictionary new];
    [self.buttonSelectOption setEnabled:YES];
    [self processingOptions];
    [self changeStateActionButtonWithState:YES];
    [self.product removeObjectForKey:@"total_option_price"];
    [self setPrice];
    _isOpenOptionFromAddToCart = NO;
}

- (void)doneButtonTouch
{
    self.variantSelectedKey = _optionViewController.variantSelectedKey;
    [self close:nil];
    if (_isOpenOptionFromAddToCart) {
        if ((self.optionDict.count > 0 && [self isCheckedAllRequiredOptions]) || (self.optionDict.count == 0))
        {
            [self addToCart];
        }
    }
    _isOpenOptionFromAddToCart = NO;
    [self changeStateActionButtonWithState:YES];
}

- (void)updatePriceWhenSelectOption
{
    self.variantSelectedKey = _optionViewController.variantSelectedKey;
    CGFloat totalOptionPrice = 0;
    switch (self.product.productType) {
        case ProductTypeGrouped:
        {
            for (NSMutableDictionary *groupItem in self.groupOptions) {
                NSString *tempKey = [groupItem valueForKey:@"_id"];
                if ([self.selectedOptionPrice valueForKey:tempKey]) {
                    totalOptionPrice += [[self.selectedOptionPrice valueForKey:tempKey] floatValue];
                }
            }
        }
            break;
        case ProductTypeSimple:
        {
            for (NSMutableDictionary *custom in self.customs) {
                NSString *tempKey = [custom valueForKey:@"_id"];
                if ([self.selectedOptionPrice valueForKey:tempKey]) {
                    totalOptionPrice += [[self.selectedOptionPrice valueForKey:tempKey] floatValue];
                }
            }
        }
            break;
        case ProductTypeConfigurable:
        {
            for (NSMutableDictionary *custom in self.customs) {
                NSString *tempKey = [custom valueForKey:@"_id"];
                if ([self.selectedOptionPrice valueForKey:tempKey]) {
                    totalOptionPrice += [[self.selectedOptionPrice valueForKey:tempKey] floatValue];
                }
            }
        }
            break;
        case ProductTypeBundle:
        {
            for (NSMutableDictionary *bundle in self.bundleItems) {
                NSString *tempKey = [bundle valueForKey:@"_id"];
                if ([self.selectedOptionPrice valueForKey:tempKey]) {
                    totalOptionPrice += [[self.selectedOptionPrice valueForKey:tempKey] floatValue];
                }
            }
        }
            break;
        default:
            break;
    }
    [self.product setValue:[NSString stringWithFormat:@"%.2f", totalOptionPrice] forKey:@"total_option_price"];
    [self setPrice];
}

#pragma mark Action Button State
- (void)changeStateActionButtonWithState:(BOOL)state
{
    if (state) {
        [self.detailButon setEnabled:YES];
        self.detailButon.alpha = 1;
        if ([[product valueForKey:@"manage_stock"] boolValue]) {
            self.buttonAddToCart.alpha = 1;
            self.buttonSelectOption.alpha = 1;
            self.imageShadowSelectOption.alpha = 1;
            self.imageShadowAddToCart.alpha = 1;
            [self.buttonAddToCart setEnabled:YES];
            [self.buttonSelectOption setEnabled:YES];
        }
    }else
    {
        [self.detailButon setEnabled:NO];
        self.detailButon.alpha = 0.5;
        self.buttonAddToCart.alpha = 0.5;
        self.buttonSelectOption.alpha = 0.5;
        self.imageShadowSelectOption.alpha = 0.5;
        self.imageShadowAddToCart.alpha = 0.5;
        [self.buttonAddToCart setEnabled:NO];
        [self.buttonSelectOption setEnabled:NO];
    }
}

#pragma mark Create New Quote & Add Product To Cart
- (void)didCreateNewQuote:(NSNotification*)noti
{
    if([noti.name isEqualToString:DidCreateNewQuote])
    {
        SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
        if ([responder.status isEqualToString:@"SUCCESS"]) {
            [SimiGlobalVar sharedInstance].quoteId = [cartModel valueForKey:@"_id"];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setValue:[cartModel valueForKey:@"_id"] forKey:@"quoteId"];
            [userDefaults synchronize];
            if ([[SimiGlobalVar sharedInstance]isLogin]) {
                cartModel = [SimiCartModel new];
                NSMutableDictionary *customer = [NSMutableDictionary new];
                SimiCustomerModel *customerModel = [SimiGlobalVar sharedInstance].customer;
                [customer setValue:[customerModel valueForKey:@"first_name"]  forKey:@"customer_first_name"];
                [customer setValue:[customerModel valueForKey:@"last_name"]  forKey:@"customer_last_name"];
                [customer setValue:[customerModel valueForKey:@"email"]  forKey:@"customer_email"];
                [customer setValue:[customerModel valueForKey:@"group_id"]  forKey:@"customer_group_id"];
                [customer setValue:[customerModel valueForKey:@"name"] forKey:@"customer_name"];
                [customer setValue:[customerModel valueForKey:@"_id"]  forKey:@"customer_id"];
                [cartModel addCustomerToQuote:[[NSMutableDictionary alloc]initWithDictionary:@{@"customer":customer}]];
                [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didAddCustomerToQuote:) name:DidAddCustomerToQuote object:cartModel];
            }else
                [self addProductToCart];
        }
        [self removeObserverForNotification:noti];
    }
}

- (void)didAddCustomerToQuote:(NSNotification*)noti
{
    if([noti.name isEqualToString:DidAddCustomerToQuote])
    {
        SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
        if ([responder.status isEqualToString:@"SUCCESS"]) {
            [self removeObserverForNotification:noti];
            [self addProductToCart];
        }
    }
}

- (void)addProductToCart
{
    SimiProductModel *cartItem = [SimiProductModel new];
    switch (product.productType) {
#pragma mark Simple
        case ProductTypeSimple:
        {
            NSString *variantID = [[[[NSMutableArray alloc]initWithArray:[self.product valueForKey:@"variants"]] objectAtIndex:0] valueForKey:@"_id"];
            [cartItem setValue:variantID forKey:@"variant_id"];
            [cartItem setValue:@"1" forKey:@"qty"];
            NSMutableArray *customsDetail = [NSMutableArray new];
            if (self.customs > 0) {
                for (NSMutableDictionary *custom in self.customs) {
                    NSString *customId = [custom valueForKey:@"_id"];
                    if ([[custom valueForKey:is_selected] boolValue]) {
                        NSMutableDictionary *customOptionDetail = [NSMutableDictionary new];
                        NSMutableArray *options = [self.customOptions valueForKey:customId];
                        [customOptionDetail setValue:customId forKey:@"customs_id"];
                        NSString *description = @"";
                        NSMutableArray *valueIds = [NSMutableArray new];
                        for (ProductOptionModel *optionModel in options) {
                            if (optionModel.isSelected) {
                                [valueIds addObject:[optionModel valueForKey:@"_id"]];
                            }
                        }
                        if ([[custom valueForKey:@"type"] isEqualToString:@"area"] || [[custom valueForKey:@"type"] isEqualToString:@"field"] || [[custom valueForKey:@"type"] isEqualToString:@"date_time"]||[[custom valueForKey:@"type"] isEqualToString:@"date"]||[[custom valueForKey:@"type"] isEqualToString:@"time"]) {
                            description = [custom valueForKey:@"option_value"];
                        }
                        [customOptionDetail setObject:valueIds forKey:@"value_id"];
                        [customsDetail addObject:customOptionDetail];
                    }
                }
            }
            [cartItem setObject:customsDetail forKey:@"customs_detail"];
        }
            break;
#pragma mark Configurable
        case ProductTypeConfigurable:
        {
            [cartItem setValue:self.variantSelectedKey forKey:@"variant_id"];
            [cartItem setValue:@"1" forKey:@"qty"];
            NSMutableArray *customsDetail = [NSMutableArray new];
            if (self.customs > 0) {
                for (NSMutableDictionary *custom in self.customs) {
                    NSString *customId = [custom valueForKey:@"_id"];
                    if ([[custom valueForKey:is_selected] boolValue]) {
                        NSMutableDictionary *customOptionDetail = [NSMutableDictionary new];
                        NSMutableArray *options = [self.customOptions valueForKey:customId];
                        [customOptionDetail setValue:customId forKey:@"customs_id"];
                        NSString *description = @"";
                        NSMutableArray *valueIds = [NSMutableArray new];
                        for (ProductOptionModel *optionModel in options) {
                            if (optionModel.isSelected) {
                                [valueIds addObject:[optionModel valueForKey:@"_id"]];
                            }
                        }
                        if ([[custom valueForKey:@"type"] isEqualToString:@"area"] || [[custom valueForKey:@"type"] isEqualToString:@"field"] || [[custom valueForKey:@"type"] isEqualToString:@"date_time"]||[[custom valueForKey:@"type"] isEqualToString:@"date"]||[[custom valueForKey:@"type"] isEqualToString:@"time"]) {
                            description = [custom valueForKey:@"option_value"];
                        }
                        [customOptionDetail setObject:valueIds forKey:@"value_id"];
                        [customsDetail addObject:customOptionDetail];
                    }
                }
            }
            [cartItem setObject:customsDetail forKey:@"customs_detail"];
        }
            break;
#pragma mark Bundle
        case ProductTypeBundle:
        {
            NSString *variantID = [[[[NSMutableArray alloc]initWithArray:[self.product valueForKey:@"variants"]] objectAtIndex:0] valueForKey:@"_id"];
            [cartItem setValue:variantID forKey:@"variant_id"];
            [cartItem setValue:@"1" forKey:@"qty"];
            NSMutableArray *bundleDetail = [NSMutableArray new];
            if (self.bundleItems > 0) {
                for (NSMutableDictionary *bundleItem in self.bundleItems) {
                    NSString *bundleId = [bundleItem valueForKey:@"_id"];
                    if ([[bundleItem valueForKey:is_selected] boolValue]) {
                        NSMutableDictionary *bundleOptionDetail = [NSMutableDictionary new];
                        NSMutableArray *options = [self.bundleOptions valueForKey:bundleId];
                        [bundleOptionDetail setValue:bundleId forKey:@"bundle_id"];
                        NSMutableArray *valueIds = [NSMutableArray new];
                        for (ProductOptionModel *optionModel in options) {
                            if (optionModel.isSelected) {
                                [valueIds addObject:[optionModel valueForKey:@"_id"]];
                            }
                        }
                        [bundleOptionDetail setObject:valueIds forKey:@"value_id"];
                        [bundleDetail addObject:bundleOptionDetail];
                    }
                }
            }
            [cartItem setObject:bundleDetail forKey:@"bundle_detail"];
        }
            break;
#pragma mark Grouped
        case ProductTypeGrouped:
        {
            NSString *variantID = [[[[NSMutableArray alloc]initWithArray:[self.product valueForKey:@"variants"]] objectAtIndex:0] valueForKey:@"_id"];
            [cartItem setValue:variantID forKey:@"variant_id"];
            [cartItem setValue:@"1" forKey:@"qty"];
            NSMutableArray *groupDetail = [NSMutableArray new];
            if (self.groupOptions > 0) {
                for (ProductOptionModel *groupItem in self.groupOptions) {
                    NSString *groupItemId = [groupItem valueForKey:@"item_id"];
                    if (groupItem.isSelected) {
                        NSMutableDictionary *groupOptionDetail = [NSMutableDictionary new];
                        [groupOptionDetail setValue:groupItemId forKey:@"item_id"];
                        [groupOptionDetail setValue:[groupItem valueForKey:@"option_qty"]  forKey:@"qty"];
                        [groupDetail addObject:groupOptionDetail];
                    }
                }
            }
            [cartItem setObject:groupDetail forKey:@"group_items"];
        }
            break;
        default:
            break;
    }
    cartModel = [SimiCartModel new];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveNotification:) name:DidAddToCart object:cartModel];
    [cartModel addToCartWithProduct:cartItem];
}

- (void)didReceiveNotification:(NSNotification *)noti
{
    if ([noti.name isEqualToString:DidAddToCart]) {
        [SimiGlobalVar sharedInstance].needGetCart = YES;
        [self stopLoadingData];
        [self removeObserverForNotification:noti];
        [[[SimiGlobalVar sharedInstance]cart] setData:[cartModel valueForKey:@"items"]];
        [[NSNotificationCenter defaultCenter] postNotificationName:DidChangeCart object:[cartModel valueForKey:@"items"]];
    }
}

- (void)configSelectedOption
{
    if (self.selectedOptionPrice == nil) {
        self.selectedOptionPrice = [[NSMutableDictionary alloc] init];
    }
#pragma mark Custom Option
    for (NSMutableDictionary *custom in self.customs) {
        CGFloat optionPrice = 0;
        NSString *tempKey = [custom valueForKey:@"_id"];
        NSMutableArray *options = [self.customOptions valueForKey:tempKey];
        BOOL isSelected = NO;
        for (ProductOptionModel *opt in options) {
            if (opt.isSelected) {
                CGFloat optionQty = 1.0f;
                if ([[opt valueForKey:@"qty"] floatValue] > 0.01f) {
                    optionQty = [[opt valueForKey:@"qty"] floatValue];
                }
                if ([opt valueForKey:@"price_include_tax"] && DISPLAY_PRICES_INSHOP) {
                    optionPrice += optionQty * [[NSString stringWithFormat:@"%@",[opt valueForKey:@"price_include_tax"]] floatValue];
                }else
                {
                    optionPrice += optionQty * [[NSString stringWithFormat:@"%@",[opt valueForKey:@"price"]] floatValue];
                }
                isSelected = YES;
            }
        }
        if (isSelected) {
            [custom setValue:@"YES" forKey:is_selected];
            [self.selectedOptionPrice setValue:[NSString stringWithFormat:@"%.2f", optionPrice] forKey:tempKey];
        }else{
            [self.selectedOptionPrice removeObjectForKey:tempKey];
            [custom setValue:@"NO" forKey:is_selected];
        }
    }
#pragma mark Bundle Option
    for (NSMutableDictionary *bundleItem in self.bundleItems) {
        CGFloat optionPrice = 0;
        NSString *tempKey = [bundleItem valueForKey:@"_id"];
        NSMutableArray *options = [self.bundleOptions valueForKey:tempKey];
        BOOL isSelected = NO;
        for (ProductOptionModel *opt in options) {
            if (opt.isSelected) {
                CGFloat optionQty = 1.0f;
                if ([[opt valueForKey:@"qty"] floatValue] > 0.01f) {
                    optionQty = [[opt valueForKey:@"qty"] floatValue];
                    
                }
                if ([[self.product valueForKey:@"sale_price_type"]boolValue]) {
                    if (DISPLAY_PRICES_INSHOP) {
                        optionPrice += optionQty *[[opt valueForKey:@"ex_price_include_tax"] floatValue];
                    }else
                    {
                        optionPrice += optionQty *[[opt valueForKey:@"ex_price"] floatValue];
                    }
                }else
                {
                    if ([opt valueForKey:@"price_include_tax"]&& DISPLAY_PRICES_INSHOP) {
                        if ([opt valueForKey:@"sale_price_include_tax"]) {
                            optionPrice += optionQty *[[opt valueForKey:@"sale_price_include_tax"] floatValue];
                        }else
                            optionPrice += optionQty *[[opt valueForKey:@"price_include_tax"] floatValue];
                    }else
                    {
                        if ([opt valueForKey:@"sale_price"]) {
                            optionPrice += optionQty *[[opt valueForKey:@"sale_price"] floatValue];
                        }else
                            optionPrice += optionQty *[[opt valueForKey:@"price"] floatValue];
                    }
                }
                isSelected = YES;
            }
        }
        if (isSelected) {
            [bundleItem setValue:@"YES" forKey:is_selected];
            [self.selectedOptionPrice setValue:[NSString stringWithFormat:@"%.2f", optionPrice] forKey:tempKey];
        }else{
            [self.selectedOptionPrice removeObjectForKey:tempKey];
            [bundleItem setValue:@"NO" forKey:is_selected];
        }
    }
#pragma mark Group Option
    for (ProductOptionModel *groupItem in self.groupOptions) {
        CGFloat optionPrice = 0;
        BOOL isSelected = NO;
        if (groupItem.isSelected) {
            CGFloat optionQty = 1.0f;
            if ([[groupItem valueForKey:@"option_qty"] floatValue] > 0.01f) {
                optionQty = [[groupItem valueForKey:@"option_qty"] floatValue];
                
            }
            if ([groupItem valueForKey:@"price_include_tax"]&& DISPLAY_PRICES_INSHOP) {
                if ([groupItem valueForKey:@"sale_price_include_tax"]) {
                    optionPrice += optionQty *[[groupItem valueForKey:@"sale_price_include_tax"] floatValue];
                }else
                    optionPrice += optionQty *[[groupItem valueForKey:@"price_include_tax"] floatValue];
            }else
            {
                if ([groupItem valueForKey:@"sale_price"]) {
                    optionPrice += optionQty *[[groupItem valueForKey:@"sale_price"] floatValue];
                }else
                    optionPrice += optionQty *[[groupItem valueForKey:@"price"] floatValue];
            }
            isSelected = YES;
        }
        if (isSelected) {
            [self.selectedOptionPrice setValue:[NSString stringWithFormat:@"%.2f", optionPrice] forKey:[groupItem valueForKey:@"_id"]];
        }else{
            [self.selectedOptionPrice removeObjectForKey:[groupItem valueForKey:@"_id"]];
        }
    }
    
    CGFloat totalOptionPrice = 0;
    switch (self.product.productType) {
        case ProductTypeGrouped:
        {
            for (NSMutableDictionary *groupItem in self.groupOptions) {
                NSString *tempKey = [groupItem valueForKey:@"_id"];
                if ([self.selectedOptionPrice valueForKey:tempKey]) {
                    totalOptionPrice += [[self.selectedOptionPrice valueForKey:tempKey] floatValue];
                }
            }
        }
            break;
        case ProductTypeSimple:
        {
            for (NSMutableDictionary *custom in self.customs) {
                NSString *tempKey = [custom valueForKey:@"_id"];
                if ([self.selectedOptionPrice valueForKey:tempKey]) {
                    totalOptionPrice += [[self.selectedOptionPrice valueForKey:tempKey] floatValue];
                }
            }
        }
            break;
        case ProductTypeConfigurable:
        {
            for (NSMutableDictionary *custom in self.customs) {
                NSString *tempKey = [custom valueForKey:@"_id"];
                if ([self.selectedOptionPrice valueForKey:tempKey]) {
                    totalOptionPrice += [[self.selectedOptionPrice valueForKey:tempKey] floatValue];
                }
            }
        }
            break;
        case ProductTypeBundle:
        {
            for (NSMutableDictionary *bundle in self.bundleItems) {
                NSString *tempKey = [bundle valueForKey:@"_id"];
                if ([self.selectedOptionPrice valueForKey:tempKey]) {
                    totalOptionPrice += [[self.selectedOptionPrice valueForKey:tempKey] floatValue];
                }
            }
        }
            break;
        default:
            break;
    }
    [self.product setValue:[NSString stringWithFormat:@"%.2f", totalOptionPrice] forKey:@"total_option_price"];
}
@end
