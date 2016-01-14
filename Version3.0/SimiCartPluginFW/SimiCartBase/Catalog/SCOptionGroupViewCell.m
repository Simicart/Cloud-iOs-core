//
//  SCOptionGroupViewCell.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/26/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCOptionGroupViewCell.h"
#import "SimiFormatter.h"
#import "UILabelDynamicSize.h"
@interface SCOptionGroupViewCell()
@end

@implementation SCOptionGroupViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setPriceOption:(NSDictionary*)optionDictionary
{
    _optionDict = [[NSMutableDictionary alloc]initWithDictionary:optionDictionary];
    if ([_optionDict valueForKey:@"price_include_tax"]&& DISPLAY_PRICES_INSHOP) {
        self.stringRegularPrice = [NSString stringWithFormat:@"%@",[_optionDict valueForKey:@"price_include_tax"]];
        if ([_optionDict valueForKey:@"sale_price_include_tax"] && ([[_optionDict valueForKey:@"sale_price_include_tax"]floatValue] < [[_optionDict valueForKey:@"price_include_tax"]floatValue])) {
            self.stringSpecialPrice = [NSString stringWithFormat:@"%@",[_optionDict valueForKey:@"sale_price_include_tax"]];
        }
    }else if([_optionDict valueForKey:@"price"])
    {
        self.stringRegularPrice = [NSString stringWithFormat:@"%@",[_optionDict valueForKey:@"price"]];
        if ([_optionDict valueForKey:@"sale_price"] && ([[_optionDict valueForKey:@"sale_price"]floatValue] < [[_optionDict valueForKey:@"price"]floatValue])) {
            self.stringSpecialPrice = [NSString stringWithFormat:@"%@",[_optionDict valueForKey:@"sale_price"]];
        }
    }
    
    int widthValue = 100;
    int originY = 5;
    int originX1 = 0;
    int heightLabel = 20;
    int heightLabelWidthDistance = 25;

    int redTag = 1030;
    
#pragma mark Product No Bundle
    _lblRegularPrice.tag = redTag;
    _lblSpecialPrice.tag = redTag;
    if (_lblRegularPrice && _lblSpecialPrice) {
        [_lblRegularPrice setFrame:CGRectMake(originX1, originY, widthValue, heightLabel)];
        originY += heightLabelWidthDistance;
        CGFloat widthLine = [_lblRegularPrice.text sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 2]}].width;
        UIImageView *viewLine = [[UIImageView alloc]initWithFrame:CGRectMake(originX1, heightLabel/2, widthLine, 1)];
        viewLine.backgroundColor = THEME_PRICE_COLOR;
        [_lblRegularPrice addSubview:viewLine];
        [self addSubview:_lblRegularPrice];

        [_lblSpecialPrice setFrame:CGRectMake(originX1, originY, widthValue, heightLabel)];
        [self addSubview:_lblSpecialPrice];
        
        if([[SimiGlobalVar sharedInstance] isReverseLanguage]){
            [_lblRegularPrice setTextAlignment:NSTextAlignmentRight];
            [_lblSpecialPrice setTextAlignment:NSTextAlignmentRight];
        }
    }else
    {
        originY = 15;
        [_lblRegularPrice setFrame:CGRectMake(originX1, originY, widthValue, heightLabel)];
        [self addSubview:_lblRegularPrice];
        if([[SimiGlobalVar sharedInstance] isReverseLanguage]){
            [_lblRegularPrice setTextAlignment:NSTextAlignmentRight];
        }
    }
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *lblView = (UILabel*)subview;
            if (lblView.tag == redTag)
            {
                [lblView setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 2]];
                lblView.textColor = THEME_PRICE_COLOR;
            }
        }
    }
}

- (void)setStringRegularPrice:(NSString *)stringRegularPrice_
{
    if (stringRegularPrice_ != nil) {
        _stringRegularPrice = stringRegularPrice_;
        _lblRegularPrice = [[UILabel alloc]init];
        _lblRegularPrice.text = [[SimiFormatter sharedInstance]priceWithPrice:_stringRegularPrice];
    }
}

- (void)setStringSpecialPrice:(NSString *)stringSpecialPrice_
{
    if (stringSpecialPrice_ != nil) {
        _stringSpecialPrice = stringSpecialPrice_;
        _lblSpecialPrice = [[UILabel alloc]init];
        _lblSpecialPrice.text = [[SimiFormatter sharedInstance] priceWithPrice:_stringSpecialPrice];
    }
}

@end
