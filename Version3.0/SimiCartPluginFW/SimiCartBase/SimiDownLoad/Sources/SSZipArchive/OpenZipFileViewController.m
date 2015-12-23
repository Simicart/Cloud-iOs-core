//
//  OpenZipFileViewController.m
//  SimiCartPluginFW
//
//  Created by Gin on 11/10/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import "OpenZipFileViewController.h"
#import "SimiSection.h"
#import "SSZipArchive.h"
#import "Constants.h"

@interface OpenZipFileViewController ()

@end

@implementation OpenZipFileViewController{
    NSString *fileName;
    NSString *linkZip;
    BOOL isUnzip;
}
@synthesize tableView,filePath,array,nameFolder;
- (void)viewDidLoadBefore
{
    isUnzip = NO;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    CGRect frame = self.view.bounds;
    frame.size.height =  frame.size.height -110;
    tableView = [[SimiTableView alloc]initWithFrame:frame];
    tableView.delegate = self;
    tableView.dataSource = self;
    if(SIMI_SYSTEM_IOS >=9.0){
        tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [self.view addSubview:tableView];
    [self unzipAndSaveFile];
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    [self reloadData];
}
- (void)unzipAndSaveFile{
    NSString *destinationPath = [NSString stringWithFormat:@"%@/FileUnzip/%@",[self applicationDocumentsDirectory],nameFolder];
    [SSZipArchive unzipFileAtPath:filePath toDestination:destinationPath overwrite:YES password:nil error:nil];
}
- (NSString *)applicationDocumentsDirectory {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

- (void)reloadData
{
    array = [[NSMutableArray alloc] init];
    _fileManger = [NSFileManager defaultManager];
    NSError *error;
    if (isUnzip == NO) {
        linkZip = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/FileUnzip/%@",nameFolder]];
    }
    array = [[_fileManger contentsOfDirectoryAtPath:linkZip error:&error] mutableCopy];
    if([array containsObject:@".DS_Store"])
        [array removeObject:@".DS_Store"];
    [tableView reloadData];
}
-(void)btnDeleteDownloadClick:(NSInteger)row{
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    NSError *error;
    [fileMgr removeItemAtURL:fileURL error:&error];
    [array removeObjectAtIndex:row];
    [tableView reloadData];
}

-(void)btnOpenClick:(NSInteger)row{
    [self.delegate sendFilePath:linkZip];
    [self.delegate openFileWithName:nameFolder];
}

#pragma mark UITableView Datasource & Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell.textLabel setText:[array objectAtIndex:indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return array.count;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:nil  message:nil  preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Open" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        isUnzip = YES;
        nameFolder = [array objectAtIndex:indexPath.row];
        NSString* fileExtension = [nameFolder pathExtension];
        if (fileExtension.length > 0) {
            [self btnOpenClick:indexPath.row];
        }else
        {   linkZip = [linkZip stringByAppendingString:[NSString stringWithFormat:@"/%@",nameFolder]];
            [self reloadData];
        }
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Remove" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self btnDeleteDownloadClick:indexPath.row];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}



@end
