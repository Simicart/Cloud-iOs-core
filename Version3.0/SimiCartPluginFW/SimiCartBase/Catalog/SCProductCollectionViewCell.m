//
//  SCProductCollectionViewCell.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/8/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SCProductCollectionViewCell.h"

@implementation SCProductCollectionViewCell
{
    float sizeFontPrice;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark
#pragma mark setProduct
- (void)cusSetProductModel:(SimiProductModel *)productModel_{
    sizeFontPrice = 15;
    NSString *viewIdentifier = @"SCProductCollectionCell_SubView";
    if (self.isChangeLayOut) {
        [self setInterfaceCell];
    }
    if (![self.productModel isEqual:productModel_]) {
        self.productModel = productModel_;
        self.imageProduct = [UIImageView new];
        self.imageProduct.simiObjectIdentifier = viewIdentifier;
        if ([self.productModel valueForKey:@"images"] && [[self.productModel valueForKey:@"images"] isKindOfClass:[NSArray class]]) {
            NSMutableArray *arrayImage = [[NSMutableArray alloc]initWithArray:[self.productModel valueForKey:@"images"]];
            if (arrayImage.count > 0) {
                [self.imageProduct sd_setImageWithURL:[NSURL URLWithString:[[arrayImage objectAtIndex:0]valueForKey:@"url"]]placeholderImage:[UIImage imageNamed:@"logo"]];
            }
        }else
            [self.imageProduct setImage:[UIImage imageNamed:@"logo"]];
        self.imageProduct.contentMode = UIViewContentModeScaleAspectFit;
        [self.imageProduct.layer setBorderWidth:1];
        [self.imageProduct.layer setBorderColor:THEME_IMAGE_BORDER_COLOR.CGColor];
        [self addSubview:self.imageProduct];
        
        [self.imageProduct setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageProduct attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageProduct attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
        
        self.lblNameProduct = [UILabel new];
        self.lblNameProduct.simiObjectIdentifier = viewIdentifier;
        [self.lblNameProduct setFont:[UIFont fontWithName:THEME_FONT_NAME size:sizeFontPrice]];
        [self.lblNameProduct setTextColor:THEME_CONTENT_COLOR];
        [self.lblNameProduct setText:[self.productModel valueForKey:@"name"]];
        [self.lblNameProduct setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.lblNameProduct];
        
        [self cusSetStockStatus:[[self.productModel valueForKey:@"manage_stock"] boolValue]];
        [self setPrice];
        [self setInterfaceCell];
    }
}

- (void)setPrice
{
    if ([self.productModel valueForKey:@"price"]) {
        [self cusSetStringPriceRegular: [NSString stringWithFormat:@"%@",[self.productModel valueForKey:@"price"]]];
    }
    if ([self.productModel valueForKey:@"sale_price"]) {
        NSString *salePrice = [NSString stringWithFormat:@"%@",[self.productModel valueForKey:@"sale_price"]];
        if (![salePrice isEqualToString:@""] && ![salePrice isEqualToString:self.stringPriceRegular]) {
            [self cusSetStringPriceSpecial:salePrice];
        }
    }
}

- (void)setInterfaceCell
{
    float maximumImageSize = 152.5;
    float heightLabel = 20;
    if (self.isShowOnlyImage) {
        for (UIView *subview in self.subviews) {
            if(![subview isKindOfClass:[UIImageView class]])
            {
                [subview setHidden:YES];
            }
        }
        [self.imageStockStatus setHidden:YES];
        return;
    }else
    {
        for (UIView *subview in self.subviews) {
            [subview setHidden:NO];
        }
        [self.imageStockStatus setHidden:NO];
    }
    
    if (self.lblStockStatus) {
        float sizeImageStock = 41.5;
        [_imageStockStatus setFrame:CGRectMake([SimiGlobalVar scaleValue:maximumImageSize] - sizeImageStock, [SimiGlobalVar scaleValue:maximumImageSize] - sizeImageStock, sizeImageStock, sizeImageStock)];
        [_lblStockStatus setFrame:CGRectMake([SimiGlobalVar scaleValue:maximumImageSize] - sizeImageStock - 2, [SimiGlobalVar scaleValue:maximumImageSize] - 25, sizeImageStock * 1.4, 14)];
        [_lblStockStatus setBackgroundColor:[UIColor clearColor]];
        [_lblStockStatus setTransform:CGAffineTransformMakeRotation(- M_PI_4)];
        [_lblStockStatus setTextAlignment:NSTextAlignmentCenter];
        [self.imageProduct addSubview:self.imageStockStatus];
        [self.imageProduct addSubview:self.lblStockStatus];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidDrawProductImageView" object:self.imageProduct userInfo:@{@"imageView": self.imageProduct, @"product": self.productModel}];
    
    [self.lblNameProduct setFrame:[SimiGlobalVar scaleFrame:CGRectMake(0, maximumImageSize, maximumImageSize, heightLabel)]];
    //  gin edit RTL
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        [self.lblNameProduct setTextAlignment:NSTextAlignmentRight];
        [self.lblNameProduct setLineBreakMode:NSLineBreakByTruncatingHead];
    }
    //  End RTL
    if (self.lblExcl && self.lblIncl) {
        [self.lblExcl setFrame:[SimiGlobalVar scaleFrame:CGRectMake(0, maximumImageSize + heightLabel, maximumImageSize/2, heightLabel)]];
        [self.lblIncl setFrame:[SimiGlobalVar scaleFrame:CGRectMake(maximumImageSize/2, maximumImageSize + heightLabel, maximumImageSize/2, heightLabel)]];
        CGFloat priceWidth = [self.lblExcl.text sizeWithAttributes:@{NSFontAttributeName:[self.lblExcl font]}].width;
        if(priceWidth > maximumImageSize/2)
            priceWidth = maximumImageSize/2;
        self.viewLine = [[UIView alloc]initWithFrame:CGRectMake(0, [SimiGlobalVar scaleValue:heightLabel/2], priceWidth, 1)];
        self.viewLine.backgroundColor = THEME_PRICE_COLOR;
        //  gin edit RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [self.lblExcl setTextAlignment:NSTextAlignmentRight];
            [self.lblIncl setTextAlignment:NSTextAlignmentRight];
            [self.viewLine setFrame:CGRectMake(CGRectGetWidth(self.lblExcl.frame) - priceWidth,[SimiGlobalVar scaleValue:heightLabel/2], priceWidth, 1)];
        }
        //  End RTL
        [self addSubview:self.lblExcl];
        [self addSubview:self.lblIncl];
        [self.lblExcl addSubview:self.viewLine];
        return;
    }
    
    if (self.lblExcl) {
        [self.lblExcl setFrame:[SimiGlobalVar scaleFrame:CGRectMake(0, maximumImageSize + heightLabel, maximumImageSize, heightLabel)]];
        [self addSubview:self.lblExcl];
        //  gin edit RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [self.lblExcl setTextAlignment:NSTextAlignmentRight];
        }
        //  End RTL

        return;
    }
    
    if (self.lblInclPrice) {
        [self.lblInclPrice setFrame:[SimiGlobalVar scaleFrame:CGRectMake(0, maximumImageSize + heightLabel, maximumImageSize, heightLabel)]];
        [self addSubview:self.lblInclPrice];
        //  gin edit RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [self.lblInclPrice setTextAlignment:NSTextAlignmentRight];
        }
        //  End RTL
        return;
    }
   
}

