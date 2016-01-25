//
//  SCCartCell.m
//  SimiCart
//
//  Created by Tan on 5/16/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import "SCCartCell.h"
#import "SimiFormatter.h"
#import "UILabelDynamicSize.h"
@implementation SCCartCell

@synthesize nameLabel, priceLabel, qtyButton, productImageView, deleteButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    //Axe Edit 150803 for use without xib file
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        nameLabel = [UILabel new];
        priceLabel = [UILabel new];
        qtyButton = [UIButton new];
        productImageView = [UIImageView new];
        deleteButton = [UIButton new];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
    //End
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setName:(NSString *)name{
    if (![_name isEqualToString:name]) {
        _name = [name copy];
        nameLabel.text = [name stringByConvertingHTMLToPlainText];
        nameLabel.numberOfLines = 3;
        nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        //  Liam Update RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            CGRect frame = productImageView.frame;
            frame.origin.x = 225;
            [productImageView setFrame:frame];
            
            frame = nameLabel.frame;
            frame.origin.x = 65;
            [nameLabel setFrame:frame];
            [nameLabel setTextAlignment:NSTextAlignmentRight];
            
            frame = priceLabel.frame;
            frame.origin.x = 65;
            [priceLabel setFrame:frame];
            [priceLabel setTextAlignment:NSTextAlignmentRight];
            
            frame = deleteButton.frame;
            frame.origin.x = 215;
            [deleteButton setFrame:frame];
        }
        //  End RTL
    }
}

- (void)setPrice:(NSString *)price{
    if (![_price isEqual:price]) {
        _price = [price copy];
        priceLabel.text = [[SimiFormatter sharedInstance] priceWithPrice:_price];
        priceLabel.textColor = THEME_PRICE_COLOR;
    }
}

- (void)setPriceWithCurrency:(NSString *)priceWithCurrency{
    priceLabel.text = priceWithCurrency;
    priceLabel.textColor = THEME_PRICE_COLOR;
}

//Axe Edit 150805
- (void)setQty:(NSString *)qty{
    if (![[qtyButton titleForState:UIControlStateNormal] isEqualToString:qty]) {
        _qty = [qty copy];
        [qtyButton setTitle:_qty forState:UIControlStateNormal];
    }
}
//End 150805
- (void)setImagePath:(NSString *)imagePath{
    if (![imagePath isKindOfClass:[NSNull class]]) {
        if (![_imagePath isEqualToString:imagePath]) {
            _imagePath = [imagePath copy];
            [productImageView sd_setImageWithURL:[NSURL URLWithString:_imagePath] placeholderImage:[UIImage imageNamed:@"logo"]];
            [productImageView setContentMode:UIViewContentModeScaleAspectFit];
        }
    }
}

- (void)deleteButtonClicked:(id)sender {
    [self.delegate removeProductFromCart:self.cartItemId];
}

//Axe added 150805
-(void) qtyButtonClicked: (id)sender{
    [self.delegate qtyButtonClicked:(UIButton*)sender cellIndexPath:self.indexPath];

}
//End

//Axe added match to zaza theme

- (void)setItem:(SimiCartModel *)item
{
    if (![_item isEqual:item]) {
        _item = [item copy];
    }
}


