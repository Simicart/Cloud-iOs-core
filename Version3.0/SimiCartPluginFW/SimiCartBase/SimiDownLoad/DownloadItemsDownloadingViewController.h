//
//  DownloadItemsDownloadingViewController.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 9/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//
extern NSString * const kMZDownloadKeyURL;
extern NSString * const kMZDownloadKeyStartTime;
extern NSString * const kMZDownloadKeyFileName;
extern NSString * const kMZDownloadKeyProgress;
extern NSString * const kMZDownloadKeyTask;
extern NSString * const kMZDownloadKeyStatus;
extern NSString * const kMZDownloadKeyDetails;
extern NSString * const kMZDownloadKeyResumeData;

extern NSString * const RequestStatusDownloading;
extern NSString * const RequestStatusPaused;
extern NSString * const RequestStatusFailed;

#import <SimiCartBundle/SimiCartBundle.h>
#import "MZUtility.h"
@class DownloadItemsDownloadingTableViewCell;
@protocol ItemsDownloadingDelegate <NSObject>
@optional
/**A delegate method called each time whenever new download task is start downloading
 */
- (void)downloadRequestStarted:(NSURLSessionDownloadTask *)downloadTask;
/**A delegate method called each time whenever any download task is cancelled by the user
 */
- (void)downloadRequestCanceled:(NSURLSessionDownloadTask *)downloadTask;
/**A delegate method called each time whenever any download task is finished successfully
 */
- (void)downloadRequestFinished:(NSString *)fileName;
@end

@protocol  DownloadItemsDownloadingTableViewCellDelegate <NSObject>
- (void)deleteRowAtIndex:(DownloadItemsDownloadingTableViewCell*)cell;
@end

@interface DownloadItemsDownloadingViewController : SimiViewController<NSURLSessionDelegate, UITableViewDataSource, UITableViewDelegate, DownloadItemsDownloadingTableViewCellDelegate>
@property (nonatomic, strong) UITableView *tableItemsDownloading;
/**An array that holds the information about all downloading tasks.
 */
@property(nonatomic, strong) NSMutableArray *downloadingArray;
/**A table view for displaying details of on going download tasks.
 */
@property(nonatomic, strong) NSURLSession *sessionManager;
@property (nonatomic, weak) id<ItemsDownloadingDelegate> delegate;

- (NSURLSession *)backgroundSession;
/**A method for adding new download task.
 @param NSString* file name
 @param NSString* file url
 */
- (void)addDownloadTask:(NSString *)fileName fileURL:(NSString *)fileURL;
/**A method for restoring any interrupted download tasks e.g user force quits the app or any network error occurred.
 */
- (void)populateOtherDownloadTasks;
@end

@interface  DownloadItemsDownloadingTableViewCell: UITableViewCell
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UILabel *lblDetails;
@property (nonatomic, strong) UIProgressView *progressDownload;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) id<DownloadItemsDownloadingTableViewCellDelegate> delegate;
@property (nonatomic) NSInteger rowIndex;
@end
