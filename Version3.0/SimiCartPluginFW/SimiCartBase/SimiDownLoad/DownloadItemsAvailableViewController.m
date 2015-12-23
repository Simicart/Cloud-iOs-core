//
//  DownloadManageViewController.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 9/10/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "DownloadItemsAvailableViewController.h"
@interface DownloadItemsAvailableViewController ()

@end
static NSString *SectionControlAvailable = @"SectionControlAvailable";
static NSString *rowDownloadAvailabel = @"rowDownloadAvailabel";
static NSString *downloadNotAvailable = @"downloadNotAvailable";

@implementation DownloadItemsAvailableViewController{
}
-(void)viewDidLoadBefore
{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    _tableDownloadItems = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableDownloadItems.dataSource = self;
    _tableDownloadItems.delegate = self;
    if(SIMI_SYSTEM_IOS >=9.0){
        _tableDownloadItems.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [self.view addSubview:_tableDownloadItems];
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    if ([SimiGlobalVar sharedInstance].needGetDownloadItems || [SimiGlobalVar sharedInstance].downloadModelCollection == nil) {
        [SimiGlobalVar sharedInstance].needGetDownloadItems = NO;
        [self getListDownloadItems];
    }else
    {
        _downloadModelCollection = [SimiGlobalVar sharedInstance].downloadModelCollection;
        [self setCells:nil];
    }
        
}
- (void)viewDidAppearBefore:(BOOL)animated
{
    [_tableDownloadItems setFrame:self.view.bounds];
}

#pragma mark Get List Download Items
- (void)getListDownloadItems
{
    if (_downloadModelCollection == nil) {
        _downloadModelCollection = [DownloadModelCollection new];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetDownloadItems:) name:@"DidGetDownloadItems" object:nil];
    [_downloadModelCollection getDownloadItemsWithParams:@{}];
    [self startLoadingData];
}

- (void)didGetDownloadItems:(NSNotification*)noti
{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([[responder.status uppercaseString]isEqualToString:@"SUCCESS"]) {
        if (_downloadModelCollection.count > 0) {
            [SimiGlobalVar sharedInstance].downloadModelCollection = _downloadModelCollection;
            _countSuccess = 0;
            [self stopLoadingData];
            NSMutableArray *arrayProductPending = [NSMutableArray new];
            for (int i = 0; i < _downloadModelCollection.count; i++) {
                SimiModel *model = [_downloadModelCollection objectAtIndex:i];
                if ([[model valueForKey:@"order_status"] isEqualToString:@"expired"]) {
                    [model setValue:@"YES" forKey:downloadNotAvailable];
                }
                if ([[model valueForKey:@"order_status"] isEqualToString:@"pending"]) {
                    [arrayProductPending addObject:model];
                }
            }
            [self setCells:nil];
            
            for (int i = 0; i < arrayProductPending.count; i++) {
                SimiModel *model = [arrayProductPending objectAtIndex:i];
                NSURL *url = [NSURL URLWithString:[model valueForKey:@"order_link"]];
                NSMutableURLRequest *request = [NSMutableURLRequest
                                                requestWithURL:url
                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                timeoutInterval:30.0];
                
                [request setHTTPMethod:@"HEAD"];
                NSOperationQueue *queue = [NSOperationQueue mainQueue];
                [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                    [model setValue:response.suggestedFilename forKey:@"c"];
                    if (response == nil || ![httpResponse.allHeaderFields valueForKey:@"Content-Disposition"]) {
                        [model setValue:@"YES" forKey:downloadNotAvailable];
                    }
                    _countSuccess += 1;
                    if (_countSuccess == _downloadModelCollection.count) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self setCells:nil];
                            return;
                        });
                    }
                }];
            }
        }else
            dispatch_async(dispatch_get_main_queue(), ^{
                [self stopLoadingData];
            });
    }else
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopLoadingData];
        });
    [self removeObserverForNotification:noti];
}

