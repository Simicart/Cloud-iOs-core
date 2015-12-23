//
//  SCOrderFeeCell.h
//  SimiCart
//
//  Created by Cody Nguyen on 8/17/14.
//  Copyright (c) 2015 SimiTeam. All rights reserved.
//

@interface SCOrderMethodCell : UITableViewCell;
@property (nonatomic, strong) UILabel *lblMethodTitle;
@property (nonatomic, strong) UILabel *lblMethodContent;
@property (nonatomic, strong) UIImageView *optionImageView;
- (void)setTitle: (NSString *)title andContent: (NSString *)content andIsSelected: (BOOL)isSelected;
@end