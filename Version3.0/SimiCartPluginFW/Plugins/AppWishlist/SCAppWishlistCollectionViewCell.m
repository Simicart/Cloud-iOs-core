//
//  SCAppWishlistCollectionViewCell.m
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 8/26/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SCAppWishlistCollectionViewCell.h"
#import <SimiCartBundle/UIImageView+WebCache.h>
#import <SimiCartBundle/SimiFormatter.h>

@implementation SCAppWishlistCollectionViewCell
@synthesize productImage,nameLabel, priceLabel, straightLine, specialPriceLabel, btnAddToCart, btnDelete, btnShare;


-(void)setProduct:(SimiModel *)product
{
    [self setInterfaceCell];
    _product = product;
    NSString * priceString = [[SimiFormatter sharedInstance]priceByLocalizeNumber:(NSNumber *)[product objectForKey:@"product_regular_price"]];
    NSString * specialPriceString =
    [[SimiFormatter sharedInstance]priceByLocalizeNumber:(NSNumber *)[product objectForKey:@"product_price"]];
    
    [nameLabel setText:[product objectForKey:@"product_name"]];
    [productImage sd_setImageWithURL:[NSURL URLWithString:(NSString *)[product objectForKey:@"product_image"]]];
    
    
    
    [priceLabel setText:priceString];
    if ([priceString isEqualToString:specialPriceString]) {
        [priceLabel setTextColor:THEME_PRICE_COLOR];
        [specialPriceLabel setText:@""];
        [straightLine setHidden:YES];
    }
    else
    {
        [priceLabel setTextColor:[UIColor blackColor]];
        [specialPriceLabel setText:specialPriceString];
        
        CGRect frame = straightLine.frame;
        frame.size.width = [priceLabel.text sizeWithFont:priceLabel.font].width;
        [straightLine setFrame:frame];
        [straightLine setHidden:NO];
    }
    
    if ([[product objectForKey:@"stock_status"] boolValue]) {
        btnAddToCart.enabled = YES;
        [btnAddToCart setBackgroundColor:THEME_BUTTON_BACKGROUND_COLOR];
        [btnAddToCart setTitle:[SCLocalizedString(@"Add To Cart") uppercaseString] forState:UIControlStateNormal];
    }
    else
    {
        btnAddToCart.enabled = NO;
        [btnAddToCart setBackgroundColor:[UIColor lightGrayColor]];
        [btnAddToCart setTitle:[SCLocalizedString(@"Out Stock") uppercaseString] forState:UIControlStateNormal];
    }
}

-(void)setInterfaceCell
{
    CGFloat padding = 10;
    CGFloat productImageY = 20;
    CGFloat productImageWidth = self.frame.size.height - 2 * productImageY;
    CGFloat addToCartBtnWidth = 150;
    CGFloat addToCartBtnHeight = 30;
    CGFloat labelX = padding *2 + productImageWidth;
    CGFloat deleteBtnWidth = 30;
    CGFloat deleteBtnY = 10;
    CGFloat labelWidth = self.frame.size.width - 2*padding - labelX - deleteBtnWidth;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        padding = 16;
        productImageY = 45;
        productImageWidth = self.frame.size.height - 2 * productImageY;
        addToCartBtnWidth = 220;
        addToCartBtnHeight = 40;
        labelX = padding *2 + productImageWidth;
        deleteBtnWidth = 30;
        deleteBtnY = 24;
        labelWidth = self.frame.size.width - 2*padding - labelX - deleteBtnWidth;
    }
    
    if (productImage == nil) {
        productImage = [[UIImageView alloc]initWithFrame:CGRectMake(padding, productImageY, productImageWidth, productImageWidth)];
        productImage.layer.borderColor = [[SimiGlobalVar sharedInstance]colorWithHexString:@"#e8e8e8"].CGColor;
        productImage.layer.borderWidth = 1;
        [self addSubview:productImage];
        UIButton *imageButton = [[UIButton alloc]initWithFrame:productImage.frame];
        [imageButton addTarget:self action:@selector(didClickImage) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:imageButton];
        [self bringSubviewToFront:imageButton];
    }
    
    CGFloat currenHeight = productImageY;
    if (nameLabel == nil) {
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, currenHeight, labelWidth, 20)];
        [nameLabel setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:THEME_FONT_SIZE]];
        [self addSubview:nameLabel];
        currenHeight += 22;
    }
    if (priceLabel == nil) {
        priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, currenHeight, labelWidth, 18)];
        [priceLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE-2]];
        [self addSubview:priceLabel];
        currenHeight +=20;
    }
    
    if (straightLine == nil) {
        CGRect frame = priceLabel.frame;
        frame.origin.y += 9;
        frame.size.height = 1;
        straightLine = [[UIView alloc]initWithFrame:frame];
        straightLine.hidden = YES;
        [straightLine setBackgroundColor:[UIColor blackColor]];
        [self addSubview:straightLine];
    }
    
    if (specialPriceLabel == nil) {
        specialPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, currenHeight, labelWidth, 18)];
        [specialPriceLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE-2]];
        [specialPriceLabel setTextColor:THEME_PRICE_COLOR];
        [self addSubview:specialPriceLabel];
    }
    
    
    if (btnAddToCart == nil) {
        btnAddToCart = [[UIButton alloc]initWithFrame:CGRectMake(labelX, productImageY + productImageWidth - addToCartBtnHeight, addToCartBtnWidth, addToCartBtnHeight)];
        btnAddToCart.enabled = NO;
        btnAddToCart.layer.cornerRadius = 1.0f;
        [btnAddToCart.titleLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
        [btnAddToCart setBackgroundColor:THEME_BUTTON_BACKGROUND_COLOR];
        [btnAddToCart setTitleColor:THEME_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
        [btnAddToCart addTarget:self action:@selector(didClickAddToCart) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnAddToCart];
    }
    
    if (btnDelete == nil) {
        btnDelete = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - padding - deleteBtnWidth, deleteBtnY , deleteBtnWidth, deleteBtnWidth)];
        [btnDelete setContentEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
        [btnDelete setImage:[UIImage imageNamed:@"wishlist_remove_icon"] forState:UIControlStateNormal];
        [btnDelete addTarget:self action:@selector(didClickDelete) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnDelete];
    }
    
    if (btnShare == nil) {
        btnShare = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - padding - deleteBtnWidth, deleteBtnY + deleteBtnWidth +20 , deleteBtnWidth, deleteBtnWidth)];
        [btnShare setContentEdgeInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
        [btnShare setImage:[UIImage imageNamed:@"wishlist_share_icon"] forState:UIControlStateNormal];
        [btnShare addTarget:self action:@selector(didClickShare:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnShare];
    }
}

#pragma mark Delegate functions
-(void)didClickAddToCart
{
    if ([[self.product objectForKey:@"selected_all_required_options"] boolValue])
        [self.delegate addProductToCartWithWishlistId:[self.product objectForKey:@"wishlist_item_id"]];
    else
        [self didClickImage];
}

-(void)didClickDelete
{
    
    [self.delegate removeProductWithWishlistId:[self.product objectForKey:@"wishlist_item_id"]];
}

-(void)didClickShare:(id)sender
{
    [self.delegate shareWithText:[self.product objectForKey:@"product_sharing_message"] andURL:[self.product objectForKey:@"product_sharing_url"] andButton:sender];
}

-(void)didClickImage
{
    [self.delegate openProductViewWithId:[self.product objectForKey:@"product_id"]];
}

@end
