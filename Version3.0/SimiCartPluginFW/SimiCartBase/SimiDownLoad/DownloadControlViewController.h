//
//  DownloadControlViewController.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 9/10/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <QuickLook/QuickLook.h>
#import <AVFoundation/AVFoundation.h>
#import "SimiCartBundle.h"
#import "SimiViewController.h"
#import "SimiTable.h"
#import "LazyPageScrollView.h"
#import "DownloadItemsAvailableViewController.h"
#import "DownloadItemsDownloadedViewController.h"
#import "DownloadItemsDownloadingViewController.h"
#import "OpenZipFileViewController.h"
#import "SCOrderDetailViewController.h"

@interface DownloadControlViewController : SimiViewController<LazyPageScrollViewDelegate, DownloadItemsAvailableViewControllerDelegate, DownloadItemsDownloadedViewControllerDelegate,QLPreviewControllerDelegate,QLPreviewControllerDataSource,OpenZipFileViewControllerDelegate>
@property (nonatomic, strong) LazyPageScrollView *pageScrollView;
@property (nonatomic, strong) DownloadItemsAvailableViewController *downloadAvailable;
@property (nonatomic, strong) DownloadItemsDownloadedViewController *downloadedViewController;
@property (nonatomic, strong) DownloadItemsDownloadingViewController *downloadingViewController;

@end
