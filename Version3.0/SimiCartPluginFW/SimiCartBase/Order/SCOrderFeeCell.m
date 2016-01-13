//
//  SCOrderFeeCell.m
//  SimiCart
//
//  Created by Tân Hoàng on 8/8/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import "SCOrderFeeCell.h"
#import "SimiFormatter.h"
#import "SimiGlobalVar.h"

@implementation SCOrderFeeCell

@synthesize heightCell, order, subTotal, subTotalLabel,tax, taxLabel, discount, discountLabel, total, totalLabel, shipping, shippingLabel;
@synthesize subTotalValueLabel, totalValueLabel, discountValueLabel, taxValueLabel, shippingValueLabel, currencyPosition, currencySymbol,isUsePhoneSizeOnPad, payment, paymentLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setOrder:(SimiOrderModel *)order_ withCurencyPosition: (NSString *)curencyPosition_ withCurrencySymbol: (NSString *)currencySymbol_
{
    order = [order_ copy];
    currencyPosition = curencyPosition_;
    currencySymbol = currencySymbol_;
    self.subTotal = [order valueForKey:@"subtotal"];
    self.shipping = [order valueForKey:@"shipping_amount"];
    self.total = [order valueForKey:@"grand_total"];
    self.payment = [order valueForKey:@"payment_amount"];
    self.tax = [order valueForKey:@"tax_amount"];
    self.discount = [order valueForKey:@"discount_amount"];
    
    [self setInterfaceCell];
}

- (void)setData:(NSMutableDictionary*)cartPrices
{
    if([cartPrices valueForKey:@"subtotal"])
        self.subTotal = [cartPrices valueForKey:@"subtotal"];
    if([cartPrices valueForKey:@"shipping_amount"] && [cartPrices valueForKey:@"shipping_amount"] > 0)
        self.shipping = [cartPrices valueForKey:@"shipping_amount"];
    if([cartPrices valueForKey:@"payment_amount"] && [cartPrices valueForKey:@"payment_amount"] > 0)
        self.payment = [cartPrices valueForKey:@"payment_amount"];
    if([cartPrices valueForKey:@"grand_total"])
        self.total = [cartPrices valueForKey:@"grand_total"];
    if([cartPrices valueForKey:@"tax_amount"] && [cartPrices valueForKey:@"tax_amount"] > 0)
        self.tax = [cartPrices valueForKey:@"tax_amount"];
    if([cartPrices valueForKey:@"discount_amount"] && [cartPrices valueForKey:@"discount_amount"] > 0)
        self.discount = [cartPrices valueForKey:@"discount_amount"];
    [self setInterfaceCell];
}

- (NSString *)getPriceWithCurrency: (NSString *)price
{
    NSString *priceWithCurrency = @"";
     NSString *orderPrice = [NSString stringWithFormat:@"%0.2f", [price floatValue]];
    if([currencyPosition isEqualToString:@"after"]){
        priceWithCurrency = [NSString stringWithFormat:@"%2@ %@", orderPrice, currencySymbol];
    }else if([currencyPosition isEqualToString:@"before"]){
        priceWithCurrency = [NSString stringWithFormat:@"%@%2@",currencySymbol,orderPrice];
    }else{
        priceWithCurrency = [[SimiFormatter sharedInstance] priceByLocalizeNumber:[NSNumber numberWithFloat:[price floatValue]]];
    }
    return priceWithCurrency;
}

#pragma mark Setters
- (void)setSubTotal:(NSString *)subTotal_
{
    subTotal = [subTotal_ copy];
    subTotalLabel = [[UILabel alloc]init];
    subTotalValueLabel = [[UILabel alloc]init];
    subTotalLabel.text = [self getPriceWithCurrency:subTotal];
    subTotalLabel.text = [NSString stringWithFormat:@"%@:",  SCLocalizedString(@"Subtotal")];
    
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        [subTotalLabel setTextAlignment:NSTextAlignmentRight];
    }
    subTotalValueLabel.text = [self getPriceWithCurrency:subTotal];
    subTotalLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE];
    subTotalLabel.textColor = THEME_CONTENT_COLOR;
    subTotalValueLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE];
    subTotalValueLabel.textColor = THEME_PRICE_COLOR;
}

