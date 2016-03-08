//
//  SCProductListCell.m
//  SimiCart
//
//  Created by Tan on 4/30/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import "SCProductListCell.h"
#import "SimiFormatter.h"
#import "UILabelDynamicSize.h"
#import "NSString+HTML.h"
static NSString* PRODUCTLISTCELL_LABEL = @"PRODUCTLISTCELL_LABEL";
static NSString* PRODUCTLISTCELL_PRICE = @"PRODUCTLISTCELL_PRICE";

@interface SCProductListCell()

@end

@implementation SCProductListCell
@synthesize showPriceV2;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier product:(SimiProductModel*)productModel
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _product = productModel;
        self.productName = [_product valueForKeyPath:@"name"];
        if ([_product valueForKey:@"images"] && [[_product valueForKey:@"images"] isKindOfClass:[NSArray class]]) {
            NSMutableArray *arrayImage = [[NSMutableArray alloc]initWithArray:[_product valueForKey:@"images"]];
            if (arrayImage.count > 0) {
                self.imagePath = [[arrayImage objectAtIndex:0]valueForKey:@"url"];
            }
        }else
        {
            _productImageView = [UIImageView new];
            _productImageView.contentMode = UIViewContentModeScaleAspectFit;
            _productImageView.layer.borderWidth = 1;
            _productImageView.layer.borderColor = THEME_IMAGE_BORDER_COLOR.CGColor;
            [self.productImageView setImage:[UIImage imageNamed:@"logo"]];
        }
        self.stockStatus = YES;
        if ([self.product valueForKey:@"price"]) {
            self.regularPrice = [NSString stringWithFormat:@"%@",[self.product valueForKey:@"price"]];
        }
        if ([self.product valueForKey:@"sale_price"] && [[self.product valueForKey:@"sale_price"] floatValue] <  [[self.product valueForKey:@"price"] floatValue]) {
            NSString *salePrice = [NSString stringWithFormat:@"%@",[self.product valueForKey:@"sale_price"]];
            if (![salePrice isEqualToString:@""] && ![salePrice isEqualToString:self.regularPrice]) {
                self.specialPrice = salePrice;
            }
        }
        [self setInterfaceCell];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark overide Set Property

- (void)setProductName:(NSString *)productName
{
    _productName = productName;
    _productNameLabel = [UILabel new];
    [_productNameLabel setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:15]];
    [_productNameLabel setText:_productName];
    [_productNameLabel setTextColor:THEME_CONTENT_COLOR];
}

- (void)setImagePath:(NSString *)imagePath
{
    _imagePath = imagePath;
    _productImageView = [UIImageView new];
    [_productImageView sd_setImageWithURL:[NSURL URLWithString:_imagePath] placeholderImage:[UIImage imageNamed:@"logo"]];
    _productImageView.contentMode = UIViewContentModeScaleAspectFit;
    _productImageView.layer.borderWidth = 1;
    _productImageView.layer.borderColor = THEME_IMAGE_BORDER_COLOR.CGColor;
}

- (void)setRegularPrice:(NSString *)regularPrice
{
    _regularPrice = regularPrice;
    _regularPriceLabel = [UILabel new];
    _regularPriceLabel.text = [[SimiFormatter sharedInstance] priceWithPrice:_regularPrice];
    [_regularPriceLabel setTextColor:THEME_PRICE_COLOR];
    _regularPriceLabel.simiObjectName = PRODUCTLISTCELL_PRICE;
}

- (void)setSpecialPrice:(NSString *)specialPrice
{
    _specialPrice = specialPrice;
    _specialPriceLabel = [UILabel new];
    _specialPriceLabel.text = [[SimiFormatter sharedInstance] priceWithPrice:_specialPrice];
    [_specialPriceLabel setTextColor:THEME_SPECIAL_PRICE_COLOR];
    _specialPriceLabel.simiObjectName = PRODUCTLISTCELL_PRICE;
}

