//
//  SCProductView.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/11/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//
#import "SimiCartBundle.h"
#import "SimiView.h"
#import "SimiProductModel.h"
#import "UIImageView+WebCache.h"
#import "UIImage+SimiCustom.h"
#define BIG_SCROLL_VIEW_TAG -1

@protocol SCProductView_Delegate <NSObject>
@optional
- (void)didGetProductDetailWithProductID:(NSString*)productID;
- (void)touchImage;
@end
@interface SCProductView : SimiView<UIScrollViewDelegate>
{
    UIActivityIndicatorView *activityIndicatorView;
    int beginTag;
}

@property (nonatomic, strong) UIScrollView *scrollViewProductImages;
@property (nonatomic, strong) SimiProductModel *productModel;
@property (nonatomic, strong) NSString* productID;
@property (nonatomic, strong) NSMutableArray *productImages;

@property (nonatomic) CGFloat heightScrollView;
@property (nonatomic) CGFloat widthScrollView;
@property (nonatomic) CGFloat topMark;
@property (nonatomic) CGFloat bottomMark;
@property (nonatomic) NSInteger offsetZoomed;
@property (nonatomic) CGFloat scale;
@property (nonatomic) CGFloat previousScale;
@property (nonatomic) BOOL isTouchInSmallScrollView;
@property (nonatomic) BOOL isGotProduct;
@property (nonatomic) BOOL isDidGetProduct;

@property (nonatomic) CGRect frameParentView;
@property (nonatomic, weak) id<SCProductView_Delegate> delegate;

@property (nonatomic) int numberImage;
@property (nonatomic, strong) UIView    *viewPageControl;

- (instancetype)initWithFrame:(CGRect)frame productID:(NSString *)productID_;
- (void)getProductDetail;
@end