- (void)setShipping:(NSString *)shipping_
{
    if([shipping_ floatValue] > 0){
        shipping = [shipping_ copy];
        shippingLabel = [[UILabel alloc]init];
        shippingValueLabel = [[UILabel alloc]init];
        shippingLabel.text = [NSString stringWithFormat:@"%@:", SCLocalizedString(@"Shipping & Handling")];
        shippingValueLabel.text = [self getPriceWithCurrency:shipping];
        shippingLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE];
        shippingLabel.textColor = THEME_CONTENT_COLOR;
        shippingValueLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE];
        shippingValueLabel.textColor = THEME_PRICE_COLOR;
    }
}

- (void)setTotal:(NSString *)total_
{
    total = [total_ copy];
    totalLabel = [[UILabel alloc]init];
    totalValueLabel = [[UILabel alloc]init];
    totalLabel.text = [NSString stringWithFormat:@"%@:", SCLocalizedString(@"Grand Total")];
    totalValueLabel.text = [self getPriceWithCurrency:total];
    totalLabel.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE];
    totalLabel.textColor = THEME_CONTENT_COLOR;
    totalValueLabel.font = [UIFont fontWithName: THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE];
    totalValueLabel.textColor = THEME_PRICE_COLOR;
}

- (void)setTax:(NSString *)tax_
{
    if([tax_ floatValue] > 0){
        tax = [tax_ copy];
        taxLabel = [[UILabel alloc]init];
        taxValueLabel = [[UILabel alloc]init];
        taxLabel.text = [NSString stringWithFormat:@"%@:", SCLocalizedString(@"Tax")];
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [taxLabel setTextAlignment:NSTextAlignmentRight];
        }
        taxValueLabel.text = [self getPriceWithCurrency:tax];
        taxLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE];
        taxLabel.textColor = THEME_CONTENT_COLOR;
        taxValueLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE];
        taxValueLabel.textColor = THEME_PRICE_COLOR;
    }
}

- (void)setDiscount:(NSString *)discount_
{
    discount = [discount_ copy];
    if([discount_ floatValue] > 0){
        discountLabel = [[UILabel alloc]init];
        discountValueLabel = [[UILabel alloc]init];
        discountLabel.text = [NSString stringWithFormat:@"%@:", SCLocalizedString(@"Discount")];
        discountValueLabel.text = [self getPriceWithCurrency:discount];
        discountLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE];
        discountLabel.textColor = THEME_CONTENT_COLOR;
        discountValueLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE];
        discountValueLabel.textColor = THEME_PRICE_COLOR;
    }
}

- (void)addSubview:(UIView *)view
{
    if (SIMI_SYSTEM_IOS >= 8) {
        [super addSubview:view];
    }else
    {
        [self.contentView addSubview:view];
    }
}

- (NSArray *)subviews
{
    if (SIMI_SYSTEM_IOS >= 8) {
        return [super subviews];
    }else
    {
        return self.contentView.subviews;
    }
}

