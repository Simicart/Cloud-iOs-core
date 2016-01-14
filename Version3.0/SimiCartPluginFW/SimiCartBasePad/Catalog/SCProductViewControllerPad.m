//
//  SCProductViewControllerPad.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/20/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SCProductViewControllerPad.h"
@interface SCProductViewControllerPad ()
{
    float imagePaddingLeft;
    float imagePaddingRight;
    float spaceBetweenTwoImage;
}
@end

@implementation SCProductViewControllerPad
- (void)viewDidLoadBefore
{
    [self configureNavigationBarOnViewDidLoad];
    [self configureLogo];
    
    heightViewAction = 50;
    heightNavigation = 64;
    imagePaddingLeft = 200;
    imagePaddingRight = 200;
    spaceBetweenTwoImage = 10;
    
    // Position action button
    widthLongButton = 424;
    widthShortButton = 200;
    paddingEdge = 300;
    spaceBetweenButton = 24;
    heightButton = 40;
    heightShadow = 1.5;
    cornerRadius = 4;
    
    self.arrayProductsView = [NSMutableArray new];
    self.heightScrollView = SCREEN_HEIGHT - heightNavigation;
    self.widthScrollView = 624;
    
    self.scrollViewProducts = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    [self.scrollViewProducts setContentSize:CGSizeMake(self.widthScrollView * self.arrayProductsID.count + imagePaddingLeft + imagePaddingRight, self.heightScrollView)];
    if(self.firstProductID == nil || [self.firstProductID isEqualToString:@""])
    {
        self.firstProductID = self.productId;
        self.arrayProductsID = [[NSMutableArray alloc]initWithArray:@[self.productId]];
    }
    
    if (self.arrayProductsID == nil) {
        self.arrayProductsID = [[NSMutableArray alloc]initWithArray:@[self.firstProductID]];
    }
    for (int i = 0; i < self.arrayProductsID.count; i++) {
        SCProductView *productView = [[SCProductView alloc]initWithFrame:CGRectMake(imagePaddingLeft + (self.widthScrollView) *i +  spaceBetweenTwoImage, 0, self.widthScrollView - spaceBetweenTwoImage*2, self.heightScrollView) productID:[self.arrayProductsID objectAtIndex:i]];
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
    [self.scrollViewProducts setDelegate:self];
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
    
    CGRect frame = self.view.frame;
    frame.origin.x = imagePaddingLeft;
    frame.size.width = self.widthScrollView;
    invisibleScrollView = [[UIScrollView alloc]initWithFrame:frame];
    [invisibleScrollView setContentSize:CGSizeMake(self.widthScrollView * self.arrayProductsID.count, self.heightScrollView)];
    
    [invisibleScrollView setDelegate:self];
    [invisibleScrollView setContentOffset:CGPointMake(self.currentIndexProductOnArray*self.widthScrollView, 0) animated:NO];
    invisibleScrollView.userInteractionEnabled = NO;
    invisibleScrollView.pagingEnabled = YES;
    [self.scrollViewProducts addGestureRecognizer:invisibleScrollView.panGestureRecognizer];
    [self.view addSubview:invisibleScrollView];
    
    [self addSideFog];
    [self viewToolBar];
    [self.view addSubview: self.viewToolBar];
    [self initViewAction];
    
    [self.viewAction setHidden:YES];
    [self.viewToolBar setHidden:YES];
    self.isFirtLoadProduct = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SCProductViewControllerPad_DidLoadBefore" object:self userInfo:@{@"viewAction": self.viewAction}];
}

#pragma mark SideFog
- (void) addSideFog
{
    if (leftFog == nil) {
        leftFog = [[UIView alloc]initWithFrame:CGRectMake(0, 0, imagePaddingLeft, self.heightScrollView)];
        [leftFog setBackgroundColor:THEME_CONTENT_COLOR];
        [leftFog setAlpha:0.1];
        [self.view addSubview:leftFog];
        
        rightFog = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - imagePaddingRight, 0, imagePaddingRight, self.heightScrollView)];
        [rightFog setBackgroundColor:THEME_CONTENT_COLOR];
        [rightFog setAlpha:0.1];
        [self.view addSubview:rightFog];
    }
    [leftFog setHidden:NO];
    [rightFog setHidden:NO];
}

- (void) removeSideFog
{
    [leftFog setHidden:YES];
    [rightFog setHidden:YES];
}

