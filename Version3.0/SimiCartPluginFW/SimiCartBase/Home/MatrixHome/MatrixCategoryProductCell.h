//
//  SCCategoryProductCell_Theme01.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 8/18/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimiCategoryModel.h"
#import "MatrixSlideShow.h"

@protocol MatrixCategoryProductCell_Delegate <NSObject>
@optional
- (void)didSelectCateGoryWithCateModel:(SimiCategoryModel*)cateModel;
@end

@interface MatrixCategoryProductCell : UIView
{
    UIButton *btnCate;
    UILabel *lblCateName;
    UILabel *lblViewMore;
    UIImageView *imgChoice;
    UIImageView *imgCateBackGround;
    //  Liam ADD 150502
    UILabel *lblChoice;
    //  End 150502
}

@property (nonatomic, strong) SimiCategoryModel *cateModel;
@property (nonatomic, strong) MatrixSlideShow *slideShow;
@property (nonatomic, weak) id<MatrixCategoryProductCell_Delegate> delegate;
@property (nonatomic) BOOL isAllCate;

- (id)initWithFrame:(CGRect)frame isAllCate:(BOOL)isAllCate;
- (void)cusSetCateModel:(SimiCategoryModel *)cateModel_;
@end
