//
//  SCOrderFeeCell.h
//  SimiCart
//
//  Created by Tân Hoàng on 8/8/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCAppDelegate.h"
#import "SimiOrderModel.h"

@interface SCOrderFeeCell : UITableViewCell

@property (strong, nonatomic) UILabel *discountLabel;
@property (strong, nonatomic) UILabel *totalLabel;
@property (strong, nonatomic) UILabel *shippingLabel;
@property (strong, nonatomic) UILabel *taxLabel;
@property (strong, nonatomic) UILabel *subTotalLabel;
@property (strong, nonatomic) UILabel *discountValueLabel;
@property (strong, nonatomic) UILabel *totalValueLabel;
@property (strong, nonatomic) UILabel *shippingValueLabel;
@property (strong, nonatomic) UILabel *taxValueLabel;
@property (strong, nonatomic) UILabel *subTotalValueLabel;
@property (strong, nonatomic) UILabel *paymentLabel;

@property (strong, nonatomic) NSString *subTotal;
@property (strong, nonatomic) NSString *tax;
@property (strong, nonatomic) NSString *shipping;
@property (strong, nonatomic) NSString *total;
@property (strong, nonatomic) NSString *discount;
@property (strong, nonatomic) NSString *payment;

@property (strong, nonatomic) SimiOrderModel *order;
@property (strong, nonatomic) NSString *currencyPosition;
@property (strong, nonatomic) NSString *currencySymbol;
@property (nonatomic) int heightCell;
//@property (strong, nonatomic) NSArray *total;

@property (nonatomic) BOOL isUsePhoneSizeOnPad;

- (void)setOrder:(SimiOrderModel *)order_ withCurencyPosition: (NSString *)curencyPosition_ withCurrencySymbol: (NSString *)currencySymbol_;
- (void)setData:(NSMutableDictionary*)cartPrices;
- (void)setInterfaceCell;

@end
