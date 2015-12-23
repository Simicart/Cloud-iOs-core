//
//  ShortReviewCell.h
//  SimiCart
//
//  Created by Tan on 7/1/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UILabelDynamicSize.h"
@interface SCProductReviewShortCell : UITableViewCell

@property (nonatomic) float ratePoint;
@property (strong, nonatomic) NSString *reviewTitle;
@property (strong, nonatomic) NSString *reviewBody;
@property (strong, nonatomic) NSString *reviewTime;
@property (strong, nonatomic) NSString *customerName;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) NSMutableArray *starCollection;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *bodyLabel;


- (void)reArrangeLabelWithTitleLine:(int)titleLine BodyLine:(int) bodyLine;
- (CGFloat)getActualCellHeight;

@end
