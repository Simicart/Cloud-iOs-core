//
//  MatrixHomeViewControllerPad.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/7/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "MatrixHomeViewController.h"
#import "MatrixCategoryProductCellPad.h"
#import "MatrixSpotProductCellPad.h"
#import "iCarousel.h"
#import "SimiViewController.h"


@interface MatrixHomeViewControllerPad : MatrixHomeViewController<UITableViewDataSource, UITableViewDelegate, MatrixCategoryProductCell_Delegate, iCarouselDataSource, iCarouselDelegate, MatrixSpotProductCell_Delegate>
@property (nonatomic, strong) iCarousel *carousel;
@property (nonatomic, strong) NSMutableArray *arrayImageBanner;
@property (nonatomic, strong) NSMutableArray *arrayBannerModel;

@end
