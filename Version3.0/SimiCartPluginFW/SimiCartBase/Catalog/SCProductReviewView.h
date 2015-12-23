//
//  SCReviewView.h
//  SimiCart
//
//  Created by Tan on 7/4/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCProductReviewView : UIView

@property (nonatomic) NSInteger reviewNumber;
@property (strong, nonatomic) NSString *reviewType;
@property (nonatomic) float ratePoint;

@property (strong, nonatomic)  UILabel *reviewTypeLabel;
@property (strong, nonatomic)  NSMutableArray *starReview;
@property (strong, nonatomic)  UILabel *reviewNumberLabel;
@property (strong, nonatomic)  NSMutableArray *starLabelCollection;
@property (strong, nonatomic)  NSMutableArray *labelViewCollection;


- (void)setStarCollectionWithFiveStar:(NSString *)fiveStar fourStar:(NSString *)fourStar threeStar:(NSString *)threeStar twoStar:(NSString *)twoStar oneStar:(NSString *)oneStar;
- (void)setReviewType:(NSString *)rt;

@end
