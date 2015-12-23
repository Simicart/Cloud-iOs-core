//
//  SCProductRelateViewController.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/18/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SimiCartBundle.h"
#import "SimiProductModelCollection.h"
#import "SCProductCollectionViewController.h"
@protocol SCProductRelateViewControllerDelegate <NSObject>
- (void)didSelectRelatedProductWithFirstProductID:(NSString*)productID arrayProductID:(NSMutableArray*)arrayProductID;
@end

@interface SCProductRelateViewController : SimiViewController<SCProductCollectionViewController_Delegate>
@property (nonatomic, strong) NSString *productID;
@property (nonatomic, strong) SimiProductModelCollection *relateProductCollection;
@property (nonatomic, strong) SCProductCollectionViewController *relateProductCollectionViewController;
@property (nonatomic) ProductListGetProductType productListGetProductType;
@property (nonatomic, strong) id<SCProductRelateViewControllerDelegate> delegate;
@end
