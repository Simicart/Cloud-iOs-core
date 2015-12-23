//
//  DownloadManageDownloadedViewController.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 9/10/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "DownloadItemsDownloadedViewController.h"
#import "SimiGlobalVar.h"
#import "UIImage+SimiCustom.h"
#import "SCAppDelegate.h"

@interface DownloadItemsDownloadedViewController ()

@end

@implementation DownloadItemsDownloadedViewController{
    NSString *fileName;
}

- (void)viewDidLoadBefore
{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    float tableWidth = SCREEN_WIDTH;
    float tableHeight = SCREEN_HEIGHT - 110;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        tableWidth = 2*SCREEN_WIDTH/3;
        tableHeight = 2*SCREEN_HEIGHT/3 -110;
    }
    
    _tableItemsDownloaded = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, tableWidth, tableHeight)];
    _tableItemsDownloaded.delegate = self;
    _tableItemsDownloaded.dataSource = self;
    _tableItemsDownloaded.allowsMultipleSelectionDuringEditing = NO;
    if(SIMI_SYSTEM_IOS >=9.0){
        _tableItemsDownloaded.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [self.view addSubview:_tableItemsDownloaded];
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    [self reloadData];
}

- (void)reloadData
{
    _downloadedFilesArray = [[NSMutableArray alloc] init];
    _fileManger = [NSFileManager defaultManager];
    NSError *error;
    _downloadedFilesArray = [[_fileManger contentsOfDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"] error:&error] mutableCopy];
    
    for (int i = 0; i<_downloadedFilesArray.count; i++) {
        NSString *string = [_downloadedFilesArray objectAtIndex:i];
        if ([string containsString:@"Unzip"]) {
            [_downloadedFilesArray removeObjectAtIndex:i];
        }
    }
    if([_downloadedFilesArray containsObject:@".DS_Store"])
        [_downloadedFilesArray removeObject:@".DS_Store"];
    [_tableItemsDownloaded reloadData];
}

-(void)btnDeleteDownloadClick:(NSInteger)row{
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    NSString *destinationPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"] stringByAppendingPathComponent:[_downloadedFilesArray objectAtIndex:row]];
    NSURL *fileURL = [NSURL fileURLWithPath:destinationPath];
    NSError *error;
    [fileMgr removeItemAtURL:fileURL error:&error];
    [_downloadedFilesArray removeObjectAtIndex:row];
    [_tableItemsDownloaded reloadData];
}

-(void)btnOpenClick:(NSInteger)row{
    fileName = [_downloadedFilesArray objectAtIndex:row];
    [self.delegate openFileWithName:fileName];
}

#pragma mark UITableView Datasource & Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (MGSwipeTableCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MGSwipeTableCell *cell = [[MGSwipeTableCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell.textLabel setText:[_downloadedFilesArray objectAtIndex:indexPath.row]];
    [cell.textLabel setNumberOfLines:2];
    //configure right buttons
    cell.delegate = self;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _downloadedFilesArray.count;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:nil  message:nil  preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:SCLocalizedString(@"Open") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self btnOpenClick:indexPath.row];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:SCLocalizedString(@"Remove") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self btnDeleteDownloadClick:indexPath.row];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:SCLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
     */
    fileName = [_downloadedFilesArray objectAtIndex:indexPath.row];
    [self.delegate openFileWithName:fileName];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}

/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        NSFileManager* fileMgr = [NSFileManager defaultManager];
        NSString *destinationPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"] stringByAppendingPathComponent:[_downloadedFilesArray objectAtIndex:indexPath.row]];
        NSURL *fileURL = [NSURL fileURLWithPath:destinationPath];
        NSError *error;
        [fileMgr removeItemAtURL:fileURL error:&error];
        [_downloadedFilesArray removeObjectAtIndex:indexPath.row];
        [tableView endUpdates];
    }
}
 */


#pragma mark MGSwipe Delegate
-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;
{
    return YES;
}

-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings
{
    swipeSettings.transition = MGSwipeTransitionBorder;
    expansionSettings.buttonIndex = 0;
    
    __weak DownloadItemsDownloadedViewController * me = self;
    
    if (direction == MGSwipeDirectionRightToLeft) {
        expansionSettings.fillOnTrigger = YES;
        expansionSettings.threshold = 1.5;
        
        CGFloat padding = 15;
        
        MGSwipeButton * trash = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"ic_delete_download_item"] backgroundColor:[UIColor colorWithRed:1.0 green:59/255.0 blue:50/255.0 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            
            NSIndexPath * indexPath = [me.tableItemsDownloaded indexPathForCell:sender];
            [me.tableItemsDownloaded beginUpdates];
            [me.tableItemsDownloaded deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            NSFileManager* fileMgr = [NSFileManager defaultManager];
            NSString *destinationPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"] stringByAppendingPathComponent:[_downloadedFilesArray objectAtIndex:indexPath.row]];
            NSURL *fileURL = [NSURL fileURLWithPath:destinationPath];
            NSError *error;
            [fileMgr removeItemAtURL:fileURL error:&error];
            [_downloadedFilesArray removeObjectAtIndex:indexPath.row];
            [me.tableItemsDownloaded endUpdates];
            return NO; //don't autohide to improve delete animation
        }];
        return @[trash];
    }
    
    return nil;
    
}

-(void) swipeTableCell:(MGSwipeTableCell*) cell didChangeSwipeState:(MGSwipeState)state gestureIsActive:(BOOL)gestureIsActive
{
    
}
@end
