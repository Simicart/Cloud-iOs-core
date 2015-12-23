//
//  SCSpotProductCell_Theme01.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/18/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimiModel.h"

#import "MatrixSlideShow.h"
@protocol MatrixSpotProductCell_Delegate <NSObject>
@optional
- (void)didSelectedSpotProductWithSpotProductModel:(SimiModel*)spotModel;

@end
@interface MatrixSpotProductCell : UIView
{
    UILabel *lblSpotName;
    UILabel *lblViewMore;
    UIImageView *imgViewBackGround;
    UIImageView *imgViewMore;
    UIButton *btnSpot;
}

@property (nonatomic, strong) MatrixSlideShow* slideShow;
@property (nonatomic, strong) SimiModel* spotModel;
@property (nonatomic, weak) id<MatrixSpotProductCell_Delegate> delegate;
- (void)setViewSpot;
- (void)cusSetSpotModel:(SimiModel *)spotModel;
@end