#pragma mark Set Cells
- (void)setCells:(SimiTable *)cells
{
    if (cells) {
        _cells = cells;
    }else
    {
        _cells = [SimiTable new];
        SimiSection *section = [[SimiSection alloc]initWithIdentifier:SectionControlAvailable];
        _downloadedFilesArray = [[NSMutableArray alloc] init];
        _fileManger = [NSFileManager defaultManager];
        NSError *error;
        _downloadedFilesArray = [[_fileManger contentsOfDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"] error:&error] mutableCopy];
        if([_downloadedFilesArray containsObject:@".DS_Store"])
            [_downloadedFilesArray removeObject:@".DS_Store"];
        for (int j = 0; j < _downloadModelCollection.count; j++) {
            SimiModel *model = [_downloadModelCollection objectAtIndex:j];
            [model setValue:@"NO" forKey:@"order_link_isDownloaded"];
            [model setValue:@"NO" forKey:@"order_link_isDownloading"];
        }

        for (int i = 0; i < _downloadedFilesArray.count; i++) {
            for (int j = 0; j < _downloadModelCollection.count; j++) {
                NSString *stringDownloadedFileName = [_downloadedFilesArray objectAtIndex:i];
                SimiModel *model = [_downloadModelCollection objectAtIndex:j];
                if ([(NSString*)[model valueForKey:@"order_file"] isEqualToString:stringDownloadedFileName]) {
                    [model setValue:@"YES" forKey:@"order_link_isDownloaded"];
                }
            }
        }
        for (int i = 0; i < self.downloadingArray.count; i++) {
            for (int j = 0; j < _downloadModelCollection.count; j++) {
                NSString *stringDownloadingFileName = [[self.downloadingArray objectAtIndex:i]valueForKey:@"order_file"];
                SimiModel *model = [_downloadModelCollection objectAtIndex:j];
                if ([(NSString*)[model valueForKey:@"order_file"] isEqualToString:stringDownloadingFileName]) {
                    [model setValue:@"YES" forKey:@"order_link_isDownloading"];
                }
            }
        }
        if (_downloadModelCollection.count > 0) {
            for (int i = 0; i < _downloadModelCollection.count; i++) {
                SimiModel *model = [_downloadModelCollection objectAtIndex:i];
                SimiRow *row = [[SimiRow alloc]initWithIdentifier:rowDownloadAvailabel height:50];
                row.data = model;
                row.height = 160;
                [section addRow:row];
            }
        }
        [_cells addObject:section];
    }
    [_tableDownloadItems reloadData];
}

#pragma mark TableView Delegate & DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SimiSection *simiSection = [_cells objectAtIndex:section];
    return simiSection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection objectAtIndex:indexPath.row];
    NSString *cellIdentifier = [NSString stringWithFormat:@"%@%@",rowDownloadAvailabel,[simiRow.data valueForKey:@"order_id"]];
    DownloadItemsAvailableTableViewCell *cell = [[DownloadItemsAvailableTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withData:simiRow withIndex:indexPath.row];
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (cell) {
        return cell;
    }
    return [UITableViewCell new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection objectAtIndex:indexPath.row];
    return simiRow.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection objectAtIndex:indexPath.row];
    [self.delegate openOrderHistoryDetailWithID:[simiRow.data valueForKey:@"order_id"]];
}

#pragma mark Download Available Cell Delegate
- (void)downloadItem:(SimiRow *)row atIndex:(NSInteger)index
{
    NSString *stringPath = [row.data valueForKey:@"order_link"];
    NSString *stringFileName = [row.data valueForKey:@"order_file"];
    [self.delegate addDownloadTask:stringFileName fileURL:stringPath];
    [[_downloadModelCollection objectAtIndex:index]setValue:@"YES" forKey:@"order_link_isDownloading"];
}
-(void)openFileOnCellWithName:(NSString *)fileName{
    [self.delegate openFileWithName:fileName];
}
@end

