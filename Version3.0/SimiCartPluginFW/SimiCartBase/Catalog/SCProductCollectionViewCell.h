//
//  SCProductCollectionViewCell.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/8/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "SimiFormatter.h"

@interface SCProductCollectionViewCell : UICollectionViewCell
@property (nonatomic) BOOL isShowOnlyImage;
@property (nonatomic) BOOL isChangeLayOut;
@property (nonatomic, strong) UIImageView *imageProduct;
@property (nonatomic, strong) UILabel *lblNameProduct;
@property (nonatomic, strong) UILabel *lblExcl;
@property (nonatomic, strong) UILabel *lblExclPrice;
@property (nonatomic, strong) UILabel *lblIncl;
@property (nonatomic, strong) UILabel *lblInclPrice;
@property (nonatomic, strong) UIView *viewLine;
@property (nonatomic) BOOL isRelated;
@property (nonatomic, strong) NSDictionary *priceDict;

@property (nonatomic, strong) NSString *stringNameProduct;
@property (nonatomic, strong) NSString *stringStock;
@property (nonatomic, strong) NSString *stringPriceRegular;
@property (nonatomic, strong) NSString *stringPriceSpecial;

@property (nonatomic) BOOL stockStatus;
@property (nonatomic, strong) UIImageView *imageStockStatus;
@property (nonatomic, strong) UILabel *lblStockStatus;

@property (nonatomic, strong) SimiProductModel *productModel;

- (void)cusSetProductModel:(SimiProductModel *)productModel_;
- (void)setPrice;
- (void)setInterfaceCell;
- (void)cusSetStringPriceRegular:(NSString *)stringPriceRegular_;
- (void)cusSetStringPriceSpecial:(NSString *)stringPriceSpecial_;
@end