#pragma mark Set Interface
- (void)setInterfaceCell
{
    float cellWidth = SCREEN_WIDTH;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        cellWidth = SCREEN_WIDTH*2/3;
    }
    _heightCell = 10;
    float padding = [SimiGlobalVar scaleValue:16];;
    float imageX = [SimiGlobalVar scaleValue:16];
    float imageWidth = [SimiGlobalVar scaleValue:75];
    float deleteButtonWidth = 44;
    float deleteButtonX = cellWidth - deleteButtonWidth;
    float labelX = imageWidth + imageX + padding ;
    float labelWidth = cellWidth - labelX - deleteButtonWidth;
    float heightLabel = 25;
    float optionWidth = labelWidth/2;
    float optionValueWidth = labelWidth/2 - padding;
    float optionX = labelX;
    float optionValueX = labelX + optionWidth + padding;
    //Gin edit RTL

    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        deleteButtonX = 0;
        imageX = cellWidth - imageWidth- padding;
        labelX = padding;
        labelWidth = cellWidth - imageWidth - 3*padding;
        optionWidth = labelWidth/2;
        optionValueWidth = labelWidth/2 - padding;
        optionX = cellWidth - imageWidth - 2*padding - optionWidth;
        optionValueX = padding;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        }
    }
    //end
    CGRect frame;
    
    [self.productImageView setFrame:CGRectMake(imageX, _heightCell, imageWidth, imageWidth)];
    [self addSubview:self.productImageView];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(productImageClick)];
    singleTap.numberOfTapsRequired = 1;
    [productImageView setUserInteractionEnabled:YES];
    [productImageView addGestureRecognizer:singleTap];
    productImageView.layer.borderWidth = [SimiGlobalVar scaleValue:1];
    productImageView.layer.borderColor = THEME_IMAGE_BORDER_COLOR.CGColor;
    
    
    
    [deleteButton setImage:[UIImage imageNamed:@"ic_delete"] forState:UIControlStateNormal];
    deleteButton.imageView.clipsToBounds = YES;
    deleteButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.deleteButton setImageEdgeInsets:UIEdgeInsetsMake(10, 20, 20, 10)];
    [self.deleteButton setFrame:CGRectMake(deleteButtonX, 0, deleteButtonWidth, deleteButtonWidth)];
    [self.deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.deleteButton];
    //Gin edit
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]){
        [self.deleteButton setFrame:CGRectMake(deleteButtonX, -5, deleteButtonWidth, deleteButtonWidth)];
    }
    
    [self.nameLabel setFrame:CGRectMake(labelX, _heightCell, labelWidth, heightLabel)];
    [self.nameLabel resizLabelToFit];
    self.nameLabel.textColor = THEME_CONTENT_COLOR;
    self.nameLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME_REGULAR] size:THEME_FONT_SIZE];
    [self addSubview:self.nameLabel];
    frame = self.nameLabel.frame;
    self.nameLabel.numberOfLines = 1;
    if(frame.size.height > 30){
        frame.size.height = 40;
        self.nameLabel.numberOfLines = 2;
        frame.origin.x = frame.origin.x - 1;
        self.nameLabel.frame = frame;
    }
    _heightCell += heightLabel * self.nameLabel.numberOfLines;
    
    [priceLabel setFrame:CGRectMake(labelX, _heightCell, labelWidth, heightLabel)];
    priceLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE];
    [self addSubview:self.priceLabel];
    _heightCell += heightLabel;
    int i = 0;
    for (NSDictionary *option in [_item valueForKeyPath:@"options"]) {
        if(i < 2){
            UILabel *optionNameLabel =  [[UILabel alloc]initWithFrame:CGRectMake(optionX, _heightCell, optionWidth, 20)];
            optionNameLabel.textColor = THEME_CONTENT_COLOR;
            optionNameLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME_REGULAR] size:THEME_FONT_SIZE];
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
            [optionValueLabel setFrame:CGRectMake(optionValueX, _heightCell, optionValueWidth , 20)];
            optionValueLabel.textColor = THEME_CONTENT_COLOR;
            optionValueLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME] size:THEME_FONT_SIZE];
            [self addSubview:optionValueLabel];
            
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                optionNameLabel.text = [NSString stringWithFormat:@":%@", [option valueForKeyPath:@"option_title"]];
                optionNameLabel.frame = CGRectMake(optionX, _heightCell, optionWidth, 20);
                optionValueLabel.frame =  CGRectMake(padding, _heightCell, optionValueWidth, 20);
                [optionValueLabel setLineBreakMode:NSLineBreakByTruncatingHead];
            }

            _heightCell += heightLabel;
        }
        i++;
    }
    
    UILabel *qtyLabel =  [[UILabel alloc]initWithFrame:CGRectMake(optionX , _heightCell + 5, optionWidth, 20)];
    qtyLabel.text = [NSString stringWithFormat:@"%@:", SCLocalizedString(@"Quantity")];
    //Gin edit
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        [qtyLabel setTextAlignment:NSTextAlignmentRight];
        [qtyLabel setLineBreakMode:NSLineBreakByTruncatingHead];
        [qtyLabel setFrame:CGRectMake(optionX , _heightCell + 5, optionWidth, 20)];
    }
    
    qtyLabel.textColor = THEME_CONTENT_COLOR;
    qtyLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", THEME_FONT_NAME_REGULAR] size:THEME_FONT_SIZE];
    float qtyWidth = [qtyLabel.text sizeWithAttributes:@{NSFontAttributeName: qtyLabel.font}].width;
    [self addSubview:qtyLabel];
    
    [qtyButton setFrame:CGRectMake(optionX + qtyWidth + padding , _heightCell - 1, 44, 30)];
    [qtyButton titleLabel].font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
    qtyButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [qtyButton setTitleColor:THEME_CONTENT_COLOR forState:UIControlStateNormal];
    [[qtyButton layer] setBorderColor:[UIColor grayColor].CGColor];
    [[qtyButton layer] setBorderWidth:1];
    [[qtyButton layer] setCornerRadius:5.0f];
    [qtyButton addTarget:self action:@selector(qtyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.qtyButton];
        
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        [qtyButton setFrame:CGRectMake(optionX -padding, _heightCell - 1, 44, 30)];
    }
    _heightCell += heightLabel + 20;
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel*)view;
                [label setTextAlignment:NSTextAlignmentRight];
            }
        }
    }
}

-(void) productImageClick{
    if(self.indexPath)
        [self.delegate productImageClicked:self.indexPath];
}

//End
@end
