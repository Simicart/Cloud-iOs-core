//
//  SCLeftMenuPhoneViewController.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/4/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SimiCartBundle.h"
#import "SimiViewController.h"
#import "SimiStoreModelCollection.h"
#import "SimiTable.h"
#import "SimiCMSPagesModelCollection.h"
static NSString *LEFTMENU_SECTION_MAIN = @"LEFTMENU_SECTION_MAIN";
static NSString *LEFTMENU_SECTION_MORE = @"LEFTMENU_SECTION_MORE";
static NSString *LEFTMENU_ROW_HOME = @"LEFTMENU_ROW_HOME";
static NSString *LEFTMENU_ROW_CATEGORY = @"LEFTMENU_ROW_CATEGORY";
static NSString *LEFTMENU_ROW_ORDERHISTORY = @"LEFTMENU_ROW_ORDERHISTORY";
static NSString *LEFTMENU_ROW_SETTING = @"LEFTMENU_ROW_SETTING";
static NSString *LEFTMENU_ROW_CMS = @"LEFTMENU_ROW_CMS";
static NSString *LEFTMENU_ROW_LOGIN = @"LEFTMENU_ROW_LOGIN";
static NSString *LEFTMENU_ROW_DOWNLOAD = @"LEFTMENU_ROW_DOWNLOAD";

@class SCLeftMenuViewController;
@protocol SCLeftMenuPhoneViewController_Delegate <NSObject>
@optional
- (void)menu:(SCLeftMenuViewController *)menu didClickShowButonWithShow:(BOOL)show;
- (void)menu:(SCLeftMenuViewController *)menu didSelectRow:(SimiRow *)row withIndexPath:(NSIndexPath*)indexPath;
- (void)openCategoryProductsListWithCategoryId: (NSString *)categoryId;
- (void)didSelectLoginRow;
@end

#pragma mark LeftMenuView Controller
@interface SCLeftMenuViewController : SimiViewController<UITableViewDataSource, UITableViewDelegate>
{
    CGFloat tableWidth;
}
@property (strong, nonatomic) SimiStoreModelCollection *stores;
@property (strong, nonatomic) SimiCMSPagesModelCollection *cmsPages;
@property (nonatomic, strong) UITableView *tableViewMenu;
@property (nonatomic, strong) UITableView *tableViewLogin;
@property (nonatomic, strong) SimiTable *cells;
@property (nonatomic, weak) id<SCLeftMenuPhoneViewController_Delegate> delegate;

- (void)didClickShow;
- (void)didClickHide;
@end

#pragma mark LeftMenuCell
@interface SCLeftMenuCell : UITableViewCell
@property (nonatomic, strong) UIImageView *rowIcon;
@property (nonatomic, strong) UILabel *rowName;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier rowHeight:(CGFloat)rowHeight;
@end
