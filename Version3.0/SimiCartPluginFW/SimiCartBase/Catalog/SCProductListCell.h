//
//  SCProductListCell.h
//  SimiCart
//
//  Created by Tan on 4/30/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "SimiProductModel.h"

@interface SCProductListCell : UITableViewCell


@property (strong, nonatomic) SimiProductModel *product;
@property (strong, nonatomic) NSDictionary *showPriceV2;

@property (nonatomic, strong)  UILabel *productNameLabel;
@property (nonatomic, strong)  UIImageView *productImageView;
@property (nonatomic) int heightCell;

@property (nonatomic, strong) NSString *productName;
@property (nonatomic, strong) NSString *specialPrice;
@property (nonatomic, strong) NSString *regularPrice;
@property (nonatomic, strong) NSString *imagePath;
@property (nonatomic) BOOL stockStatus;


@property (nonatomic, strong) UILabel *specialPriceLabel;
@property (nonatomic, strong) UILabel *regularPriceLabel;
@property (nonatomic, strong) UILabel *lblStockStatus;
@property (nonatomic, strong) UIImageView *imageStockStatus;


- (void)setInterfaceCell;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier product:(SimiProductModel*)productModel;

@end
