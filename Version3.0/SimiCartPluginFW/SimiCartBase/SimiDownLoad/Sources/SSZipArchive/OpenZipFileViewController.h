//
//  OpenZipFileViewController.h
//  SimiCartPluginFW
//
//  Created by Gin on 11/10/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import "SimiTableView.h"
@protocol OpenZipFileViewControllerDelegate<NSObject>
- (void)openFileWithName:(NSString*)fileName;
- (void)sendFilePath:(NSString *)filePathString;
@end
@interface OpenZipFileViewController : SimiViewController<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) SimiTableView *tableView;
@property (nonatomic,strong) NSMutableArray *array;
@property (nonatomic,strong) NSMutableArray *cells;
@property (nonatomic,strong) NSString *filePath;
@property (nonatomic,strong) NSString *nameFolder;
@property (nonatomic,strong) NSFileManager *fileManger;
@property (nonatomic, strong) id<OpenZipFileViewControllerDelegate> delegate;
- (void)reloadData;

@end
