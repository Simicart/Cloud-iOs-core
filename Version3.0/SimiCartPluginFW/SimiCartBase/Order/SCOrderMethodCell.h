//
//  SCOrderFeeCell.h
//  SimiCart
//
//  Created by Cody Nguyen on 8/17/14.
//  Copyright (c) 2015 SimiTeam. All rights reserved.
//

@protocol  SCOrderMethodCellDelegate <NSObject>
- (void)editCreditCard:(int)paymentIndex;
@end

@interface SCOrderMethodCell : UITableViewCell;
@property (nonatomic, strong) UILabel *lblMethodTitle;
@property (nonatomic, strong) UILabel *lblMethodContent;
@property (nonatomic, strong) UIImageView *optionImageView;
@property (nonatomic, strong) UIButton *btnEditCard;
@property (nonatomic) BOOL isCreditCard;
@property (nonatomic) int paymentIndex;
@property (nonatomic, strong) id<SCOrderMethodCellDelegate> delegate;
- (void)setTitle: (NSString *)title andContent: (NSString *)content andIsSelected: (BOOL)isSelected;
@end