//
//  ZThemeCartCellPad.m
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 5/29/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SimiFormatter.h"
#import "UILabelDynamicSize.h"
#import "SCCartCellPad.h"
#import "SCThemeWorker.h"

@implementation SCCartCellPad


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    //     Configure the view for the selected state
}

#pragma mark Set Interface
- (void)setInterfaceCell
{
    self.heightCell = 30;
    float padding = 15;
    float imageX = 15;
    float imageWidth = 150;
    float labelX = imageWidth + imageX + padding ;
    float labelWidth = 600 - labelX - padding;
    float heightLabel = 27;
    float optionWidth = labelWidth/2;
    float optionValueWidth = labelWidth/2 - padding;
    float optionX = labelX;
    float deleteX = 560;
    float optionValueX = labelX + optionWidth + padding;
    //Gin edit RTL
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        imageX = [SimiGlobalVar scaleValue:600] - imageWidth- padding;
        labelX = padding;
        labelWidth = 600 - imageWidth - 3*padding;
        optionWidth = labelWidth/2;
        optionValueWidth = labelWidth/2 - padding;
        optionX = padding;
        deleteX = 0;
    }
    //end
    CGRect frame;
    
    [self.productImageView setFrame:CGRectMake(imageX, self.heightCell, imageWidth, imageWidth)];
    [self addSubview:self.productImageView];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(productImageClick)];
    singleTap.numberOfTapsRequired = 1;
    [self.productImageView setUserInteractionEnabled:YES];
    [self.productImageView addGestureRecognizer:singleTap];
    self.productImageView.layer.borderWidth = [SimiGlobalVar scaleValue:1];
    self.productImageView.layer.borderColor = [[SimiGlobalVar sharedInstance] colorWithHexString:@"#e8e8e8"].CGColor;
    
    
    
    [self.deleteButton setImage:[UIImage imageNamed:@"ic_delete"] forState:UIControlStateNormal];
    [self.deleteButton setFrame:CGRectMake(deleteX, 0, 40, 40)];
    [self.deleteButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [self.deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.deleteButton];
    
    [self.nameLabel setFrame:CGRectMake(labelX, self.heightCell, labelWidth, heightLabel)];
    [self.nameLabel resizLabelToFit];
    self.nameLabel.textColor = THEME_CONTENT_COLOR;
    self.nameLabel.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR  size:THEME_FONT_SIZE];
    [self addSubview:self.nameLabel];
    frame = self.nameLabel.frame;
    self.nameLabel.numberOfLines = 1;
    if(frame.size.height > 30){
        frame.size.height = 40;
        self.nameLabel.numberOfLines = 2;
        frame.origin.x = frame.origin.x - 1;
        self.nameLabel.frame = frame;
    }
    self.heightCell += heightLabel * self.nameLabel.numberOfLines;
    
    [self.priceLabel setFrame:CGRectMake(labelX, self.heightCell, labelWidth, heightLabel)];
    self.priceLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
    [self addSubview:self.priceLabel];
    self.heightCell += heightLabel;
    int i = 0;
    for (NSDictionary *option in [self.item valueForKeyPath:@"options"]) {
        if(i < 2){
            UILabel *optionNameLabel =  [[UILabel alloc]initWithFrame:CGRectMake(optionX, self.heightCell, optionWidth, 20)];
            optionNameLabel.textColor = THEME_CONTENT_COLOR;
            optionNameLabel.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE];
            optionNameLabel.text = [NSString stringWithFormat:@"%@:", [option valueForKeyPath:@"option_title"]];
            float optionStringWidth = [optionNameLabel.text sizeWithAttributes:@{NSFontAttributeName: optionNameLabel.font}].width;
            frame = optionNameLabel.frame;
            if(optionStringWidth < optionWidth){
                frame.size.width = optionStringWidth;
                optionNameLabel.frame = frame;
            }
            [self addSubview:optionNameLabel];
            
            UILabel *optionValueLabel =  [[UILabel alloc]init];
            optionValueWidth = labelWidth - frame.size.width - 2*padding;
            optionValueX = optionX + frame.size.width + padding;
            optionValueLabel.text = [[NSString stringWithFormat:@"%@", [option valueForKeyPath:@"option_value"]] stringByDecodingHTMLEntities];
            [optionValueLabel setFrame:CGRectMake(optionValueX, self.heightCell, optionValueWidth , 20)];
            optionValueLabel.textColor = THEME_CONTENT_COLOR;
            optionValueLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
            [self addSubview:optionValueLabel];
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                //gin edit RTL
                
                optionNameLabel.frame = CGRectMake(600 - 2*padding - imageWidth - optionWidth, self.heightCell, optionWidth, 20);
                [optionValueLabel setFrame:CGRectMake(optionX  , self.heightCell, optionValueWidth , 20)];
                [optionValueLabel setLineBreakMode:NSLineBreakByTruncatingHead];
                //end
            }

            self.heightCell += heightLabel;
        }
        i++;
    }
    
    UILabel *qtyLabel =  [[UILabel alloc]initWithFrame:CGRectMake(optionX, self.heightCell + 5, optionWidth, 20)];
    qtyLabel.text = [NSString stringWithFormat:@"%@:", SCLocalizedString(@"Quantity")];
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        //gin edit RTL
        qtyLabel.frame = CGRectMake(optionX + optionWidth, self.heightCell + 5, optionWidth, 20);
        //end
    }
    
    qtyLabel.textColor = THEME_CONTENT_COLOR;
    qtyLabel.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE];
    float qtyWidth = [qtyLabel.text sizeWithAttributes:@{NSFontAttributeName: qtyLabel.font}].width;
    [self addSubview:qtyLabel];
    
    [self.qtyButton setFrame:CGRectMake(optionX + qtyWidth + padding + 100 , self.heightCell - 1, 60, 30)];
    [self.qtyButton titleLabel].font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
    self.qtyButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.qtyButton setTitleColor:THEME_CONTENT_COLOR forState:UIControlStateNormal];
    [[self.qtyButton layer] setBorderColor:[UIColor grayColor].CGColor];
    [[self.qtyButton layer] setBorderWidth:0.5f];
    [[self.qtyButton layer] setCornerRadius:5.0f];
    
    //gin edit RTL
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        CGSize textSize = [qtyLabel.text sizeWithAttributes:@{NSFontAttributeName:[qtyLabel font]}];
        self.qtyButton.frame = CGRectMake(optionX + optionWidth -textSize.width , self.heightCell - 1, 60, 30);
    }
    //end
    [self.qtyButton addTarget:self action:@selector(qtyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.qtyButton];
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