#pragma mark add Action views
- (void) initViewAction
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

#pragma mark ViewToolBar

- (UIView *)viewToolBar
{
    UIView * toolBar = [super viewToolBar];
    
    [self.labelProductName setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:18]];
    [self.labelProductName setText:self.labelProductName.text];
    [self.labelProductName setFrame:CGRectMake(250, 0, 524, 25)];
    [self.labelProductName setTextAlignment:NSTextAlignmentCenter];
    return  toolBar;
}

#pragma mark UIScroll View Delegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if((invisibleScrollView == scrollView)&&(!CGPointEqualToPoint(invisibleScrollView.contentOffset, currentScollviewContentOffset)))
    {
        currentScollviewContentOffset = invisibleScrollView.contentOffset;
        self.scrollViewProducts.contentOffset = invisibleScrollView.contentOffset;
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZThemeProductViewController_BeginChangeProduct" object:self];
    [self configureProductViewWithStatus:NO];
    self.currentIndexProductOnArray = (invisibleScrollView.contentOffset.x)/self.widthScrollView;
    for (int i = self.currentIndexProductOnArray - 1; i <= self.currentIndexProductOnArray + 1; i++) {
        if (i >= 0 && i < self.arrayProductsID.count) {
            SCProductView *currentShowProduct = (SCProductView*)[self.arrayProductsView objectAtIndex:i];
            if (!currentShowProduct.isGotProduct) {
                [currentShowProduct getProductDetail];
            }
        }
    }
    
    SCProductView *productView = [self.arrayProductsView objectAtIndex:self.currentIndexProductOnArray];
    if (productView.isDidGetProduct) {
        [self setProduct:productView.productModel];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZThemeProductViewControllerPad_DidChangeProduct" object:self];
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
        self.numberOfRequired = [self countNumberOfRequired];
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
        if (![[self.product valueForKey:@"manage_stock"] boolValue]) {
            [self.buttonAddToCart setTitle:SCLocalizedString(@"Out Stock") forState:UIControlStateNormal];
            [self.buttonAddToCart setEnabled:NO];
            [self.buttonAddToCart setAlpha:0.5];
            self.imageShadowAddToCart.alpha = 0.5;
        }
    }else
    {
        [self changeStateActionButtonWithState:NO];
    }
}

- (void)touchImage
{
    self.isShowOnlyImage = !self.isShowOnlyImage;
    if (self.isShowOnlyImage) {
        [self.viewToolBar setHidden:YES];
        [self.viewAction setHidden:YES];
        [self removeSideFog];
    }else
    {
        [self.viewToolBar setHidden:NO];
        [self.viewAction setHidden:NO];
        [self addSideFog];
    }
}

#pragma mark Set Price


