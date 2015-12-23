//
//  DownloadControlViewController.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 9/10/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "DownloadControlViewController.h"
#import <MediaPlayer/MPMoviePlayerViewController.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#import "SCAppDelegate.h"
#import "EbookViewController.h"
#import "OpenZipFileViewController.h"

@interface DownloadControlViewController ()

@end

@implementation DownloadControlViewController{
    NSString *string;
    BOOL isOpenZip;
    NSString *filePath;
}
#pragma mark Init View
- (void)viewDidLoadBefore
{
    isOpenZip = NO;
    self.navigationItem.title = [self formatTitleString:SCLocalizedString(@"Manage Downloadable Products")];
    if (UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPhone) {
        [super viewDidLoadBefore];
    }
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    [self initPageScrollView];
    [self initDownloadAvailable];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didPopulateOtherDownloadTasks:) name:@"DidPopulateOtherDownloadTasks" object:nil];
    [self initDownloading];
    [self initDownloaded];
    [self.view addSubview:_pageScrollView];
    [_pageScrollView generate];
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    
}

- (void)didPopulateOtherDownloadTasks:(NSNotification*)noti
{
    _downloadAvailable.downloadingArray = _downloadingViewController.downloadingArray;
    [_downloadAvailable setCells:nil];
}

- (void)initPageScrollView
{
    _pageScrollView = [[LazyPageScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT -  64)];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [_pageScrollView setFrame:CGRectMake(0, 0, SCREEN_WIDTH *2/3, SCREEN_HEIGHT *2/3)];
    }

    [_pageScrollView setDelegate:self];
    [_pageScrollView initTab:YES Gap:50 TabHeight:60 VerticalDistance:5 BkColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#eeeeee"]];
    [_pageScrollView enableTabBottomLine:YES LineHeight:3 LineColor:[[SimiGlobalVar sharedInstance]colorWithHexString:@"#c3c3c3"] LineBottomGap:0 ExtraWidth:10];
    [_pageScrollView setTitleStyle:[UIFont fontWithName:THEME_FONT_NAME size:12] Color:[[SimiGlobalVar sharedInstance ] colorWithHexString:@"141414"] SelColor:THEME_COLOR];
    [_pageScrollView enableBreakLine:NO Width:1 TopMargin:0 BottomMargin:0 Color:[UIColor blackColor]];
    _pageScrollView.leftTopView = [[UIView alloc]initWithFrame:CGRectZero];
    _pageScrollView.rightTopView = [[UIView alloc]initWithFrame:CGRectZero];
    [_pageScrollView setBackgroundColor:[UIColor whiteColor]];
//    _pageScrollView.viewScrollMain.scrollEnabled = NO;
}

- (void)initDownloadAvailable
{
    _downloadAvailable = [DownloadItemsAvailableViewController new];
    _downloadAvailable.delegate = self;
    [self addChildViewController:_downloadAvailable];
    [_pageScrollView addTab:SCLocalizedString(@"Download Availability") View:_downloadAvailable.view Info:nil];
}

- (void)initDownloaded
{
    _downloadedViewController = [DownloadItemsDownloadedViewController new];
    _downloadedViewController.delegate = self;
    [self addChildViewController:_downloadedViewController];
    [_pageScrollView addTab:SCLocalizedString(@"Downloaded") View:_downloadedViewController.view Info:nil];
}

- (void)initDownloading
{
    _downloadingViewController = [DownloadItemsDownloadingViewController new];
    [self addChildViewController:_downloadingViewController];
    [_pageScrollView addTab:SCLocalizedString(@"Downloading") View:_downloadingViewController.view Info:nil];
}

#pragma mark Download Available & Downloaded Delegate
- (void)addDownloadTask:(NSString *)fileName fileURL:(NSString *)fileURL
{
    [_downloadingViewController addDownloadTask:fileName fileURL:fileURL];
}

- (void)openOrderHistoryDetailWithID:(NSString *)orderId
{
    SCOrderDetailViewController *orderHistoryDetail = [SCOrderDetailViewController new];
    orderHistoryDetail.orderId = orderId;
    [self.navigationController pushViewController:orderHistoryDetail animated:YES];
}

