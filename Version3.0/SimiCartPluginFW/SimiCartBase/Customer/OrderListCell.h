//
//  OrderListCell.h
//  SimiCart
//
//  Created by Tan on 7/30/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimiOrderModel.h"
@interface OrderListCell : UITableViewCell
@property (strong, nonatomic)  UILabel *statusLabel;
@property (strong, nonatomic)  UILabel *statusValueLabel;
@property (strong, nonatomic)  UILabel *datelabel;
@property (strong, nonatomic)  UILabel *dateValueLabel;
@property (strong, nonatomic)  UILabel *recipientLabel;
@property (strong, nonatomic)  UILabel *recipientValueLabel;
@property (strong, nonatomic)  UILabel *itemLabel;
@property (strong, nonatomic)  UILabel *itemValueLabel;
@property (strong, nonatomic)  SimiOrderModel *orderModel;
@end
