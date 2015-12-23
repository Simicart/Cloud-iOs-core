//
//  SCOrderFeeCell.m
//  SimiCart
//
//  Created by Tân Hoàng on 8/8/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import "SCOrderProductCell.h"
#import "UILabelDynamicSize.h"

@implementation SCOrderProductCell
/*
@synthesize productImageView, deleteButton, priceLabel, qtyButton;
*/
#pragma mark Set Interface
- (void)setInterfaceCell
{
    self.heightCell = [SimiGlobalVar scaleValue:16];
    float padding = [SimiGlobalVar scaleValue:16];
    float imageX = [SimiGlobalVar scaleValue:16];
    float imageWidth = [SimiGlobalVar scaleValue:90];
    float labelX = imageX + padding + imageWidth ;
    float qtyLabelX = SCREEN_WIDTH - 45;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        qtyLabelX = 512 - 45;
    float labelWidth = qtyLabelX - imageX - imageWidth - 2 * padding;
    float heightLabel = 25;
    float optionWidth = labelWidth/2;
    float optionValueWidth = labelWidth/2 - padding;
    float optionX = labelX;
    float optionValueX = labelX + optionWidth + padding;
    
    //Gin
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        imageX = SCREEN_WIDTH - imageWidth- padding;
        labelX = padding;
        labelWidth = SCREEN_WIDTH - imageWidth - 3*padding;
        optionWidth = labelWidth/2;
        optionValueWidth = labelWidth/2 - padding;
        optionX = SCREEN_WIDTH - imageWidth - 2*padding - optionWidth;
        optionValueX = padding;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            imageX = [SimiGlobalVar scaleValue:512] - imageWidth- padding;
            labelX = padding;
            labelWidth = [SimiGlobalVar scaleValue:512] - imageWidth - 3*padding;
            optionWidth = labelWidth/2;
            optionValueWidth = labelWidth/2 - padding;
            optionX = [SimiGlobalVar scaleValue:512] - imageWidth - 2*padding - optionWidth;
            optionValueX = padding;
        }
    }
    //end
    [self.productImageView setFrame:CGRectMake(imageX, self.heightCell, imageWidth, imageWidth)];
    [self addSubview:self.productImageView];
    self.productImageView.layer.borderWidth = [SimiGlobalVar scaleValue:1];
    self.productImageView.layer.borderColor = THEME_LINE_COLOR.CGColor;
    
    [self.nameLabel setFrame:CGRectMake(labelX, self.heightCell, labelWidth, heightLabel)];
    [self.nameLabel resizLabelToFit];
    self.nameLabel.textColor = THEME_CONTENT_COLOR;
    self.nameLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME_REGULAR] size:THEME_FONT_SIZE];
    [self addSubview:self.nameLabel];
    CGRect frame = self.nameLabel.frame;
    self.nameLabel.numberOfLines = 1;
    if(frame.size.height > 30){
        frame.size.height = 40;
        self.nameLabel.numberOfLines = 2;
        frame.origin.x = frame.origin.x - 1;
        self.nameLabel.frame = frame;
    }
    
    [self.qtyButton setFrame:CGRectMake(qtyLabelX, self.heightCell, 27, 20)];
    //Gin
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
       [self.qtyButton setFrame:CGRectMake(padding -27+  [self.qtyButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.qtyButton.titleLabel.font}].width, self.heightCell, 27, 20)];
    }
    //End
    [self.qtyButton titleLabel].font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
    self.qtyButton.contentHorizontalAlignment =  UIControlContentHorizontalAlignmentRight;
    [self.qtyButton setTitleColor:THEME_CONTENT_COLOR forState:UIControlStateNormal];
    [self addSubview:self.qtyButton];
    
    self.heightCell += heightLabel * self.nameLabel.numberOfLines;
    
    [self.priceLabel setFrame:CGRectMake(labelX, self.heightCell, labelWidth, heightLabel)];
    self.priceLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE];
    [self addSubview:self.priceLabel];
    self.heightCell += heightLabel;
    int i = 0;
    for (NSDictionary *option in [self.item valueForKeyPath:@"options"]) {
        if(i < 2){
            UILabel *optionNameLabel =  [[UILabel alloc]initWithFrame:CGRectMake(optionX, self.heightCell, optionWidth, 20)];
            optionNameLabel.textColor = THEME_CONTENT_COLOR;
            optionNameLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME_REGULAR] size:THEME_FONT_SIZE];
            optionNameLabel.text = [NSString stringWithFormat:@"%@:", [option valueForKeyPath:@"option_title"]];
            float optionStringWidth = [optionNameLabel.text sizeWithAttributes:@{NSFontAttributeName: optionNameLabel.font}].width;
            frame = optionNameLabel.frame;
            if(optionStringWidth < optionWidth){
                frame.size.width = optionStringWidth;
                optionNameLabel.frame = frame;
            }
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
               
            }
            [self addSubview:optionNameLabel];
            
            UILabel *optionValueLabel =  [[UILabel alloc]init];
            optionValueWidth = labelWidth - frame.size.width - 2*padding;
            optionValueX = optionX + frame.size.width + padding;
            optionValueLabel.text = [[NSString stringWithFormat:@"%@", [option valueForKeyPath:@"option_value"]] stringByDecodingHTMLEntities];
            [optionValueLabel setFrame:CGRectMake(optionValueX, self.heightCell, optionValueWidth , 20)];
            optionValueLabel.textColor = THEME_CONTENT_COLOR;
            optionValueLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE];
            [self addSubview:optionValueLabel];
            
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                optionNameLabel.frame = CGRectMake(optionX, self.heightCell, optionWidth, 20);
                optionValueLabel.frame =  CGRectMake(padding, self.heightCell, optionValueWidth, 20);
                [optionValueLabel setLineBreakMode:NSLineBreakByTruncatingHead];
            }
            self.heightCell += heightLabel;
        }
        i++;
    }
    self.heightCell += heightLabel;
    
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