- (void)cusSetStringPriceRegular:(NSString *)stringPriceRegular_
{
    if (![stringPriceRegular_ isEqualToString:@""]) {
        self.lblExcl = [[UILabel alloc]init];
        [self.lblExcl setFont:[UIFont fontWithName:THEME_FONT_NAME size:sizeFontPrice]];
        self.lblExcl.textColor = THEME_PRICE_COLOR;
        self.stringPriceRegular = stringPriceRegular_;
        self.lblExcl.text = [[SimiFormatter sharedInstance]priceWithPrice:self.stringPriceRegular];
    }
}

- (void)cusSetStringPriceSpecial:(NSString *)stringPriceSpecial_
{
    if (![stringPriceSpecial_ isEqualToString:@""]) {
        self.lblIncl = [[UILabel alloc]init];
        [self.lblIncl setFont:[UIFont fontWithName:THEME_FONT_NAME size:sizeFontPrice]];
        self.lblIncl.textColor = THEME_PRICE_COLOR;
        self.stringPriceSpecial = stringPriceSpecial_;
        self.lblIncl.text = [[SimiFormatter sharedInstance] priceWithPrice:self.stringPriceSpecial];
    }
}

- (void)cusSetStockStatus:(BOOL)stockStatus
{
    _stockStatus = stockStatus;
    if (!_stockStatus) {
        _lblStockStatus = [UILabel new];
        [_lblStockStatus setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:6]];
        [_lblStockStatus setTextColor:THEME_OUT_STOCK_TEXT_COLOR];
        [_lblStockStatus setText:[SCLocalizedString(@"Out Stock") uppercaseString]];
        
        _imageStockStatus = [UIImageView new];
        [_imageStockStatus setImage:[UIImage imageNamed:@"stockstatus_background"]];
    }
}
@end