- (void)openFileWithName:(NSString *)fileName
{
    NSString *fileExtension = [fileName pathExtension];
    if (isOpenZip == NO) {
        filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"] stringByAppendingPathComponent:fileName];
    }else{
        filePath  = [filePath stringByAppendingString:[NSString stringWithFormat:@"/%@",fileName]];
        isOpenZip = NO;
    }
    
    //  File Video and Audio
    if([fileExtension isEqualToString:@"mp4"]||[fileExtension isEqualToString:@"3gp"]||[fileExtension isEqualToString:@"afs"]||[fileExtension isEqualToString:@"avi"]||[fileExtension isEqualToString:@"mov"]||[fileExtension isEqualToString:@"rm"]||[fileExtension isEqualToString:@"vob"]||[fileExtension isEqualToString:@"wmv"]||[fileExtension isEqualToString:@"mp3"]||[fileExtension isEqualToString:@"wav"]
       )
    {
        MPMoviePlayerViewController *myPlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:filePath]];
        [self presentMoviePlayerViewControllerAnimated:myPlayer];
        [myPlayer.moviePlayer play];
    }else if ([fileExtension isEqualToString:@"zip"]){
        OpenZipFileViewController *openVC = [OpenZipFileViewController new];
        openVC.filePath = filePath;
        openVC.nameFolder = fileName;
        openVC.delegate = self;
        [self.navigationController pushViewController:openVC animated:YES];
    }else if ([fileExtension isEqualToString:@"epub"]||[fileExtension isEqualToString:@"prc"]||[fileExtension isEqualToString:@"PDF"]){
        EbookViewController *ebookViewController = [EbookViewController new];
        ebookViewController._strFileName = fileName;
        ebookViewController.filePath = filePath;
        [self.navigationController pushViewController:ebookViewController animated:YES];
    }else if ([fileExtension isEqualToString:@"docx"]||[fileExtension isEqualToString:@"doc"]||[fileExtension isEqualToString:@"pptx"]||[fileExtension isEqualToString:@"ppt"]||[fileExtension isEqualToString:@"png"]||[fileExtension isEqualToString:@"jpg"]||[fileExtension isEqualToString:@"bmp"]||[fileExtension isEqualToString:@"jpeg"]||[fileExtension isEqualToString:@"gif"]||[fileExtension isEqualToString:@"tiff"]||[fileExtension isEqualToString:@"tga"]||[fileExtension isEqualToString:@"ico"]||[fileExtension isEqualToString:@"jp2"]||[fileExtension isEqualToString:@"xls"]||[fileExtension isEqualToString:@"pdf"]||[fileExtension isEqualToString:@"odt"]||[fileExtension isEqualToString:@"xlsx"]||[fileExtension isEqualToString:@"txt"]||[fileExtension isEqualToString:@"pps"]||[fileExtension isEqualToString:@"ppsx"]||[fileExtension isEqualToString:@"rtf"]){
        string = filePath;
        QLPreviewController *previewController=[[QLPreviewController alloc]init];
        previewController.delegate=self;
        previewController.dataSource=self;
        [self presentViewController:previewController animated:YES completion:NULL];
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:SCLocalizedString(@"This file cannot viewed on app") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark Lazy Delegate
-(void)LazyPageScrollViewPageChange:(LazyPageScrollView *)pageScrollView Index:(NSInteger)index PreIndex:(NSInteger)preIndex
{
    switch (index) {
        case 0:
            _downloadAvailable.downloadingArray = _downloadingViewController.downloadingArray;
            [_downloadAvailable setCells:nil];
            break;
        case 2:
        {
            [_downloadedViewController reloadData];
            _downloadAvailable.downloadedFilesArray = _downloadedViewController.downloadedFilesArray;
        }
            break;
        default:
            break;
    }
}

- (void)LazyPageScrollViewEdgeSwipe:(LazyPageScrollView *)pageScrollView Left:(BOOL)bLeft
{
    
}

#pragma mark Open file
-(void)sendFilePath:(NSString *)filePathString{
    isOpenZip = YES;
    filePath =  filePathString;
}
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
   
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return [NSURL fileURLWithPath:string];
}

#pragma mark - delegate methods


- (BOOL)previewController:(QLPreviewController *)controller shouldOpenURL:(NSURL *)url forPreviewItem:(id <QLPreviewItem>)item
{
    return YES;
}

- (CGRect)previewController:(QLPreviewController *)controller frameForPreviewItem:(id <QLPreviewItem>)item inSourceView:(UIView **)view
{
    return self.view.frame;
}

@end
