//
//  SCProductInfoView.m
//  SimiCart
//
//  Created by Tan on 7/4/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import "SCProductInfoView.h"
#import "NSString+HTML.h"
#import "SimiFormatter.h"
#import "UILabelDynamicSize.h"
#import "SCWebViewController.h"
#include "SCAppDelegate.h"

@implementation SCProductInfoView
{
    float sizeFontPrice;
    float sizeFontName;
    float sizeFontDescription;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil {
    NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:nibNameOrNil owner:self options:nil];
    self = [nibObjects objectAtIndex:0];
    return self;
}

- (void)setProduct:(SimiProductModel *)product
{
    _product = product;
    sizeFontPrice = 16;
    sizeFontName = 18;
    sizeFontDescription = 16;
    self.productName = [_product valueForKey:@"name"];
    self.shortDescription = [_product valueForKey:@"short_description"]?[[self.product valueForKey:@"short_description"] stringByConvertingHTMLToPlainText] : @"";
//    self.stockStatus = [_product valueForKey:@"manage_stock"];
    self.stockStatus = @"1";
    float total_option_price = 0;
    if ([_product valueForKey:@"total_option_price"]) {
        total_option_price = [[_product valueForKey:@"total_option_price"]floatValue];
    }
    if (![self.variantSelectedKey isEqualToString:@""] && self.variantSelectedKey != nil) {
        for (NSMutableDictionary *variant in self.variants) {
            if ([[variant valueForKey:@"_id"] isEqualToString:self.variantSelectedKey]) {
                if ([variant valueForKey:@"total_option_price"]) {
                    total_option_price = [[variant valueForKey:@"total_option_price"]floatValue];
                }
                if ([variant valueForKey:@"sale_price_include_tax"]) {
                    float specialPriceTax = [[variant valueForKey:@"sale_price_include_tax"]floatValue] + total_option_price;
                    self.specialPriceIncludeTax = [NSString stringWithFormat:@"%0.2f",specialPriceTax];
                }
                if ([variant valueForKey:@"price_include_tax"]) {
                    float priceTax = [[variant valueForKey:@"price_include_tax"]floatValue] + total_option_price;
                    self.regularPriceIncludeTax = [NSString stringWithFormat:@"%0.2f",priceTax];
                }
                if ([variant valueForKey:@"sale_price"]) {
                    float salePrice = [[variant valueForKey:@"sale_price"]floatValue] + total_option_price;
                    self.specialPrice = [NSString stringWithFormat:@"%0.2f",salePrice];
                }
                if ([variant valueForKey:@"price"]) {
                    float price = [[variant valueForKey:@"price"]floatValue] + total_option_price;
                    self.regularPrice = [NSString stringWithFormat:@"%0.2f",price];
                }
            }
        }
    }else
    {
        if ([_product valueForKey:@"sale_price_include_tax"]) {
            float specialPriceTax = [[_product valueForKey:@"sale_price_include_tax"]floatValue] + total_option_price;
            self.specialPriceIncludeTax = [NSString stringWithFormat:@"%0.2f",specialPriceTax];
        }
        if ([_product valueForKey:@"price_include_tax"]) {
            float priceTax = [[_product valueForKey:@"price_include_tax"]floatValue] + total_option_price;
            self.regularPriceIncludeTax = [NSString stringWithFormat:@"%0.2f",priceTax];
        }
        if ([_product valueForKey:@"sale_price"]) {
            float salePrice = [[_product valueForKey:@"sale_price"]floatValue] + total_option_price;
            self.specialPrice = [NSString stringWithFormat:@"%0.2f",salePrice];
        }
        if ([_product valueForKey:@"price"]) {
            float price = [[_product valueForKey:@"price"]floatValue] + total_option_price;
            self.regularPrice = [NSString stringWithFormat:@"%0.2f",price];
        }
    }
    [self setInterfaceCell];
}

- (void)setProductName:(NSString *)productName
{
    _productName = productName;
    self.productNameLabel.text = _productName;
}

- (void)setStockStatus:(NSString *)stockStatus
{
    _stockStatus = stockStatus;
    if ([_stockStatus boolValue]) {
        self.stockStatusLabel.text = SCLocalizedString(@"In Stock");
    }else
        self.stockStatusLabel.text = SCLocalizedString(@"Out Stock");
}

