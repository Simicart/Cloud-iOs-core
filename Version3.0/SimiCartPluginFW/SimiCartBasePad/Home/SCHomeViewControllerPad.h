//
//  SCHomeViewControllerPad.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/7/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SimiCartBundle.h"
#import "SCHomeViewController.h"
#import "SCHomeCategoryCollectionViewCellPad.h"
#import "iCarousel.h"

@interface SCHomeViewControllerPad : SCHomeViewController <iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, strong) iCarousel *carousel;
@property (nonatomic, strong) NSMutableArray *arrayImageBanner;
@property (nonatomic, strong) NSMutableArray *arrayBannerModel;

@end
