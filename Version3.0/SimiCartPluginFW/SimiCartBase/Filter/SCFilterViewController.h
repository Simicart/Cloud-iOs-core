//
//  SCFilterViewController.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 3/13/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SimiCartBundle.h"
#import "SimiTable.h"
#import "SimiRow.h"
#import "SimiSection.h"
#import "ActionSheetStringPicker.h"
static NSString* FILTER_SECTION_ACTIVED = @"FILTER_SECTION_ACTIVED";
static NSString* FILTER_SECTION_SELECTED = @"FILTER_SECTION_SELECTED";
@protocol SCFilterViewControllerDelegate <NSObject>
- (void)filterWithParam:(NSMutableDictionary*)param;
@end

@protocol SCFilterTableViewCellDelegate <NSObject>
- (void)didSelectAttributeDeletete:(NSString*)attributeName;
@end


@interface SCFilterViewController : SimiViewController<UITableViewDelegate, UITableViewDataSource, SCFilterTableViewCellDelegate>
@property (nonatomic, strong) id<SCFilterViewControllerDelegate> delegate;
@property (nonatomic, strong) UITableView *filterTableView; // TableView Show list select filter and actived filter
@property (nonatomic, strong) NSDictionary *filterContent; //Layered Navigation Data recieve when didGetProducts
@property (nonatomic, strong) NSMutableArray *arrSelectFilter; //Layered Navigation Select Data
@property (nonatomic, strong) NSMutableArray *arrActivedFilter; //Layerednavigation Actived Data
@property (nonatomic, strong) SimiTable *cells;
@property (nonatomic, strong) NSDictionary *attributeSelected;
@property (nonatomic, strong) NSMutableArray *arrFilterLabel;
@property (nonatomic, strong) NSMutableArray *arrFilterValue;
@property (nonatomic) int valueSelectedIndex;
@property (nonatomic) int attributeSelectedIndex;
@property (nonatomic, strong) NSMutableDictionary *paramFilter; //Param of filter send when getProDucts
@end

@interface SCFilterTableViewCell : UITableViewCell
@property (strong, nonatomic) UILabel *lblAttributeName;
@property (strong, nonatomic) UILabel *lblAttributeValue;
@property (strong, nonatomic) UIButton *btnDeleteAttribute;
@property (strong, nonatomic) id<SCFilterTableViewCellDelegate> delegate;
- (instancetype)initWithAttributeTitle:(NSString*)title attributeValue:(NSString*)value attributeName:(NSString*)attribute;
- (void)touchButtonDelete:(id)sender;
@end
