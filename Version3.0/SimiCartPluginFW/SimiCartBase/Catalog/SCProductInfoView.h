//
//  SCProductInfoView.h
//  SimiCart
//
//  Created by Tan on 7/4/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimiProductModel.h"

@interface SCProductInfoView : UIView

@property (strong, nonatomic) NSString *productName;
@property (strong, nonatomic) NSString *specialPrice;
@property (strong, nonatomic) NSString *regularPrice;
@property (strong, nonatomic) NSString *specialPriceIncludeTax;
@property (strong, nonatomic) NSString *regularPriceIncludeTax;
@property (strong, nonatomic) NSString *stockStatus;
@property (strong, nonatomic) NSString *shortDescription;

@property (strong, nonatomic) SimiProductModel *product;
@property (strong, nonatomic) NSString *variantSelectedKey;
@property (nonatomic, strong) NSMutableArray *variants;
@property (nonatomic) BOOL isDetailInfo;

@property (strong, nonatomic)  UILabel *productNameLabel;
@property (strong, nonatomic)  UILabel *shortDescriptionLabel;
@property (strong, nonatomic)  UILabel *stockStatusLabel;
@property (strong, nonatomic)  UILabel *specialPriceLabel;
@property (strong, nonatomic)  UILabel *regularPriceLabel;
@property (strong, nonatomic)  UILabel *regularLabel;
@property (strong, nonatomic)  UILabel *specialLabel;
@property (strong, nonatomic)  UILabel *specialPriceIncludeTaxLabel;
@property (strong, nonatomic)  UILabel *regularPriceIncludeTaxLabel;
@property (strong, nonatomic)  UILabel *regularIncludeTaxLabel;
@property (strong, nonatomic)  UILabel *specialIncludeTaxLabel;
@property (strong, nonatomic)  UILabel *specialTitlelabel;
@property (strong, nonatomic)  UILabel *regularTitleLabel;

@property (nonatomic) int heightCell;

- (id)initWithNibName:(NSString *)nibNameOrNil;
- (void)setInterfaceCell;
@end