- (void)setPrice
{
    self.lblRegularPrice.hidden = YES;
    self.lblSpecialPrice.hidden = YES;
    self.crossLine.hidden = YES;
    float priceRegular = 0;
    float priceSpecial = 0;
    float paddingTop = 25;
    CGRect frame = self.labelProductName.frame;
    frame.origin.y = paddingTop;
    switch (self.product.productType) {
#pragma mark Bundle
        case ProductTypeBundle:
        {
#pragma mark Fixed
            if ([[self.product valueForKey:@"sale_price_type"]boolValue]) {
                [self setNormalPrice];
#pragma mark Dynamic
            }else
            {
                if ([self.product valueForKey:@"total_option_price"]) {
                    priceRegular += [[self.product valueForKey:@"total_option_price"] floatValue];
                }
                [self.lblRegularPrice setText:[[SimiFormatter sharedInstance]priceWithPrice:[NSString stringWithFormat:@"%f", priceRegular]]];
                [self.lblRegularPrice setFrame:frame];
                [self.lblRegularPrice setTextAlignment:NSTextAlignmentCenter];
                [self.lblRegularPrice setHidden:NO];
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
                            if ([self.product valueForKey:@"total_option_price"]) {
                                priceRegular += [[self.product valueForKey:@"total_option_price"] floatValue];
                            }
                            priceRegular += [[variant valueForKey:@"price_include_tax"] floatValue];
                            [self.lblRegularPrice setText:[[SimiFormatter sharedInstance]priceWithPrice:[NSString stringWithFormat:@"%f", priceRegular]]];
                            [self.lblRegularPrice setFrame:frame];
                            [self.lblRegularPrice setTextAlignment:NSTextAlignmentCenter];
                            [self.lblRegularPrice setHidden:NO];
                            
                            if ([self.product valueForKey:@"sale_price_include_tax"]) {
                                NSString *salePriceInclude = [NSString stringWithFormat:@"%@",[variant valueForKey:@"sale_price_include_tax"]];
                                if (!([salePriceInclude floatValue] == [[variant valueForKey:@"price_include_tax"] floatValue])) {
                                    frame.size.width = frame.size.width/2 - 20;
                                    [self.lblRegularPrice setFrame:frame];
                                    [self.lblRegularPrice setTextAlignment:NSTextAlignmentRight];
                                    CGFloat priceWidth = [self.lblRegularPrice.text sizeWithAttributes:@{NSFontAttributeName:[self.lblRegularPrice font]}].width;
                                    [self.crossLine setFrame:CGRectMake(CGRectGetWidth(self.lblRegularPrice.frame) - priceWidth, CGRectGetHeight(self.lblRegularPrice.frame)/2, priceWidth, 1)];
                                    [self.crossLine setHidden:NO];
                                    
                                    
                                    if ([self.product valueForKey:@"total_option_price"]) {
                                        priceSpecial += [[self.product valueForKey:@"total_option_price"] floatValue];
                                    }
                                    
                                    priceSpecial += [[variant valueForKey:@"sale_price_include_tax"] floatValue];
                                    [self.lblSpecialPrice setText:[[SimiFormatter sharedInstance]priceWithPrice:[NSString stringWithFormat:@"%f", priceSpecial]]];
                                    [self.lblSpecialPrice setHidden:NO];
                                    frame = self.labelProductName.frame;
                                    frame.origin.y = paddingTop;
                                    frame.origin.x += frame.size.width/2 + 40;
                                    frame.size.width = frame.size.width/2 - 20;
                                    [self.lblSpecialPrice setFrame:frame];
                                    [self.lblSpecialPrice setTextAlignment:NSTextAlignmentLeft];
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
                            if ([self.product valueForKey:@"total_option_price"]) {
                                priceRegular += [[self.product valueForKey:@"total_option_price"] floatValue];
                            }
                            priceRegular += [[variant valueForKey:@"price"] floatValue];
                            [self.lblRegularPrice setText:[[SimiFormatter sharedInstance]priceWithPrice:[NSString stringWithFormat:@"%f", priceRegular]]];
                            [self.lblRegularPrice setFrame:frame];
                            [self.lblRegularPrice setTextAlignment:NSTextAlignmentCenter];
                            [self.lblRegularPrice setHidden:NO];
                            
                            if ([variant valueForKey:@"sale_price"]) {
                                NSString *salePriceInclude = [NSString stringWithFormat:@"%@",[variant valueForKey:@"sale_price"]];
                                if (!([salePriceInclude floatValue] == [[variant valueForKey:@"price"] floatValue])) {
                                    frame.size.width = frame.size.width/2 - 20;
                                    [self.lblRegularPrice setFrame:frame];
                                    [self.lblRegularPrice setTextAlignment:NSTextAlignmentRight];
                                    CGFloat priceWidth = [self.lblRegularPrice.text sizeWithAttributes:@{NSFontAttributeName:[self.lblRegularPrice font]}].width;
                                    [self.crossLine setFrame:CGRectMake(CGRectGetWidth(self.lblRegularPrice.frame) - priceWidth, CGRectGetHeight(self.lblRegularPrice.frame)/2, priceWidth, 1)];
                                    [self.crossLine setHidden:NO];
                                
                                    if ([self.product valueForKey:@"total_option_price"]) {
                                        priceSpecial += [[self.product valueForKey:@"total_option_price"] floatValue];
                                    }
                                    
                                    priceSpecial += [[variant valueForKey:@"sale_price"] floatValue];
                                    [self.lblSpecialPrice setText:[[SimiFormatter sharedInstance]priceWithPrice:[NSString stringWithFormat:@"%f", priceSpecial]]];
                                    [self.lblSpecialPrice setHidden:NO];
                                    frame = self.labelProductName.frame;
                                    frame.origin.y = paddingTop;
                                    frame.origin.x += frame.size.width/2 + 40;
                                    frame.size.width = frame.size.width/2 - 20;
                                    [self.lblSpecialPrice setFrame:frame];
                                    [self.lblSpecialPrice setTextAlignment:NSTextAlignmentLeft];
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
    float priceRegular = 0;
    float priceSpecial = 0;
    float paddingTop = 25;
    CGRect frame = self.labelProductName.frame;
    frame.origin.y = paddingTop;
    
    if ([self.product valueForKey:@"price_include_tax"] && DISPLAY_PRICES_INSHOP) {
        if ([self.product valueForKey:@"total_option_price"]) {
            priceRegular += [[self.product valueForKey:@"total_option_price"] floatValue];
        }
        priceRegular += [[self.product valueForKey:@"price_include_tax"] floatValue];
        [self.lblRegularPrice setText:[[SimiFormatter sharedInstance]priceWithPrice:[NSString stringWithFormat:@"%f", priceRegular]]];
        [self.lblRegularPrice setFrame:frame];
        [self.lblRegularPrice setTextAlignment:NSTextAlignmentCenter];
        [self.lblRegularPrice setHidden:NO];
        
        if ([self.product valueForKey:@"sale_price_include_tax"]) {
            NSString *salePriceInclude = [NSString stringWithFormat:@"%@",[self.product valueForKey:@"sale_price_include_tax"]];
            if (!([salePriceInclude floatValue] == [[self.product valueForKey:@"price_include_tax"] floatValue])) {
                frame.size.width = frame.size.width/2 - 20;
                [self.lblRegularPrice setFrame:frame];
                [self.lblRegularPrice setTextAlignment:NSTextAlignmentRight];
                CGFloat priceWidth = [self.lblRegularPrice.text sizeWithAttributes:@{NSFontAttributeName:[self.lblRegularPrice font]}].width;
                [self.crossLine setFrame:CGRectMake(CGRectGetWidth(self.lblRegularPrice.frame) - priceWidth, CGRectGetHeight(self.lblRegularPrice.frame)/2, priceWidth, 1)];
                [self.crossLine setHidden:NO];
                
                if ([self.product valueForKey:@"total_option_price"]) {
                    priceSpecial += [[self.product valueForKey:@"total_option_price"] floatValue];
                }
                
                priceSpecial += [[self.product valueForKey:@"sale_price_include_tax"] floatValue];
                [self.lblSpecialPrice setText:[[SimiFormatter sharedInstance]priceWithPrice:[NSString stringWithFormat:@"%f", priceSpecial]]];
                [self.lblSpecialPrice setHidden:NO];
                frame = self.labelProductName.frame;
                frame.origin.y = paddingTop;
                frame.origin.x += frame.size.width/2 + 40;
                frame.size.width = frame.size.width/2 - 20;
                [self.lblSpecialPrice setFrame:frame];
                [self.lblSpecialPrice setTextAlignment:NSTextAlignmentLeft];
            }
        }
        //  Liam Update RTL
        if([[SimiGlobalVar sharedInstance]isReverseLanguage])
        {
        }
        //  End RTL
        return;
    }
    
    if ([self.product valueForKey:@"price"]) {
        if ([self.product valueForKey:@"total_option_price"]) {
            priceRegular += [[self.product valueForKey:@"total_option_price"] floatValue];
        }
        priceRegular += [[self.product valueForKey:@"price"] floatValue];
        [self.lblRegularPrice setText:[[SimiFormatter sharedInstance]priceWithPrice:[NSString stringWithFormat:@"%f", priceRegular]]];
        [self.lblRegularPrice setFrame:frame];
        [self.lblRegularPrice setTextAlignment:NSTextAlignmentCenter];
        [self.lblRegularPrice setHidden:NO];
        
        if ([self.product valueForKey:@"sale_price"]) {
            NSString *salePriceInclude = [NSString stringWithFormat:@"%@",[self.product valueForKey:@"sale_price"]];
            if (!([salePriceInclude floatValue] == [[self.product valueForKey:@"price"] floatValue])) {
                frame.size.width = frame.size.width/2 - 20;
                [self.lblRegularPrice setFrame:frame];
                [self.lblRegularPrice setTextAlignment:NSTextAlignmentRight];
                CGFloat priceWidth = [self.lblRegularPrice.text sizeWithAttributes:@{NSFontAttributeName:[self.lblRegularPrice font]}].width;
                [self.crossLine setFrame:CGRectMake(CGRectGetWidth(self.lblRegularPrice.frame) - priceWidth, CGRectGetHeight(self.lblRegularPrice.frame)/2, priceWidth, 1)];
                [self.crossLine setHidden:NO];
                
                if ([self.product valueForKey:@"total_option_price"]) {
                    priceSpecial += [[self.product valueForKey:@"total_option_price"] floatValue];
                }
                
                priceSpecial += [[self.product valueForKey:@"sale_price"] floatValue];
                [self.lblSpecialPrice setText:[[SimiFormatter sharedInstance]priceWithPrice:[NSString stringWithFormat:@"%f", priceSpecial]]];
                [self.lblSpecialPrice setHidden:NO];
                frame = self.labelProductName.frame;
                frame.origin.y = paddingTop;
                frame.origin.x += frame.size.width/2 + 40;
                frame.size.width = frame.size.width/2 - 20;
                [self.lblSpecialPrice setFrame:frame];
                [self.lblSpecialPrice setTextAlignment:NSTextAlignmentLeft];
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


#pragma mark SCProductView Delegate
- (void)didGetProductDetailWithProductID:(NSString *)productID
{
    SCProductView *productView = [self.arrayProductsView objectAtIndex:self.currentIndexProductOnArray];
    if ([productView.productID isEqualToString:productID]) {
        if (self.isFirtLoadProduct) {
            [self.viewToolBar setHidden:NO];
            [self.viewAction setHidden:NO];
            self.isFirtLoadProduct = NO;
        }
        [self setProduct:productView.productModel];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ZThemeProductViewControllerPad_DidGetProduct" object:self];
    }
}


#pragma mark Selection & Add To Cart
- (void)buttonSelectOptionTouch:(id)sender
{
    [self changeStateActionButtonWithState:NO];
    UIButton *buttonSelectOption = (UIButton*)sender;
    if (self.optionViewController == nil) {
        self.optionViewController = [SCProductOptionViewController new];
        self.optionViewController.tableViewOption.showsVerticalScrollIndicator = NO;
        self.optionViewController.delegate = self;
    }
    self.optionViewController.variants = self.variants;
    self.optionViewController.variantsAllKey = self.variantsAllKey;
    self.optionViewController.variantOptions = self.variantOptions;
    self.optionViewController.product = self.product;
    self.optionViewController.selectedOptionPrice = self.selectedOptionPrice;
    self.optionViewController.variantSelectedKey = self.variantSelectedKey;
    
    self.optionViewController.customOptions = self.customOptions;
    self.optionViewController.customs = self.customs;
    
    self.optionViewController.bundleItems = self.bundleItems;
    self.optionViewController.bundleOptions = self.bundleOptions;
    
    self.optionViewController.groupOptions = self.groupOptions;
    
    [self.optionViewController setCells:nil];
    
    if(productOptionPopOver == nil){
        productOptionPopOver = [[UIPopoverController alloc]initWithContentViewController:self.optionViewController];
    }
    
    [productOptionPopOver presentPopoverFromRect:buttonSelectOption.bounds inView:buttonSelectOption permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    productOptionPopOver.delegate = self;
}

- (void)close:(id)sender
{
    [productOptionPopOver dismissPopoverAnimated:YES];
}
#pragma mark UIPopView Controller
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self changeStateActionButtonWithState:YES];
}

#pragma mark Action Touch Button

- (void)didTouchDetailButton:(id)sender
{
    UIButton *moreDetailButton = (UIButton*)sender;
    if (self.hadCurrentProductModel) {
        SCProductMoreViewController *moreViewController = [SCProductMoreViewController new];
        moreViewController.productModel = self.product;
        moreViewController.delegate = self;
        
        UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:moreViewController];
        self.popover = [[UIPopoverController alloc]initWithContentViewController:navi];
        self.popover.delegate = self;
        [self.popover presentPopoverFromRect:moreDetailButton.bounds inView:moreDetailButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

#pragma mark SCMore View Controller Delegate
- (void)didSelectRelateProductWithProductID:(NSString *)productID arrayProduct:(NSMutableArray *)arrayID
{
    [self.popover dismissPopoverAnimated:YES];
    SCProductViewControllerPad *productViewController = [SCProductViewControllerPad new];
    productViewController.firstProductID = productID;
    productViewController.arrayProductsID = arrayID;
    [self.navigationController pushViewController:productViewController animated:YES];
}
@end
