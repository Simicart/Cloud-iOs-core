//
//  SCProductRelateViewController.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/18/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SCProductRelateViewController.h"
#import "SCProductViewController.h"
#import "SCAppDelegate.h"
@interface SCProductRelateViewController ()

@end

@implementation SCProductRelateViewController
@synthesize relateProductCollectionViewController;
- (void)viewDidLoadBefore
{
    [super viewDidLoadBefore];
    UICollectionViewLayout* layOut = [[UICollectionViewLayout alloc] init];
    relateProductCollectionViewController = [[SCProductCollectionViewController alloc]initWithCollectionViewLayout:layOut];
    [relateProductCollectionViewController.collectionView setFrame:self.view.bounds];
    relateProductCollectionViewController.collectionGetProductType = self.productListGetProductType;
    if (self.productID) {
        relateProductCollectionViewController.productCollection = self.relateProductCollection;
    }
    [self.view addSubview:relateProductCollectionViewController.collectionView];
    self.relateProductCollectionViewController.delegate = self;
    self.relateProductCollectionViewController.relatedIds = self.stringIds;
    [self.relateProductCollectionViewController getProducts];
    [self startLoadingData];
}
#pragma SCProductCollection Delegate
- (void)startGetProductModelCollection
{

}
- (void)didGetProductModelCollection:(NSDictionary*)layerNavigation
{
    [self stopLoadingData];
}

- (void)selectedProduct:(NSString*)productID_
{
    [self.delegate didSelectRelatedProductWithFirstProductID:productID_ arrayProductID:self.relateProductCollectionViewController.arrayProductID];
}
- (void)numberProductChange:(int)numberProduct
{
    
}

- (void)setHideViewToolBar:(BOOL)isHide
{
    
}
@end