- (void)setStockStatus:(BOOL)stockStatus
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
#pragma mark Set Interface
- (void)setInterfaceCell
{
    float imageOrigionX = SCREEN_WIDTH/20;
    float imageOrigionY = 0.0;
    if(SIMI_SYSTEM_IOS >=8){
        imageOrigionY = [SimiGlobalVar scaleValue:15];
    }else{
        imageOrigionY = [SimiGlobalVar scaleValue:18];
    }
   
    float sizeImage = [SimiGlobalVar scaleValue:75];
    float labelTitleX = [SimiGlobalVar scaleValue:5] + imageOrigionX + sizeImage;
    float labelValueWidth = SCREEN_WIDTH - labelTitleX - [SimiGlobalVar scaleValue:25];
    float spaceLabel = 5;
    float heightLabel = 20;
    float sizeImageStock = 41.5;
     //gin edit
    float padding;
    if ([[SimiGlobalVar sharedInstance] isReverseLanguage]) {
        padding = SCREEN_WIDTH/20 ;
        imageOrigionX = SCREEN_WIDTH - sizeImage - padding;
        labelValueWidth = imageOrigionX- 2*padding ;
        labelTitleX = imageOrigionX - labelValueWidth - 20;
    }
    //end
    [_productImageView setFrame:CGRectMake(imageOrigionX, imageOrigionY, sizeImage, sizeImage)];
    //gin edit
    if([[SimiGlobalVar sharedInstance] isReverseLanguage]){
        [_productImageView setFrame:CGRectMake(imageOrigionX - [SimiGlobalVar scaleValue:10] , imageOrigionY, sizeImage, sizeImage)];
    }
    //end
    [self addSubview:_productImageView];
    if (_lblStockStatus) {
        [_imageStockStatus setFrame:CGRectMake(sizeImage - sizeImageStock, sizeImage - sizeImageStock, sizeImageStock, sizeImageStock)];
        [_productImageView addSubview:_imageStockStatus];
        [_lblStockStatus setFrame:CGRectMake(sizeImage - sizeImageStock - 2, sizeImage - 25, sizeImageStock * 1.4, 14)];
        [_lblStockStatus setBackgroundColor:[UIColor clearColor]];
        [_lblStockStatus setTransform:CGAffineTransformMakeRotation(- M_PI_4)];
        [_lblStockStatus setTextAlignment:NSTextAlignmentCenter];
        [_productImageView addSubview:_lblStockStatus];
    }
    
    [_productNameLabel setFrame:CGRectMake(labelTitleX, imageOrigionY - 2, SCREEN_WIDTH - labelTitleX - 15 , heightLabel)];
    
    //gin edit
    if([[SimiGlobalVar sharedInstance] isReverseLanguage]){
        [_productNameLabel setFrame:CGRectMake(labelTitleX, imageOrigionY - 2, SCREEN_WIDTH - sizeImage - 2*padding - 15, heightLabel)];
    }
    //end
    [_productNameLabel resizLabelToFit];
    CGRect frame = _productNameLabel.frame;
    if (CGRectGetHeight(frame) > 40) {
        frame.size.height = 40;
        [_productNameLabel setFrame:frame];
        _productNameLabel.numberOfLines = 2;
    }
    
    self.heightCell = _productNameLabel.frame.origin.y + CGRectGetHeight(_productNameLabel.frame) + spaceLabel;
    [self addSubview:_productNameLabel];
    if (_regularPriceLabel) {
        [_regularPriceLabel setFrame:CGRectMake(labelTitleX, self.heightCell, labelValueWidth, heightLabel)];
        [self addSubview:_regularPriceLabel];
        self.heightCell += heightLabel;
    }
    if (_specialPriceLabel) {
        [_specialPriceLabel setFrame:CGRectMake(labelTitleX, self.heightCell, labelValueWidth, heightLabel)];
        [self addSubview:_specialPriceLabel];
        CGFloat regularTextWidth = [_regularPriceLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:THEME_FONT_NAME size:15]}].width;
        float imageLineWidth;
        if(regularTextWidth < labelValueWidth)
            imageLineWidth = regularTextWidth;
        else
            imageLineWidth = labelValueWidth;
        UIImageView *imageLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, heightLabel/2, imageLineWidth, 1)];
        //gin edit
        if([[SimiGlobalVar sharedInstance] isReverseLanguage]){
            [imageLine setFrame:CGRectMake(labelTitleX +labelValueWidth - regularTextWidth - padding, heightLabel/2, imageLineWidth, 1)];
        }
        //end
        [imageLine setBackgroundColor:THEME_PRICE_COLOR];
        [_regularPriceLabel addSubview:imageLine];
        self.heightCell += heightLabel;
    }
    if(SIMI_SYSTEM_IOS >=8){
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel*)view;
                if ([label.simiObjectName isEqualToString:PRODUCTLISTCELL_PRICE]) {
                    [label setFont:[UIFont fontWithName:THEME_FONT_NAME size:15]];
                    [label setTextColor:THEME_PRICE_COLOR];
                }else if([label.simiObjectName isEqualToString:PRODUCTLISTCELL_LABEL])
                {
                    [label setFont:[UIFont fontWithName:THEME_FONT_NAME size:15]];
                    [label setTextColor:[UIColor darkGrayColor]];
                }
                //gin edit
                if([[SimiGlobalVar sharedInstance] isReverseLanguage]){
                    [label setTextAlignment:NSTextAlignmentRight];
                }
                //end
            }
        }
    }else{
        // May start edited 20151022
        for (UIView *view in self.contentView.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel*)view;
                if ([label.simiObjectName isEqualToString:PRODUCTLISTCELL_PRICE]) {
                    [label setFont:[UIFont fontWithName:THEME_FONT_NAME size:15]];
                    [label setTextColor:THEME_PRICE_COLOR];
                }else if([label.simiObjectName isEqualToString:PRODUCTLISTCELL_LABEL])
                {
                    [label setFont:[UIFont fontWithName:THEME_FONT_NAME size:15]];
                    [label setTextColor:[UIColor darkGrayColor]];
                }
                if([[SimiGlobalVar sharedInstance] isReverseLanguage]){
                    [label setTextAlignment:NSTextAlignmentRight];
                }
            }
        }
        // May end 20151022
    }
}

// May start edited 20151022
-(void)addSubview:(UIView *)view{
    if (SIMI_SYSTEM_IOS>=8) {
        [super addSubview:view];
    }else{
        [self.contentView addSubview:view];
    }
}
//May end 20151022

@end
     
