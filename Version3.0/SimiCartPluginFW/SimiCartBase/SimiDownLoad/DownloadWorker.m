//
//  DownloadWorker.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 9/9/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "DownloadWorker.h"
#import <SimiCartBundle/SimiTable.h>
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SimiRow.h>
#import <SimiCartBundle/SCAppDelegate.h>
#import <SimiCartBundle/SCNavigationBarPad.h>
#import "DownloadControlViewController.h"
@implementation DownloadWorker
{
    SimiTable *cells;
    
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initCellsAfter:) name:@"SCLeftMenu_InitCellsAfter" object:nil];
    }
    return self;
}

- (void)initCellsAfter:(NSNotification*)noti
{
    if ([noti.name isEqualToString:@"SCLeftMenu_InitCellsAfter"]) {
        cells = (SimiTable *)noti.object;
        for (int i = 0; i < cells.count; i++) {
            SimiSection *section = [cells objectAtIndex:i];
            if ([section.identifier isEqualToString:LEFTMENU_SECTION_MAIN] && [[SimiGlobalVar sharedInstance]isLogin]) {
                int emailContactSortOrder = 0;
                for (int j = 0; j < section.count; j++) {
                    SimiRow *row = [section objectAtIndex:j];
                    if ([row.identifier isEqualToString:LEFTMENU_ROW_ORDERHISTORY]) {
                        emailContactSortOrder = (int)row.sortOrder + 10;
                    }
                }
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                    SimiRow *row = [[SimiRow alloc]initWithIdentifier:LEFTMENU_ROW_DOWNLOAD height:45 sortOrder:emailContactSortOrder];
                    row.image = [UIImage imageNamed:@"ic_down"];
                    row.title = SCLocalizedString(@"Manage DownLoads");
                    [section addObject:row];
                }else
                {
                    SimiRow *row = [[SimiRow alloc]initWithIdentifier:LEFTMENU_ROW_DOWNLOAD height:60 sortOrder:emailContactSortOrder];
                    row.image = [UIImage imageNamed:@"ic_down"];
                    row.title = SCLocalizedString(@"Manage DownLoads");
                    [section addObject:row];
                }
                [section sortItems];
            }
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end