- (void)setInterfaceCell
{
    heightCell = 5;
    //Axe Edit 150804
    float widthTitle = [SimiGlobalVar scaleValue:150];
    float widthValue = [SimiGlobalVar scaleValue:120];
    float origionTitleX = [SimiGlobalVar scaleValue:16];
    float origionValueX = [SimiGlobalVar scaleValue:166];
    float heightLabel = 22;
    float heightLabelWithDistance = 25;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        heightCell = 15;
        origionValueX = self.frame.size.width - 150;
        widthValue = 130;
        origionTitleX = 10;
        widthTitle = self.frame.size.width - 160;
        heightLabel = 22;
        heightLabelWithDistance = 25;
    }
    //  End Axe Edit150805
    
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        origionTitleX = [SimiGlobalVar scaleValue:140];
        widthTitle = [SimiGlobalVar scaleValue:165];
        origionValueX = [SimiGlobalVar scaleValue:15];
        widthValue = [SimiGlobalVar scaleValue:120];
        heightLabel = 50;
        heightLabelWithDistance = 50;
        //gin edit RTL
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad &&(!self.isUsePhoneSizeOnPad) ) {
            origionTitleX = 140;
            widthTitle = 264;
            origionValueX = [SimiGlobalVar scaleValue:16];
            widthValue = 120;
        }
        //gin end
    }
    //  End RTL
    if(subTotal){
        [subTotalLabel setFrame:CGRectMake(origionTitleX, heightCell, widthTitle, heightLabel)];
        [subTotalValueLabel setFrame:CGRectMake(origionValueX, heightCell, widthValue, heightLabel)];
        //gin edit RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]){
        }
        //end
       
        [self addSubview:subTotalLabel];
        [self addSubview:subTotalValueLabel];
        heightCell += heightLabelWithDistance;
    }
    if(discount && [discount floatValue] >0){
        [discountLabel setFrame:CGRectMake(origionTitleX, heightCell, widthTitle, heightLabel)];
        [discountValueLabel setFrame:CGRectMake(origionValueX, heightCell, widthValue, heightLabel)];
        [self addSubview:discountLabel];
        [self addSubview:discountValueLabel];
        
        //gin edit
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]){
        }
        //end

        heightCell += heightLabelWithDistance;
    }
    if(shipping && [shipping floatValue] >0){
        [shippingLabel setFrame:CGRectMake(origionTitleX, heightCell, widthTitle, heightLabel)];
        [shippingValueLabel setFrame:CGRectMake(origionValueX, heightCell, widthValue, heightLabel)];
        [self addSubview:shippingLabel];
        [self addSubview:shippingValueLabel];
        
        //gin edit
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]){
        }
        //end
        heightCell += heightLabelWithDistance;
    }
    if(tax && [tax floatValue] >0){
        [taxLabel setFrame:CGRectMake(origionTitleX, heightCell, widthTitle, heightLabel)];
        [taxValueLabel setFrame:CGRectMake(origionValueX, heightCell, widthValue, heightLabel)];
        
        //gin edit
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]){
        }
        //end
        [self addSubview:taxLabel];
        [self addSubview:taxValueLabel];
        heightCell += heightLabelWithDistance;
    }
    if(total){
        [totalLabel setFrame:CGRectMake(origionTitleX, heightCell, widthTitle, heightLabel)];
        [totalValueLabel setFrame:CGRectMake(origionValueX, heightCell, widthValue, heightLabel)];
        [self addSubview:totalLabel];
        [self addSubview:totalValueLabel];
        
        //gin edit
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]){
        }
        //end
        heightCell += heightLabelWithDistance;
    }
    for (UIView * label in self.subviews) {
        if ([label isKindOfClass:[UILabel class]]) {
            [(UILabel *)label setTextAlignment:NSTextAlignmentRight];
            [(UILabel *)label setNumberOfLines:2];
        }
    }
    //  Liam Update RTL
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        [subTotalLabel setTextAlignment:NSTextAlignmentRight];
        [discountLabel setTextAlignment:NSTextAlignmentRight];
        [shippingLabel setTextAlignment:NSTextAlignmentRight];
        [totalLabel setTextAlignment:NSTextAlignmentRight];
        [taxLabel setTextAlignment:NSTextAlignmentRight];
        
        [subTotalValueLabel setTextAlignment:NSTextAlignmentLeft];
        [discountValueLabel setTextAlignment:NSTextAlignmentLeft];
        [shippingValueLabel setTextAlignment:NSTextAlignmentLeft];
        [totalValueLabel setTextAlignment:NSTextAlignmentLeft];
        [taxValueLabel setTextAlignment:NSTextAlignmentLeft];
    }    //  End RTL
}

@end
