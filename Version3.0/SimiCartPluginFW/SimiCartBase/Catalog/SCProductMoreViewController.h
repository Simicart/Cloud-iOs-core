//
//  SCProductMoreViewController.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/13/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SimiCartBundle.h"
#import "SimiViewController.h"
#import "SimiProductModel.h"
#import "LazyPageScrollView.h"
#import "SCProductInfoView.h"
#import "SCProductReviewController.h"
#import "SCProductRelateViewController.h"

@interface MoreActionView : UIView
@property (nonatomic) int numberIcon;
@property (nonatomic, strong) NSMutableArray *arrayIcon;
@property (nonatomic) BOOL isShowViewMoreAction;
@property (nonatomic) float heightMoreView;
@end

@protocol SCProductMoreViewControllerDelegate <NSObject>
@optional
- (void)didSelectRelateProductWithProductID:(NSString*)productID arrayProduct:(NSMutableArray*)arrayID;
@end

@interface SCProductMoreViewController : SimiViewController<LazyPageScrollViewDelegate, SCProductReviewControllerDelegate, SCProductRelateViewControllerDelegate>
@property (nonatomic, strong) LazyPageScrollView *pageScrollView;
@property (nonatomic, strong) SimiProductModel *productModel;
@property (nonatomic, strong) UIButton *buttonMoreAction;
@property (nonatomic, strong) MoreActionView *viewMoreAction;
@property (nonatomic, strong) UIButton *buttonShare;
@property (nonatomic, strong) id<SCProductMoreViewControllerDelegate> delegate;
@property (strong, nonatomic) NSString *variantSelectedKey;
@property (nonatomic, strong) NSMutableArray *variants;

- (void)didTouchMoreAction;
@end