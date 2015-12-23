//
//  DownloadManageDownloadedViewController.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 9/10/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import "MGSwipeTableCell.h"
@protocol DownloadItemsDownloadedViewControllerDelegate<NSObject>
- (void)openFileWithName:(NSString*)fileName;
@end

@interface DownloadItemsDownloadedViewController : SimiViewController<UITableViewDataSource, UITableViewDelegate,UIActionSheetDelegate, MGSwipeTableCellDelegate>

@property (nonatomic, strong) NSMutableArray *downloadedFilesArray;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) NSFileManager *fileManger;
@property (nonatomic, strong) UITableView *tableItemsDownloaded;
@property (nonatomic, strong) id<DownloadItemsDownloadedViewControllerDelegate> delegate;
- (void)reloadData;
@end
