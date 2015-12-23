//
//  DownloadManageViewController.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 9/10/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiTable.h>
#import "DownloadModelCollection.h"
#import "MZUtility.h"
@protocol DownloadItemsAvailableViewControllerDelegate<NSObject>
- (void)addDownloadTask:(NSString *)fileName fileURL:(NSString *)fileURL;
- (void)openFileWithName:(NSString *)fileName;
- (void)openOrderHistoryDetailWithID:(NSString*)orderId;
@end
@protocol  DownloadItemsAvailableTableViewCellDelegate<NSObject>
- (void)downloadItem:(SimiRow*)row atIndex:(NSInteger)index;
- (void)openFileOnCellWithName:(NSString *)fileName;
@end

@interface DownloadItemsAvailableViewController : SimiViewController<UITableViewDataSource, UITableViewDelegate, DownloadItemsAvailableTableViewCellDelegate>
@property (nonatomic, strong) DownloadModelCollection *downloadModelCollection;
@property (nonatomic, strong) UITableView *tableDownloadItems;
@property (nonatomic, strong) SimiTable *cells;
@property (nonatomic, strong) id<DownloadItemsAvailableViewControllerDelegate> delegate;
@property (nonatomic) int countSuccess;
@property (nonatomic, strong) NSMutableArray *downloadedFilesArray;
@property(nonatomic, strong) NSMutableArray *downloadingArray;
@property (nonatomic, strong) NSFileManager *fileManger;
@end

@interface DownloadItemsAvailableTableViewCell : UITableViewCell
@property (nonatomic, strong) SimiRow *rowData;
@property (nonatomic, strong) id<DownloadItemsAvailableTableViewCellDelegate> delegate;
@property (nonatomic) NSInteger index;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withData:(SimiRow*)row withIndex:(NSInteger)rowIndex;
@end