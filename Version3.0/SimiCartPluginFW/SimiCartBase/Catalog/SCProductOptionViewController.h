//
//  SCProductOptionViewController.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/11/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SimiCartBundle.h"
#import "SimiTableView.h"
#import "SimiTable.h"
#import "SCOptionGroupViewCell.h"
#import "SCProductOptionSection.h"
#import "SCProductOptionRow.h"

static NSString *Option_Configurable = @"Option_Configurable";
static NSString *Option_Group = @"Option_Group";
static NSString *Option_Bundle = @"Option_Bundle";
static NSString *Option_Custom = @"Option_Custom";
static NSString *is_selected = @"is_selected";
static NSString *is_required = @"isRequired";
@class VariantAttribute;

@protocol  SCProductOptionViewController_Delegate <NSObject>
@optional
- (void)doneButtonTouch;
- (void)cancelButtonTouch;
- (void)updatePriceWhenSelectOption;
@end

@interface SCProductOptionViewController : SimiViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) SimiTableView *tableViewOption;
@property (strong, nonatomic) SimiTable *cells;
@property (strong, nonatomic) SimiProductModel *product;
@property (strong, nonatomic) NSMutableArray *allKeys;
@property (strong, nonatomic) NSMutableDictionary *selectedOptionPrice;
@property (weak, nonatomic) id<SCProductOptionViewController_Delegate> delegate;
// Textfield and datetime options
@property (nonatomic) CGFloat widthTable;

// Done and Cancel button
@property (nonatomic, strong) UIButton *buttonCancel;
@property (nonatomic, strong) UIButton *buttonDone;
//Gin edit
@property (strong, nonatomic) NSMutableDictionary *expendSections;
//End

@property (nonatomic, strong) NSMutableArray *variantsAllKey;
@property (nonatomic, strong) NSMutableArray *variants;
@property (nonatomic, strong) NSMutableArray *variantOptions;
@property (nonatomic, strong) NSString *variantSelectedKey;
@property (nonatomic, strong) NSMutableDictionary *variantAttributes;

@property (nonatomic, strong) NSMutableArray *customs;
@property (nonatomic, strong) NSMutableDictionary *customOptions;

@property (nonatomic, strong) NSMutableArray *bundleItems;
@property (nonatomic, strong) NSMutableDictionary *bundleOptions;

@property (nonatomic, strong) NSMutableArray *groupOptions;

@end

@interface ProductOptionSelectCell : UITableViewCell
@property (nonatomic, strong) UILabel *lblNameOption;
@property (nonatomic, strong) UILabel *lblPriceInclTax;
@property (nonatomic, strong) UILabel *lblPriceExclTax;
@property (nonatomic, strong) UIImageView *imageSelect;
@property (nonatomic) BOOL isMultiSelect;
@property (nonatomic) BOOL isSelected;
@property (nonatomic, strong) ProductOptionModel * dataCell;
@property (nonatomic) ProductType productType;
@property (nonatomic, strong) SimiProductModel *product;
- (void)setDataForCell:(ProductOptionModel*)data;
@end

@interface ProductOptionTextCell : UITableViewCell
@property (nonatomic, strong) UITextField *textOption;
@end

@interface ProductOptionDateTimeCell : UITableViewCell
@property (nonatomic, strong) UIDatePicker *datePicker;
@end

@interface VariantAttribute : NSObject
@property (nonatomic, strong) NSMutableArray *arrayOption;
@property (nonatomic) BOOL isSelected;
@end