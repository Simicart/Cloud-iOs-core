//
//  SCProductCollectionViewController.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/8/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimiProductModelCollection.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "NSObject+SimiObject.h"

typedef NS_ENUM(NSInteger, ProductListGetProductType) {
    ProductListGetProductTypeFromCategory,
    ProductListGetProductTypeFromSearch,
    ProductListGetProductTypeFromSpot,
    ProductListGetProductTypeFromRelateProduct
};

@protocol SCProductCollectionViewController_Delegate <NSObject>
@optional
- (void)selectedProduct:(NSString*)productID_;
- (void)numberProductChange:(int)numberProduct;
- (void)didGetProductModelCollection:(NSDictionary*)layerNavigation;
- (void)startGetProductModelCollection;
- (void)setHideViewToolBar:(BOOL)isHide;
@end

@interface SCProductCollectionViewController : UICollectionViewController<UIScrollViewDelegate>
{
    SimiResponder *responder;
    float minimumImageSize;
    float maximumImageSize;
    float heightLabel;
    float padding;
    float paddingTop;
    float paddingBottom;
    float lineSpace;
    
    float numberRow;
    float maxScrollOffset;
}

@property (strong, nonatomic)  SimiProductModelCollection *productCollection;
@property (nonatomic) ProductCollectionSortType sortType;
@property (nonatomic, strong) id<SCProductCollectionViewController_Delegate> delegate;
@property (nonatomic) ProductListGetProductType collectionGetProductType;

@property (strong, nonatomic) NSString *categoryID;
@property (strong, nonatomic) NSString *keySearchProduct;
//@property (strong, nonatomic) NSString *spotID;
@property (nonatomic, strong) NSDictionary* spotModel;
@property (nonatomic, strong) UILabel *lbNotFound;
@property (nonatomic, strong) NSDictionary* filterParam;
@property (nonatomic, strong) NSMutableArray *arrayProductID;
@property (nonatomic) BOOL isShowOnlyImage;
@property (nonatomic, strong) UIPinchGestureRecognizer *gesture;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic) CGFloat lastContentOffset;
@property (nonatomic) int totalNumberProduct;
@property (nonatomic) BOOL isSearchOnAllProducts;

- (void)viewDidLoadAfter;
- (void)viewWillAppearAfter;
- (void)getProducts;
- (void)setLayout;
- (void)didGetProducts:(NSNotification *)noti;
@end