- (void)setShortDescription:(NSString *)shortDescription
{
    _shortDescription = shortDescription;
}

- (void)setSpecialPriceIncludeTax:(NSString *)specialPriceIncludeTax
{
    _specialPriceIncludeTax = specialPriceIncludeTax;
    self.specialPriceIncludeTaxLabel = [UILabel new];
    self.specialPriceIncludeTaxLabel.text = [[SimiFormatter sharedInstance] priceWithPrice:_specialPriceIncludeTax];
    self.specialPriceIncludeTaxLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:sizeFontPrice];
    self.specialPriceIncludeTaxLabel.textColor = THEME_SPECIAL_PRICE_COLOR;
}

- (void)setRegularPriceIncludeTax:(NSString *)regularPriceIncludeTax
{
    _regularPriceIncludeTax = regularPriceIncludeTax;
    self.regularPriceIncludeTaxLabel = [UILabel new];
    self.regularPriceIncludeTaxLabel.text = [[SimiFormatter sharedInstance] priceWithPrice:_regularPriceIncludeTax];
    self.regularPriceIncludeTaxLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:sizeFontPrice];
    self.regularPriceIncludeTaxLabel.textColor = THEME_PRICE_COLOR;

}

- (void)setRegularPrice:(NSString *)regularPrice
{
    _regularPrice = regularPrice;
    self.regularPriceLabel = [UILabel new];
    self.regularPriceLabel.text = [[SimiFormatter sharedInstance]priceWithPrice:_regularPrice];
    self.regularPriceLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:sizeFontPrice];
    self.regularPriceLabel.textColor = THEME_PRICE_COLOR;
}

- (void)setSpecialPrice:(NSString *)specialPrice
{
    _specialPrice = specialPrice;
    self.specialPriceLabel = [UILabel new];
    self.specialPriceLabel.text = [[SimiFormatter sharedInstance] priceWithPrice:_specialPrice];
    self.specialPriceLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:sizeFontPrice];
    self.specialPriceLabel.textColor = THEME_SPECIAL_PRICE_COLOR;
}