#pragma mark DownloadItemsAvailableTableViewCell
@implementation DownloadItemsAvailableTableViewCell
{
    SimiModel *model;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withData:(SimiRow *)row withIndex:(NSInteger)rowIndex
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.index = rowIndex;
    if (self) {
        float widthCell = SCREEN_WIDTH;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            widthCell = 2*SCREEN_WIDTH/3;
        }
        float padding = 15;
        float titlePaddingLeft = padding;
        float titleWidth = 90;
        float valuePaddingLeft =  titlePaddingLeft + titleWidth + padding;
        float valueWidth = widthCell - valuePaddingLeft - padding;
        float heightCell = 0;
        float heightLabel = 20;
        self.rowData = row;
        model = (SimiModel *)_rowData.data;
        NSString *titleObjectName = @"titleObjectName";
        NSString *valueObjectName = @"valueObjectName";
        
        UILabel *orderNameTitle = [[UILabel alloc]initWithFrame:CGRectMake(titlePaddingLeft, heightCell, titleWidth, heightLabel*2)];
        [orderNameTitle setText:[NSString stringWithFormat:@"%@",SCLocalizedString(@"Product Name")]];
        orderNameTitle.simiObjectName = titleObjectName;
        [self addSubview:orderNameTitle];
        
        UILabel *orderNameValue = [[UILabel alloc]initWithFrame:CGRectMake(valuePaddingLeft, heightCell,valueWidth, heightLabel*2)];
        [orderNameValue setText:[NSString stringWithFormat:@"%@",[model valueForKey:@"order_name"]]];
        orderNameValue.simiObjectName = valueObjectName;
        orderNameValue.numberOfLines = 2;
        orderNameValue.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:orderNameValue];
        heightCell += heightLabel*2;
        
        UILabel *orderDateTitle = [[UILabel alloc]initWithFrame:CGRectMake(titlePaddingLeft, heightCell, titleWidth, heightLabel)];
        [orderDateTitle setText:[NSString stringWithFormat:@"%@",SCLocalizedString(@"Order Date")]];
        orderDateTitle.simiObjectName = titleObjectName;
        [self addSubview:orderDateTitle];
        
        UILabel *orderDateValue = [[UILabel alloc]initWithFrame:CGRectMake(valuePaddingLeft, heightCell,valueWidth, heightLabel)];
        [orderDateValue setText:[NSString stringWithFormat:@"%@",[model valueForKey:@"order_date"]]];
        orderDateValue.simiObjectName = valueObjectName;
        [self addSubview:orderDateValue];
        heightCell += heightLabel;
        
        UILabel *orderStatusTitle = [[UILabel alloc]initWithFrame:CGRectMake(titlePaddingLeft, heightCell, titleWidth, heightLabel)];
        [orderStatusTitle setText:[NSString stringWithFormat:@"%@",SCLocalizedString(@"Order Status")]];
        orderStatusTitle.simiObjectName = titleObjectName;
        [self addSubview:orderStatusTitle];
        
        UILabel *orderStatusValue = [[UILabel alloc]initWithFrame:CGRectMake(valuePaddingLeft, heightCell,valueWidth, heightLabel)];
        [orderStatusValue setText:[NSString stringWithFormat:@"%@",[model valueForKey:@"order_status"]]];
        orderStatusValue.simiObjectName = valueObjectName;
        [self addSubview:orderStatusValue];
        heightCell += heightLabel;
        
        UILabel *orderRemainTitle = [[UILabel alloc]initWithFrame:CGRectMake(titlePaddingLeft, heightCell, titleWidth, heightLabel)];
        [orderRemainTitle setText:[NSString stringWithFormat:@"%@",SCLocalizedString(@"Order Remain")]];
        orderRemainTitle.simiObjectName = titleObjectName;
        [self addSubview:orderRemainTitle];
        
        UILabel *orderRemainValue = [[UILabel alloc]initWithFrame:CGRectMake(valuePaddingLeft, heightCell,valueWidth, heightLabel)];
        [orderRemainValue setText:[NSString stringWithFormat:@"%@",[model valueForKey:@"order_remain"]]];
        orderRemainValue.simiObjectName = valueObjectName;
        [self addSubview:orderRemainValue];
        heightCell += heightLabel + padding;
        
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel*)view;
                if ([label.simiObjectName isEqualToString:titleObjectName]) {
                    [label setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:14]];
                }else if ([label.simiObjectName isEqualToString:valueObjectName])
                {
                    [label setFont:[UIFont fontWithName:THEME_FONT_NAME size:14]];
                }
            }
        }
        
        UIButton *downloadButton = [[UIButton alloc]initWithFrame:CGRectMake(padding, heightCell, widthCell - padding*2, heightLabel*2)];
        [downloadButton addTarget:self action:@selector(downloadItem:) forControlEvents:UIControlEventTouchUpInside];
        [downloadButton addTarget:self action:@selector(changeColor:) forControlEvents:UIControlEventTouchDown];
        [downloadButton setTitle:SCLocalizedString(@"Download") forState:UIControlStateNormal];
        if ([[model valueForKey:@"order_link_isDownloaded"]boolValue]) {
            [downloadButton setTitle:SCLocalizedString(@"Re-download") forState:UIControlStateNormal];
            [downloadButton setFrame:CGRectMake(padding, heightCell, widthCell/2 - padding*3, heightLabel*2)];
            [downloadButton.titleLabel setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:16]];
            [downloadButton setEnabled:YES];
            [downloadButton setAlpha:1.0];
            
            UIButton *btnOpen = [[UIButton alloc] initWithFrame:CGRectMake( widthCell/2 -padding, heightCell, widthCell/2, heightLabel*2)];
            [btnOpen addTarget:self action:@selector(openClick) forControlEvents:UIControlEventTouchUpInside];
            [btnOpen setBackgroundColor:THEME_COLOR];
            [btnOpen setTitle:@"Open file" forState:UIControlStateNormal];
            [btnOpen.titleLabel setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:16]];
            [self addSubview:btnOpen];
            
        }else if ([[model valueForKey:@"order_link_isDownloading"]boolValue])
        {
            [downloadButton setTitle:SCLocalizedString(@"Downloading") forState:UIControlStateNormal];
            [downloadButton setEnabled:NO];
            [downloadButton setAlpha:0.5];
        }
        [downloadButton setBackgroundColor:THEME_COLOR];
        [downloadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:downloadButton];
    }
    return self;
}

-(void)openClick{
    NSString *fileName = [model objectForKey:@"order_file"];
    [self.delegate openFileOnCellWithName:fileName];
}

- (void)downloadItem:(id)sender
{
    UIButton *downloadButton = (UIButton*)sender;
    [downloadButton setBackgroundColor:THEME_COLOR];
    if ([[self.rowData.data valueForKey:downloadNotAvailable] boolValue]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:SCLocalizedString(@"The link is not available") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles:nil];
        [alert show];
        return;
    }
    [downloadButton setTitle:@"Downloading" forState:UIControlStateNormal];
    [downloadButton setEnabled:NO];
    [downloadButton setAlpha:0.5];
    [self.delegate downloadItem:self.rowData atIndex:self.index];
}

- (void)changeColor:(id)sender
{
//     UIButton *downloadButton = (UIButton*)sender;
//    [downloadButton setBackgroundColor:[UIColor redColor]];
}
@end
