//
//  ScrollViewCell.m
//  SimiCart
//
//  Created by Thuy Dao on 2/20/14.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import "SCHomeSpotProductCell.h"
#import "UIImageView+WebCache.h"
#import "SimiFormatter.h"

@implementation SCHomeSpotProductCell

@synthesize name, nameLabel, imageView, imagePath, productID, price, priceLabel, product;

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (self) {
        CGFloat imageHeight = frame.size.width;
        if (imageView == nil) {
            imageView = [[UIImageView alloc]init];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.layer.borderWidth = [SimiGlobalVar scaleValue:1];
            imageView.layer.borderColor = THEME_IMAGE_BORDER_COLOR.CGColor;
            [self addSubview:imageView];
        }
        [imageView setFrame:CGRectMake(0, 0, imageHeight, imageHeight)];
        
        if (nameLabel == nil) {
            nameLabel = [[UILabel alloc]init];
            [nameLabel setLineBreakMode:NSLineBreakByTruncatingTail];
            [nameLabel setTextAlignment:NSTextAlignmentLeft];
            [nameLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE-4]];
            [nameLabel setTextColor:THEME_CONTENT_COLOR];
            [self addSubview:nameLabel];
        }
        [nameLabel setFrame:CGRectMake(0, imageHeight + [SimiGlobalVar scaleValue:10], imageHeight, [SimiGlobalVar scaleValue:11])];
        
        if (priceLabel == nil) {
            priceLabel = [[UILabel alloc]init];
            [priceLabel setNumberOfLines:1];
            [priceLabel setTextAlignment:NSTextAlignmentLeft];
            [priceLabel setFont: [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE-4]];
            [priceLabel setTextColor:THEME_PRICE_COLOR];
            [self addSubview:priceLabel];
        }
        [priceLabel setFrame:CGRectMake(0, imageHeight + [SimiGlobalVar scaleValue:24], imageHeight, [SimiGlobalVar scaleValue:11])];
        //Gin edit
        if([[SimiGlobalVar sharedInstance] isReverseLanguage]){
            [nameLabel setTextAlignment:NSTextAlignmentRight];
            [nameLabel setLineBreakMode:NSLineBreakByTruncatingHead];
            [priceLabel setTextAlignment:NSTextAlignmentRight];
        }
        //end
    }
}


- (void)setProduct:(SimiProductModel *)pr{
    if (![product isEqual:pr]) {
        product = pr;
        if ([product valueForKey:@"images"] && [[product valueForKey:@"images"] isKindOfClass:[NSArray class]]) {
            NSMutableArray *arrayImage = [[NSMutableArray alloc]initWithArray:[product valueForKey:@"images"]];
            if (arrayImage.count > 0) {
                self.imagePath = [[arrayImage objectAtIndex:0]valueForKey:@"url"];
            }
        }else
            [self.imageView setImage:[UIImage imageNamed:@"logo"]];
        self.name = [NSString stringWithFormat:@"%@",[product valueForKey:@"name"]];
        self.price = [NSString stringWithFormat:@"%@",[product valueForKey:@"price"]];
        self.productID = [NSString stringWithFormat:@"%@",[product valueForKey:@"_id"]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidDrawProductImageView" object:self userInfo:@{@"imageView": imageView, @"product": product}];
}

- (void)setName:(NSString *)n{
    if (![n isKindOfClass:[NSNull class]]) {
        if (![n isEqualToString:name]) {
            name = [n copy];
            nameLabel.text = name;
            nameLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 4];
        }
    }
}

-(void)setImagePath:(NSString *)ip{
    if (![imagePath isEqualToString:ip]) {
        imagePath = [ip copy];
        if (imagePath != nil) {
            NSURL *url = [NSURL URLWithString:imagePath];
            [imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"logo"] options:SDWebImageRetryFailed];
            [imageView setContentMode:UIViewContentModeScaleAspectFit];
        }else
            [imageView setImage:[UIImage imageNamed:@"default_spotproduct"]];
    }
}

- (void)setProductID:(NSString *)pid{
    if (![pid isEqualToString:productID]) {
        productID = [pid copy];
    }
}

-(void)setPrice:(NSString *)p{
    if (![price isEqual:p]) {
        price = [p copy];
        priceLabel.text = [[SimiFormatter sharedInstance] priceByLocalizeNumber:[NSNumber numberWithFloat:[price floatValue]]];
        [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 4];
    }
}

@end