#pragma mark Set Interface
- (void)setInterfaceCell
{
    self.heightCell = 5;
    float widthSize = SCREEN_WIDTH;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        widthSize = SCREEN_WIDTH *2/3;
    }
    float origionTitleX = 15;
    float widthTitle = 120;
    float origionValueX = origionTitleX + widthTitle;
    float widthValue = widthSize - origionValueX - 15;
    float heightLabel = 20;
    float heightLabelWithDistance = 20;
    float widthText = widthSize - 30;
    
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        widthTitle = 200;
        origionTitleX = widthSize - widthTitle - 30;
        origionValueX = 15;
        widthValue = origionTitleX - origionValueX;
    }
    
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *lblView = (UILabel*)subview;
                [lblView removeFromSuperview];
        }
    }
    
    if(self.productName){
        self.productNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthText, heightLabel)];
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [self.productNameLabel setFrame:CGRectMake(0, self.heightCell, widthText, heightLabel)];
        }
        self.productNameLabel.text = self.productName;
        self.productNameLabel.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:sizeFontName];
        self.productNameLabel.textColor = THEME_CONTENT_COLOR;
        [self.productNameLabel resizLabelToFit];
        [self addSubview:self.productNameLabel];
        self.heightCell += CGRectGetHeight(self.productNameLabel.frame);
    }
    
    if(self.stockStatus){
        self.stockStatusLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthText, heightLabel)];
        if([self.stockStatus boolValue]){
            self.stockStatusLabel.text = SCLocalizedString(@"In Stock");
        }else{
            self.stockStatusLabel.text = SCLocalizedString(@"Out Stock");
        }
        self.stockStatusLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:sizeFontPrice];
        self.stockStatusLabel.textColor = THEME_TEXT_COLOR;
        [self addSubview:self.stockStatusLabel];
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [self.stockStatusLabel setFrame:CGRectMake(0, self.heightCell, widthText, heightLabel)];
        }
        self.heightCell += heightLabelWithDistance + 3;
    }
    
    if (![self.variantSelectedKey isEqualToString:@""] && self.variantSelectedKey != nil) {
        for (NSMutableDictionary *variant in self.variants) {
            if ([[variant valueForKey:@"_id"] isEqualToString:self.variantSelectedKey]) {
                if ([variant valueForKey:@"price_include_tax"] && [variant valueForKey:@"sale_price_include_tax"] && [[variant valueForKey:@"sale_price_include_tax"]floatValue] < [[variant valueForKey:@"price_include_tax"]floatValue]) {
                    self.regularTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                    self.regularTitleLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Regular Price")];
                    self.regularTitleLabel.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:sizeFontPrice];
                    self.regularTitleLabel.textColor = THEME_TEXT_COLOR;
                    [self addSubview:self.regularTitleLabel];
                    [self.regularPriceIncludeTaxLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                    [self addSubview:self.regularPriceIncludeTaxLabel];
                    
                    //Set Strike Through for Regular Price
                    CGFloat priceWidth = [self.regularPriceIncludeTaxLabel.text sizeWithAttributes:@{NSFontAttributeName:self.regularPriceIncludeTaxLabel.font}].width;
                    UIView *throughLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.regularPriceIncludeTaxLabel.frame.size.height/2, priceWidth, 1)];
                    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                        [throughLine setFrame:CGRectMake(CGRectGetWidth(self.regularPriceIncludeTaxLabel.frame) - priceWidth, self.regularPriceIncludeTaxLabel.frame.size.height/2, priceWidth, 1)];
                    }
                    throughLine.backgroundColor = THEME_PRICE_COLOR;
                    CGRect frame = throughLine.frame;
                    frame.origin.y = frame.size.height/2;
                    frame.size.height = 1;
                    [self.regularPriceIncludeTaxLabel addSubview:throughLine];
                    self.heightCell += heightLabelWithDistance;
                    
                    self.specialTitlelabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                    self.specialTitlelabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Special Price")];
                    self.specialTitlelabel.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:sizeFontPrice];
                    self.specialTitlelabel.textColor = THEME_TEXT_COLOR;
                    [self addSubview:self.specialTitlelabel];
                    self.heightCell += heightLabelWithDistance;
                    
                    self.specialLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                    self.specialLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Excl. Tax")];
                    self.specialLabel.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:sizeFontPrice];
                    self.specialLabel.textColor = THEME_TEXT_COLOR;
                    [self addSubview:self.specialLabel];
                    
                    [self.specialPriceLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                    [self addSubview:self.specialPriceLabel];
                    self.heightCell += heightLabelWithDistance;
                    
                    self.specialIncludeTaxLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                    self.specialIncludeTaxLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Incl. Tax")];
                    self.specialIncludeTaxLabel.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:sizeFontPrice];
                    self.specialIncludeTaxLabel.textColor = THEME_TEXT_COLOR;
                    [self addSubview:self.specialIncludeTaxLabel];
                    
                    [self.specialPriceIncludeTaxLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                    [self addSubview:self.specialPriceIncludeTaxLabel];
                    self.heightCell += heightLabelWithDistance;
                }else if ([variant valueForKey:@"price_include_tax"] && [[variant valueForKey:@"price_include_tax"]floatValue] > [[variant valueForKey:@"price"]floatValue])
                {
                    self.regularLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                    self.regularLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Excl. Tax")];
                    self.regularLabel.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:sizeFontPrice];
                    self.regularLabel.textColor = THEME_TEXT_COLOR;
                    [self addSubview:self.regularLabel];
                    
                    [self.regularPriceLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                    [self addSubview:self.regularPriceLabel];
                    self.heightCell += heightLabelWithDistance;
                    
                    self.regularIncludeTaxLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
                    self.regularIncludeTaxLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Incl. Tax")];
                    self.regularIncludeTaxLabel.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:sizeFontPrice];
                    self.regularIncludeTaxLabel.textColor = THEME_TEXT_COLOR;
                    [self addSubview:self.regularIncludeTaxLabel];
                    
                    [self.regularPriceIncludeTaxLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
                    [self addSubview:self.regularPriceIncludeTaxLabel];
                    self.heightCell += heightLabelWithDistance;
                }else if ([variant valueForKey:@"sale_price"] && [[variant valueForKey:@"sale_price"] floatValue] < [[variant valueForKey:@"price"]floatValue])
                {
                    [self.regularPriceIncludeTaxLabel setFrame:CGRectMake(origionTitleX, self.heightCell, widthValue, heightLabel)];
                    [self addSubview:self.regularPriceIncludeTaxLabel];
                    
                    //Set Strike Through for Regular Price
                    CGFloat priceWidth = [self.regularPriceIncludeTaxLabel.text sizeWithAttributes:@{NSFontAttributeName:self.regularPriceIncludeTaxLabel.font}].width;
                    UIView *throughLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.regularPriceIncludeTaxLabel.frame.size.height/2, priceWidth, 1)];
                    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                        [throughLine setFrame:CGRectMake(CGRectGetWidth(self.regularPriceIncludeTaxLabel.frame) - priceWidth, self.regularPriceIncludeTaxLabel.frame.size.height/2, priceWidth, 1)];
                    }
                    throughLine.backgroundColor = THEME_PRICE_COLOR;
                    CGRect frame = throughLine.frame;
                    frame.origin.y = frame.size.height/2;
                    frame.size.height = 1;
                    [self.regularPriceIncludeTaxLabel addSubview:throughLine];
                    self.heightCell += heightLabelWithDistance;
                    
                    [self.specialPriceLabel setFrame:CGRectMake(origionTitleX, self.heightCell, widthValue, heightLabel)];
                    [self addSubview:self.specialPriceLabel];
                    self.heightCell += heightLabelWithDistance;
                    
                }else
                {
                    [self.regularPriceIncludeTaxLabel setFrame:CGRectMake(origionTitleX, self.heightCell, widthValue, heightLabel)];
                    [self addSubview:self.regularPriceIncludeTaxLabel];
                    self.heightCell += heightLabelWithDistance;
                }
            }
        }
    }else if ([_product valueForKey:@"price_include_tax"] && [_product valueForKey:@"sale_price_include_tax"] && [[_product valueForKey:@"sale_price_include_tax"]floatValue] < [[_product valueForKey:@"price_include_tax"]floatValue] && [[_product valueForKey:@"sale_price_include_tax"]floatValue] > [[_product valueForKey:@"sale_price"]floatValue]) {
        
        self.regularTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
        self.regularTitleLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Regular Price")];
        self.regularTitleLabel.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:sizeFontPrice];
        self.regularTitleLabel.textColor = THEME_TEXT_COLOR;
        [self addSubview:self.regularTitleLabel];
        [self.regularPriceIncludeTaxLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
        [self addSubview:self.regularPriceIncludeTaxLabel];
        
        //Set Strike Through for Regular Price
        CGFloat priceWidth = [self.regularPriceIncludeTaxLabel.text sizeWithAttributes:@{NSFontAttributeName:self.regularPriceIncludeTaxLabel.font}].width;
        UIView *throughLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.regularPriceIncludeTaxLabel.frame.size.height/2, priceWidth, 1)];
        throughLine.backgroundColor = THEME_PRICE_COLOR;
        CGRect frame = throughLine.frame;
        frame.origin.y = frame.size.height/2;
        frame.size.height = 1;
        [self.regularPriceIncludeTaxLabel addSubview:throughLine];
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [throughLine setFrame:CGRectMake(CGRectGetWidth(self.regularPriceIncludeTaxLabel.frame) - priceWidth, self.regularPriceIncludeTaxLabel.frame.size.height/2, priceWidth, 1)];
        }
        self.heightCell += heightLabelWithDistance;
        
        self.specialTitlelabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
        self.specialTitlelabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Special Price")];
        self.specialTitlelabel.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:sizeFontPrice];
        self.specialTitlelabel.textColor = THEME_TEXT_COLOR;
        [self addSubview:self.specialTitlelabel];
        self.heightCell += heightLabelWithDistance;
        
        self.specialLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
        self.specialLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Excl. Tax")];
        self.specialLabel.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:sizeFontPrice];
        self.specialLabel.textColor = THEME_TEXT_COLOR;
        [self addSubview:self.specialLabel];
        
        [self.specialPriceLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
        [self addSubview:self.specialPriceLabel];
        self.heightCell += heightLabelWithDistance;
        
        self.specialIncludeTaxLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
        self.specialIncludeTaxLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Incl. Tax")];
        self.specialIncludeTaxLabel.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:sizeFontPrice];
        self.specialIncludeTaxLabel.textColor = THEME_TEXT_COLOR;
        [self addSubview:self.specialIncludeTaxLabel];
        
        [self.specialPriceIncludeTaxLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
        [self addSubview:self.specialPriceIncludeTaxLabel];
        self.heightCell += heightLabelWithDistance;
    }else if ([_product valueForKey:@"price_include_tax"] && [[_product valueForKey:@"price_include_tax"]floatValue] > [[_product valueForKey:@"price"]floatValue])
    {
        self.regularLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
        self.regularLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Excl. Tax")];
        self.regularLabel.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:sizeFontPrice];
        self.regularLabel.textColor = THEME_TEXT_COLOR;
        [self addSubview:self.regularLabel];
        
        [self.regularPriceLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
        [self addSubview:self.regularPriceLabel];
        self.heightCell += heightLabelWithDistance;
        
        self.regularIncludeTaxLabel = [[UILabel alloc]initWithFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
        self.regularIncludeTaxLabel.text = [NSString stringWithFormat:@"%@: ", SCLocalizedString(@"Incl. Tax")];
        self.regularIncludeTaxLabel.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:sizeFontPrice];
        self.regularIncludeTaxLabel.textColor = THEME_TEXT_COLOR;
        [self addSubview:self.regularIncludeTaxLabel];
        
        [self.regularPriceIncludeTaxLabel setFrame:CGRectMake(origionValueX, self.heightCell, widthValue, heightLabel)];
        [self addSubview:self.regularPriceIncludeTaxLabel];
        self.heightCell += heightLabelWithDistance;
    }else if ([_product valueForKey:@"sale_price"] && [[_product valueForKey:@"sale_price"] floatValue] < [[_product valueForKey:@"price"]floatValue])
    {
         [self.regularPriceIncludeTaxLabel setFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
        [self addSubview:self.regularPriceIncludeTaxLabel];
        
        //Set Strike Through for Regular Price
        CGFloat priceWidth = [self.regularPriceIncludeTaxLabel.text sizeWithAttributes:@{NSFontAttributeName:self.regularPriceIncludeTaxLabel.font}].width;
        UIView *throughLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.regularPriceIncludeTaxLabel.frame.size.height/2, priceWidth, 1)];
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [throughLine setFrame:CGRectMake(CGRectGetWidth(self.regularPriceIncludeTaxLabel.frame) - priceWidth, self.regularPriceIncludeTaxLabel.frame.size.height/2, priceWidth, 1)];
        }
        throughLine.backgroundColor = THEME_PRICE_COLOR;
        CGRect frame = throughLine.frame;
        frame.origin.y = frame.size.height/2;
        frame.size.height = 1;
        [self.regularPriceIncludeTaxLabel addSubview:throughLine];
        self.heightCell += heightLabelWithDistance;
        
        [self.specialPriceLabel setFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
        [self addSubview:self.specialPriceLabel];
        self.heightCell += heightLabelWithDistance;
        
    }else
    {
        [self.regularPriceIncludeTaxLabel setFrame:CGRectMake(origionTitleX, self.heightCell, widthTitle, heightLabel)];
        [self addSubview:self.regularPriceIncludeTaxLabel];
        self.heightCell += heightLabelWithDistance;
    }
    
    if(self.shortDescription){
        self.shortDescriptionLabel = [[UILabel alloc]init];
        self.shortDescriptionLabel.text = self.shortDescription;
        self.shortDescriptionLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:sizeFontDescription];
        self.shortDescriptionLabel.textColor = THEME_CONTENT_COLOR;
        [self addSubview:self.shortDescriptionLabel];
        [self.shortDescriptionLabel setFrame:CGRectMake(origionTitleX, self.heightCell+3, widthText,heightLabel)];
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [self.shortDescriptionLabel setFrame:CGRectMake(0, self.heightCell+3, widthText, heightLabel)];
        }
        [self.shortDescriptionLabel resizLabelToFit];
        self.heightCell += CGRectGetHeight(self.shortDescriptionLabel.frame) + 10;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"SCProductInforViewSetInterfacecell_After" object:self userInfo:nil];
    
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel*)view;
                [label setTextAlignment:NSTextAlignmentRight];
            }
        }
    }
}
@end
