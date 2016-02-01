//
//  SCProductCollectionViewCellPad.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/18/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SCProductCollectionViewCellPad.h"

@implementation SCProductCollectionViewCellPad

- (void)setInterfaceCell
{
    float maximumImageSize = 246;
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
        float sizeImageStock = 60;
        [self.imageStockStatus setFrame:CGRectMake([SimiGlobalVar scaleValue:maximumImageSize] - sizeImageStock, [SimiGlobalVar scaleValue:maximumImageSize] - sizeImageStock, sizeImageStock, sizeImageStock)];
        [self.lblStockStatus setFrame:CGRectMake([SimiGlobalVar scaleValue:maximumImageSize] - sizeImageStock - 3, [SimiGlobalVar scaleValue:maximumImageSize] - 35, sizeImageStock * 1.4, 14)];
        [self.lblStockStatus setBackgroundColor:[UIColor clearColor]];
        [self.lblStockStatus setTransform:CGAffineTransformMakeRotation(- M_PI_4)];
        [self.lblStockStatus setTextAlignment:NSTextAlignmentCenter];
        [self.lblStockStatus setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:7]];
        [self.imageProduct addSubview:self.imageStockStatus];
        [self.imageProduct addSubview:self.lblStockStatus];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidDrawProductImageView" object:self.imageProduct userInfo:@{@"imageView": self.imageProduct, @"product": self.productModel}];
    
    [self.lblNameProduct setFrame:[SimiGlobalVar scaleFrame:CGRectMake(0, maximumImageSize, maximumImageSize, heightLabel)]];
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        [self.lblNameProduct setTextAlignment:NSTextAlignmentRight];
        [self.lblNameProduct setLineBreakMode:NSLineBreakByTruncatingHead];
    }
    if (self.lblExcl && self.lblIncl) {
        [self.lblExcl setFrame:[SimiGlobalVar scaleFrame:CGRectMake(0, maximumImageSize + heightLabel, maximumImageSize/2, heightLabel)]];
        [self.lblIncl setFrame:[SimiGlobalVar scaleFrame:CGRectMake(maximumImageSize/2, maximumImageSize + heightLabel, maximumImageSize/2, heightLabel)]];
        CGFloat priceWidth = [self.lblExcl.text sizeWithAttributes:@{NSFontAttributeName:[self.lblExcl font]}].width;
        self.viewLine = [[UIView alloc]initWithFrame:CGRectMake(0, [SimiGlobalVar scaleValue:heightLabel/2], priceWidth, 1)];
        self.viewLine.backgroundColor = THEME_PRICE_COLOR;
        
        [self addSubview:self.lblExcl];
        [self addSubview:self.lblIncl];
        [self.lblExcl addSubview:self.viewLine];
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [self.lblExcl setTextAlignment:NSTextAlignmentRight];
            [self.lblIncl setTextAlignment:NSTextAlignmentRight];
            [self.viewLine setFrame:CGRectMake(CGRectGetWidth(self.lblExcl.frame) - priceWidth,[SimiGlobalVar scaleValue:heightLabel/2], priceWidth, 1)];
        }
        return;
    }
    
    if (self.lblExcl) {
        [self.lblExcl setFrame:[SimiGlobalVar scaleFrame:CGRectMake(0, maximumImageSize + heightLabel, maximumImageSize, heightLabel)]];
        [self addSubview:self.lblExcl];
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [self.lblExcl setTextAlignment:NSTextAlignmentRight];
        }
        return;
    }
    
    if (self.lblInclPrice) {
        [self.lblInclPrice setFrame:[SimiGlobalVar scaleFrame:CGRectMake(0, maximumImageSize + heightLabel, maximumImageSize, heightLabel)]];
        [self addSubview:self.lblInclPrice];
        //  Liam Update RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            [self.lblInclPrice setTextAlignment:NSTextAlignmentRight];
        }
        //  End RTL
        return;
    }
}
@end
