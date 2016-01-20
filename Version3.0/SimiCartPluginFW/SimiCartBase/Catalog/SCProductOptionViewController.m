//
//  SCProductOptionViewController.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/11/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SCProductOptionViewController.h"
#import "SimiFormatter.h"
@interface SCProductOptionViewController ()

@end

static NSString *IsSelected = @"is_selected";
static NSString *IsAvaiable = @"is_available";
static NSString *isHighLight = @"is_highlight";

@implementation SCProductOptionViewController

{
    BOOL isShowKeyBoard;
    BOOL isHideKeyBoard;
    float heightHeader;
    float paddingEdge;
    float widthTitle;
    float widthValue;
}
@synthesize tableViewOption, cells, allKeys ,expendSections;
#pragma mark Init
- (void)viewDidLoadAfter
{
    heightHeader = 50;
    paddingEdge = 10;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.widthTable = SCREEN_WIDTH - 20;
    }else
        self.widthTable = SCREEN_WIDTH * 2/3;
    widthTitle = self.widthTable - 100;
    widthValue = 100;
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    if (SIMI_SYSTEM_IOS < 9) {
        CGRect frame = self.view.frame;
        frame.origin.y += 50;
        frame.size.height -= 50;
        if (tableViewOption == nil) {
            tableViewOption = [[SimiTableView alloc]initWithFrame:frame style:UITableViewStyleGrouped];
            tableViewOption.dataSource = self;
            tableViewOption.delegate = self;
            tableViewOption.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            tableViewOption.separatorColor = [[SimiGlobalVar sharedInstance]colorWithHexString:@"#e8e8e8"];
            [tableViewOption setBackgroundColor:[UIColor whiteColor]];
            [self.view addSubview:tableViewOption];
        }
        [tableViewOption setFrame:frame];
        
        if (self.buttonDone == nil) {
            self.buttonDone = [[UIButton alloc]initWithFrame:CGRectMake(self.widthTable - 90, 0, 80, 40)];
            [self.buttonDone addTarget:self action:@selector(didTouchDone:) forControlEvents:UIControlEventTouchUpInside];
            [self.buttonDone setTitle:SCLocalizedString(@"Done") forState:UIControlStateNormal];
            [self.buttonDone setTitleColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#faa525"] forState:UIControlStateNormal];
            [self.buttonDone.titleLabel setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:18]];
            self.buttonDone.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            [self.view addSubview:self.buttonDone];
        }
        
        if (self.buttonCancel == nil) {
            self.buttonCancel = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, 80, 40)];
            [self.buttonCancel addTarget:self action:@selector(didTouchCancel:) forControlEvents:UIControlEventTouchUpInside];
            [self.buttonCancel setTitle:SCLocalizedString(@"Cancel") forState:UIControlStateNormal];
            [self.buttonCancel setTitleColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#faa525"] forState:UIControlStateNormal];
            [self.buttonCancel.titleLabel setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:18]];
            self.buttonCancel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [self.view addSubview:self.buttonCancel];
            [self.view setBackgroundColor:[UIColor whiteColor]];
        }
        [self setCells:nil];
    }
}
- (void)viewDidAppearBefore:(BOOL)animated
{
    if (SIMI_SYSTEM_IOS >= 9) {
        CGRect frame = self.view.frame;
        frame.origin.y += 50;
        frame.size.height -= 50;
        if (tableViewOption == nil) {
            tableViewOption = [[SimiTableView alloc]initWithFrame:frame style:UITableViewStyleGrouped];
            tableViewOption.dataSource = self;
            tableViewOption.delegate = self;
            tableViewOption.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            tableViewOption.separatorColor = [[SimiGlobalVar sharedInstance]colorWithHexString:@"#e8e8e8"];
            [tableViewOption setBackgroundColor:[UIColor whiteColor]];
            [self.view addSubview:tableViewOption];
        }
        [tableViewOption setFrame:frame];
        
        if (self.buttonDone == nil) {
            self.buttonDone = [[UIButton alloc]initWithFrame:CGRectMake(self.widthTable - 90, 0, 80, 40)];
            [self.buttonDone addTarget:self action:@selector(didTouchDone:) forControlEvents:UIControlEventTouchUpInside];
            [self.buttonDone setTitle:SCLocalizedString(@"Done") forState:UIControlStateNormal];
            [self.buttonDone setTitleColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#faa525"] forState:UIControlStateNormal];
            [self.buttonDone.titleLabel setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:18]];
            self.buttonDone.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            [self.view addSubview:self.buttonDone];
        }
        
        if (self.buttonCancel == nil) {
            self.buttonCancel = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, 80, 40)];
            [self.buttonCancel addTarget:self action:@selector(didTouchCancel:) forControlEvents:UIControlEventTouchUpInside];
            [self.buttonCancel setTitle:SCLocalizedString(@"Cancel") forState:UIControlStateNormal];
            [self.buttonCancel setTitleColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#faa525"] forState:UIControlStateNormal];
            [self.buttonCancel.titleLabel setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:18]];
            self.buttonCancel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [self.view addSubview:self.buttonCancel];
            [self.view setBackgroundColor:[UIColor whiteColor]];
        }
        [self setCells:nil];
    }
}

- (void)setCells:(SimiTable *)cells_
{
    if (cells_ != nil) {
        cells = cells_;
    }else
    {
        cells = [SimiTable new];
        self.variantAttributes = [NSMutableDictionary new];
        self.allKeys = [NSMutableArray new];
        switch (_product.productType) {
#pragma mark Configurable
            case ProductTypeConfigurable:
            {
                for (int i = 0; i < self.variantsAllKey.count; i++) {
                    SCProductOptionSection *section = [[SCProductOptionSection alloc]initWithHeaderTitle:@"" footerTitle:@""];
                    section.identifier =  [self.variantsAllKey objectAtIndex:i];;
                    section.simiObjectName = Option_Configurable;
                    VariantAttribute *variantAttribute = [VariantAttribute new];
                    for (int j = 0; j < self.variantOptions.count; j++) {
                        ProductOptionModel *optionModel = [self.variantOptions objectAtIndex:j];
                        if ([optionModel.variantAttributeKey isEqualToString:section.identifier]) {
                            NSString *identifier = [NSString stringWithFormat:@"%@%@",section.identifier,optionModel.title];
                            SCProductOptionRow *row = [[SCProductOptionRow alloc]initWithIdentifier:identifier height:50];
                            row.contentRow = optionModel;
                            [variantAttribute.arrayOption addObject:optionModel];
                            if (optionModel.isSelected) {
                                variantAttribute.isSelected = YES;
                            }
                            [section addObject:row];
                            section.headerTitle = optionModel.variantAttributeTitle;
                        }
                    }
                    [self.variantAttributes setObject:variantAttribute forKey:section.identifier];
                    [self.allKeys addObject:section.identifier];
                    [cells addObject:section];
                }
                
                for (NSMutableDictionary *custom in self.customs) {
                    SCProductOptionSection *section = [[SCProductOptionSection alloc]initWithHeaderTitle:[custom valueForKey:@"title"] footerTitle:@""];
                    section.identifier = [custom valueForKey:@"_id"];
                    section.simiObjectName = Option_Custom;
                    NSMutableArray *options = [self.customOptions valueForKey:section.identifier];
                    for (ProductOptionModel *optionModel in options) {
                        NSString *identifier = [NSString stringWithFormat:@"%@%@",section.identifier,[optionModel valueForKey:@"_id"]];
                        float rowHeight = 50;
                        if ([[custom valueForKey:@"type"] isEqualToString:@"area"] || [[custom valueForKey:@"type"] isEqualToString:@"field"]) {
                            rowHeight = 50;
                        }else if([[custom valueForKey:@"type"] isEqualToString:@"date_time"] || [[custom valueForKey:@"type"] isEqualToString:@"date"] || [[custom valueForKey:@"type"] isEqualToString:@"time"])
                        {
                            rowHeight = 170;
                        }else if([[custom valueForKey:@"type"] isEqualToString:@"checkbox"]||[[custom valueForKey:@"type"] isEqualToString:@"drop_down"])
                        {
                            rowHeight = 50;
                        }
                            
                        SCProductOptionRow *row = [[SCProductOptionRow alloc]initWithIdentifier:identifier height:rowHeight];
                        row.contentRow = optionModel;
                        [section addObject:row];
                    }
                    section.sectionContent = custom;
                    [self.allKeys addObject:section.identifier];
                    [cells addObject:section];
                }
            }
                break;
#pragma mark Simple
            case ProductTypeSimple:
            {
                for (NSMutableDictionary *custom in self.customs) {
                    SCProductOptionSection *section = [[SCProductOptionSection alloc]initWithHeaderTitle:[custom valueForKey:@"title"] footerTitle:@""];
                    section.identifier = [custom valueForKey:@"_id"];
                    section.simiObjectName = Option_Custom;
                    NSMutableArray *options = [self.customOptions valueForKey:section.identifier];
                    for (ProductOptionModel *optionModel in options) {
                        NSString *identifier = [NSString stringWithFormat:@"%@%@",section.identifier,[optionModel valueForKey:@"_id"]];
                        float rowHeight = 50;
                        if ([[custom valueForKey:@"type"] isEqualToString:@"area"] || [[custom valueForKey:@"type"] isEqualToString:@"field"]) {
                            rowHeight = 50;
                        }else if([[custom valueForKey:@"type"] isEqualToString:@"date_time"] || [[custom valueForKey:@"type"] isEqualToString:@"date"] || [[custom valueForKey:@"type"] isEqualToString:@"time"])
                        {
                            rowHeight = 170;
                        }else if([[custom valueForKey:@"type"] isEqualToString:@"checkbox"]||[[custom valueForKey:@"type"] isEqualToString:@"drop_down"])
                        {
                            rowHeight = 50;
                        }
                        
                        SCProductOptionRow *row = [[SCProductOptionRow alloc]initWithIdentifier:identifier height:rowHeight];
                        row.contentRow = optionModel;
                        [section addObject:row];
                    }
                    section.sectionContent = custom;
                    [self.allKeys addObject:section.identifier];
                    [cells addObject:section];
                }
            }
                break;
#pragma mark Bundle
            case ProductTypeBundle:
            {
                for (NSMutableDictionary *bundleItem in self.bundleItems) {
                    SCProductOptionSection *section = [[SCProductOptionSection alloc]initWithHeaderTitle:[bundleItem valueForKey:@"title"] footerTitle:@""];
                    section.identifier = [bundleItem valueForKey:@"_id"];
                    section.simiObjectName = Option_Bundle;
                    NSMutableArray *options = [self.bundleOptions valueForKey:section.identifier];
                    for (ProductOptionModel *optionModel in options) {
                        NSString *identifier = [NSString stringWithFormat:@"%@%@",section.identifier,[optionModel valueForKey:@"_id"]];
                        float rowHeight = 50;
                        SCProductOptionRow *row = [[SCProductOptionRow alloc]initWithIdentifier:identifier height:rowHeight];
                        row.contentRow = optionModel;
                        [section addObject:row];
                    }
                    section.sectionContent = bundleItem;
                    [self.allKeys addObject:section.identifier];
                    [cells addObject:section];
                }
            }
                break;
#pragma mark Group
            case ProductTypeGrouped:
                {
                    for (ProductOptionModel *groupItem in self.groupOptions) {
                        SCProductOptionSection *section = [[SCProductOptionSection alloc]initWithHeaderTitle:[groupItem valueForKey:@"title"] footerTitle:@""];
                        section.identifier = [groupItem valueForKey:@"_id"];
                        section.simiObjectName = Option_Group;
                        NSString *identifier = section.identifier;
                        float rowHeight = 50;
                        SCProductOptionRow *row = [[SCProductOptionRow alloc]initWithIdentifier:identifier height:rowHeight];
                        row.contentRow = groupItem;
                        [section addObject:row];
                        section.sectionContent = groupItem;
                        [self.allKeys addObject:section.identifier];
                        [cells addObject:section];
                    }
                }
                break;
            default:
                break;
        }
        self.expendSections = [NSMutableDictionary new];
        [self.expendSections setValue:@"YES" forKey:[self.allKeys objectAtIndex:0]];
    }
    [tableViewOption reloadData];
}

#pragma mark TableView DataSource & Table View Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SCProductOptionSection *simiSection = [cells objectAtIndex:indexPath.section];
    SCProductOptionRow *simiRow = (SCProductOptionRow *)[simiSection objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simiRow.identifier];
#pragma mark Configurable
    if (_product.productType == ProductTypeConfigurable) {
        if ([simiSection.simiObjectName isEqualToString:Option_Configurable]) {
            if (cell == nil) {
                ProductOptionSelectCell *aCell = [[ProductOptionSelectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
                aCell.isMultiSelect = NO;
                aCell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell = aCell;
            }
            [(ProductOptionSelectCell*)cell setDataForCell:(ProductOptionModel*)simiRow.contentRow];
            return cell;
        }
        if ([simiSection.simiObjectName isEqualToString:Option_Custom]) {
            if ([[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"checkbox"]||[[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"multiple"]) {
                if (cell == nil) {
                    ProductOptionSelectCell *aCell = [[ProductOptionSelectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
                    aCell.isMultiSelect = YES;
                    aCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell = aCell;
                }
                [(ProductOptionSelectCell*)cell setDataForCell:(ProductOptionModel*)simiRow.contentRow];
                return cell;
            }else if([[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"date_time"] || [[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"date"] || [[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"time"])
            {
                if (cell == nil) {
                    ProductOptionDateTimeCell *aCell = [[ProductOptionDateTimeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
                    aCell.datePicker = [[UIDatePicker alloc] init];
                    aCell.datePicker.frame = CGRectMake(paddingEdge, 0.0f, [SimiGlobalVar scaleValue:240.0f], [SimiGlobalVar scaleValue:120.0f]);
                    [aCell.datePicker addTarget:self action:@selector(changeDatePicker:) forControlEvents:UIControlEventValueChanged];
                    aCell.datePicker.simiObjectIdentifier = simiSection.identifier;
                    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
                    if ([[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"date"]) {
                        aCell.datePicker.datePickerMode = UIDatePickerModeDate;
                        [dateFormater setDateFormat:@"yyyy-MM-dd"];
                    } else if ([[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"date_time"]) {
                        ((ProductOptionDateTimeCell*)cell).datePicker.datePickerMode = UIDatePickerModeDateAndTime;
                        [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    } else {
                        aCell.datePicker.datePickerMode = UIDatePickerModeTime;
                        [dateFormater setDateFormat:@"HH:mm:ss"];
                    }
                    if ([simiRow.contentRow objectForKey:@"option_value"]) {
                        aCell.datePicker.date = [dateFormater dateFromString:[simiRow.contentRow objectForKey:@"option_value"]];
                    } else {
                        aCell.datePicker.date = [NSDate date];
                    }
                    [aCell addSubview:aCell.datePicker];
                    cell = aCell;
                }
                return cell;
            }else if ([[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"drop_down"] || [[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"radio"])
            {
                if (cell == nil) {
                    ProductOptionSelectCell *aCell = [[ProductOptionSelectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
                    aCell.isMultiSelect = NO;
                    aCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell = aCell;
                }
                [(ProductOptionSelectCell*)cell setDataForCell:(ProductOptionModel*)simiRow.contentRow];
                return cell;
            }else if ([[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"area"] || [[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"field"])
            {
                if (cell == nil) {
                    ProductOptionTextCell *aCell = [[ProductOptionTextCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simiRow.identifier];
                    aCell.textOption = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, self.widthTable - 10, simiRow.height)];
                    aCell.textOption.simiObjectIdentifier = simiSection.identifier;
                    aCell.textOption.delegate = self;
                    aCell.textOption.clearButtonMode = UITextFieldViewModeWhileEditing;
                    [aCell.textOption addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboardInputText) name:UIKeyboardDidShowNotification object:nil];
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboardInputText) name:UIKeyboardWillHideNotification object:nil];
                    [aCell addSubview:aCell.textOption];
                    cell = aCell;
                }
                ((ProductOptionTextCell*)cell).textOption.placeholder = [simiRow.contentRow objectForKey:@"title"];
                ((ProductOptionTextCell*)cell).textOption.text = [simiRow.contentRow objectForKey:@"option_value"];
                return cell;
            }
        }
#pragma mark Simple
    }else if (self.product.productType == ProductTypeSimple)
    {
        if ([simiSection.simiObjectName isEqualToString:Option_Custom]) {
            if ([[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"checkbox"]||[[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"multiple"]) {
                if (cell == nil) {
                    ProductOptionSelectCell *aCell = [[ProductOptionSelectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
                    aCell.isMultiSelect = YES;
                    aCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell = aCell;
                }
                [(ProductOptionSelectCell*)cell setDataForCell:(ProductOptionModel*)simiRow.contentRow];
                return cell;
            }else if([[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"date_time"] || [[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"date"] || [[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"time"])
            {
                if (cell == nil) {
                    ProductOptionDateTimeCell *aCell = [[ProductOptionDateTimeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
                    aCell.datePicker = [[UIDatePicker alloc] init];
                    aCell.datePicker.frame = CGRectMake(paddingEdge, 0.0f, [SimiGlobalVar scaleValue:240.0f], [SimiGlobalVar scaleValue:120.0f]);
                    [aCell.datePicker addTarget:self action:@selector(changeDatePicker:) forControlEvents:UIControlEventValueChanged];
                    aCell.datePicker.simiObjectIdentifier = simiSection.identifier;
                    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
                    if ([[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"date"]) {
                        aCell.datePicker.datePickerMode = UIDatePickerModeDate;
                        [dateFormater setDateFormat:@"yyyy-MM-dd"];
                    } else if ([[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"date_time"]) {
                        ((ProductOptionDateTimeCell*)cell).datePicker.datePickerMode = UIDatePickerModeDateAndTime;
                        [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    } else {
                        aCell.datePicker.datePickerMode = UIDatePickerModeTime;
                        [dateFormater setDateFormat:@"HH:mm:ss"];
                    }
                    if ([simiRow.contentRow objectForKey:@"option_value"]) {
                        aCell.datePicker.date = [dateFormater dateFromString:[simiRow.contentRow objectForKey:@"option_value"]];
                    } else {
                        aCell.datePicker.date = [NSDate date];
                    }
                    [aCell addSubview:aCell.datePicker];
                    cell = aCell;
                }
                return cell;
            }else if ([[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"drop_down"] || [[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"radio"])
            {
                if (cell == nil) {
                    ProductOptionSelectCell *aCell = [[ProductOptionSelectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
                    aCell.isMultiSelect = NO;
                    aCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell = aCell;
                }
                [(ProductOptionSelectCell*)cell setDataForCell:(ProductOptionModel*)simiRow.contentRow];
                return cell;
            }else if ([[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"area"] || [[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"field"])
            {
                if (cell == nil) {
                    ProductOptionTextCell *aCell = [[ProductOptionTextCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simiRow.identifier];
                    aCell.textOption = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, self.widthTable - 10, simiRow.height)];
                    aCell.textOption.simiObjectIdentifier = simiSection.identifier;
                    aCell.textOption.delegate = self;
                    aCell.textOption.clearButtonMode = UITextFieldViewModeWhileEditing;
                    [aCell.textOption addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboardInputText) name:UIKeyboardDidShowNotification object:nil];
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboardInputText) name:UIKeyboardWillHideNotification object:nil];
                    [aCell addSubview:aCell.textOption];
                    cell = aCell;
                }
                if ([[simiRow.contentRow objectForKey:@"title"] isEqualToString:@""]) {
                    ((ProductOptionTextCell*)cell).textOption.placeholder = SCLocalizedString(@"Enter text in here");
                }else
                    ((ProductOptionTextCell*)cell).textOption.placeholder = [simiRow.contentRow objectForKey:@"title"];
                ((ProductOptionTextCell*)cell).textOption.text = [simiRow.contentRow objectForKey:@"option_value"];
                return cell;
            }
        }
#pragma mark Bundle
    }else if (_product.productType == ProductTypeBundle)
    {
        if ([[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"radio"] || [[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"drop_down"])
        {
            if (cell == nil) {
                ProductOptionSelectCell *aCell = [[ProductOptionSelectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
                aCell.isMultiSelect = NO;
                aCell.selectionStyle = UITableViewCellSelectionStyleNone;
                aCell.product = self.product;
                cell = aCell;
            }
            [(ProductOptionSelectCell*)cell setDataForCell:(ProductOptionModel*)simiRow.contentRow];
            return cell;
        }else if ([[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"checkbox"]||[[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"multiple"]) {
            if (cell == nil) {
                ProductOptionSelectCell *aCell = [[ProductOptionSelectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
                aCell.isMultiSelect = YES;
                aCell.selectionStyle = UITableViewCellSelectionStyleNone;
                aCell.product = self.product;
                cell = aCell;
            }
            [(ProductOptionSelectCell*)cell setDataForCell:(ProductOptionModel*)simiRow.contentRow];
            return cell;
        }
    }else if (_product.productType == ProductTypeGrouped)
    {
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simiRow.identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            SCOptionGroupViewCell * optionViewCell = [[SCOptionGroupViewCell alloc]initWithFrame:CGRectMake(paddingEdge, 0, self.widthTable - 140, simiRow.height)];
            
            UIButton *_plusButton = [[UIButton alloc] initWithFrame:CGRectMake(self.widthTable - 70, (simiRow.height - 38)/2, 38, 38)];
            
            [_plusButton setImage:[UIImage imageNamed:@"plus.png"] forState:UIControlStateNormal];
            _plusButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
            [_plusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_plusButton.layer setCornerRadius:14.0f];
            [_plusButton.layer setMasksToBounds:YES];
            [_plusButton setAdjustsImageWhenHighlighted:YES];
            [_plusButton setAdjustsImageWhenDisabled:YES];
            [_plusButton addTarget:self action:@selector(didSelectPlusButtonOption:) forControlEvents:UIControlEventTouchUpInside];
            _plusButton.simiObjectIdentifier = simiSection.identifier;
            
            
            UIButton *_minusButton = [[UIButton alloc] initWithFrame:CGRectMake(self.widthTable - 130, (simiRow.height - 38)/2, 38, 38)];
            [_minusButton setImage:[UIImage imageNamed:@"minus.png"] forState:UIControlStateNormal];
            _minusButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
            [_minusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _minusButton.titleLabel.adjustsFontSizeToFitWidth = YES;
            [_minusButton.layer setCornerRadius:14.0f];
            [_minusButton.layer setMasksToBounds:YES];
            [_minusButton setAdjustsImageWhenHighlighted:YES];
            [_minusButton setAdjustsImageWhenDisabled:YES];
            [_minusButton addTarget:self action:@selector(didSelectMinusButtonOptionQty:) forControlEvents:UIControlEventTouchUpInside];
            _minusButton.simiObjectIdentifier = simiSection.identifier;
            if([[SimiGlobalVar sharedInstance] isReverseLanguage]){
                [_plusButton setFrame:CGRectMake(40, (simiRow.height - 38)/2, 38, 38)];
                [_minusButton setFrame:CGRectMake(100, (simiRow.height - 38)/2, 38, 38)];
                [optionViewCell setFrame:CGRectMake(140 - paddingEdge, 0, self.widthTable - 140, simiRow.height)];
            }
            for (UIView *subview in optionViewCell.subviews) {
                [subview removeFromSuperview];
            }
            [optionViewCell setPriceOption:simiRow.contentRow];
            [cell addSubview:_plusButton];
            [cell addSubview:_minusButton];
            [cell addSubview:optionViewCell];
        }
        return cell;
    }
#pragma mark Grouped
    if (cell == nil) {
        cell = [UITableViewCell new];
    }
    return cell;
    
    if (self.product.productType == ProductTypeGrouped) {
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simiRow.identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            SCOptionGroupViewCell * optionViewCell = [[SCOptionGroupViewCell alloc]initWithFrame:CGRectMake(paddingEdge, 0, self.widthTable - 140, simiRow.height)];
            
            UIButton *_plusButton = [[UIButton alloc] initWithFrame:CGRectMake(self.widthTable - 70, (simiRow.height - 38)/2, 38, 38)];
            
            [_plusButton setImage:[UIImage imageNamed:@"plus.png"] forState:UIControlStateNormal];
            _plusButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
            [_plusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_plusButton.layer setCornerRadius:14.0f];
            [_plusButton.layer setMasksToBounds:YES];
            [_plusButton setAdjustsImageWhenHighlighted:YES];
            [_plusButton setAdjustsImageWhenDisabled:YES];
            [_plusButton addTarget:self action:@selector(didSelectPlusButtonOption:) forControlEvents:UIControlEventTouchUpInside];
            _plusButton.simiObjectIdentifier = simiSection.identifier;
            
            
            UIButton *_minusButton = [[UIButton alloc] initWithFrame:CGRectMake(self.widthTable - 130, (simiRow.height - 38)/2, 38, 38)];
            [_minusButton setImage:[UIImage imageNamed:@"minus.png"] forState:UIControlStateNormal];
            _minusButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
            [_minusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _minusButton.titleLabel.adjustsFontSizeToFitWidth = YES;
            [_minusButton.layer setCornerRadius:14.0f];
            [_minusButton.layer setMasksToBounds:YES];
            [_minusButton setAdjustsImageWhenHighlighted:YES];
            [_minusButton setAdjustsImageWhenDisabled:YES];
            [_minusButton addTarget:self action:@selector(didSelectMinusButtonOptionQty:) forControlEvents:UIControlEventTouchUpInside];
            _minusButton.simiObjectIdentifier = simiSection.identifier;
            //Gin edit
            if([[SimiGlobalVar sharedInstance] isReverseLanguage]){
                [_plusButton setFrame:CGRectMake(40, (simiRow.height - 38)/2, 38, 38)];
                [_minusButton setFrame:CGRectMake(100, (simiRow.height - 38)/2, 38, 38)];
                [optionViewCell setFrame:CGRectMake(140 - paddingEdge, 0, self.widthTable - 140, simiRow.height)];
            }
            //end
            for (UIView *subview in optionViewCell.subviews) {
                [subview removeFromSuperview];
            }
            [optionViewCell setPriceOption:simiRow.contentRow];
            [cell addSubview:_plusButton];
            [cell addSubview:_minusButton];
            [cell addSubview:optionViewCell];
        }
        return cell;
    }
    
    if ([[simiRow.contentRow valueForKey:@"option_type"] isEqualToString:@"single"]) {
        if (cell == nil) {
            cell = [[ProductOptionSelectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
            ((ProductOptionSelectCell*)cell).isMultiSelect = NO;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [(ProductOptionSelectCell*)cell setDataForCell:simiRow.contentRow];
        return cell;
    }
    if ([[simiRow.contentRow valueForKey:@"option_type"] isEqualToString:@"multi"]) {
        if (cell == nil) {
            cell = [[ProductOptionSelectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
            ((ProductOptionSelectCell*)cell).isMultiSelect = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [(ProductOptionSelectCell*)cell setDataForCell:simiRow.contentRow];
        return cell;
    }
    if ([[simiRow.contentRow valueForKey:@"option_type"] isEqualToString:@"text"]) {
        if (cell == nil) {
            cell = [[ProductOptionTextCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simiRow.identifier];
            ((ProductOptionTextCell*)cell).textOption = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, self.widthTable - 10, simiRow.height)];
            ((ProductOptionTextCell*)cell).textOption.simiObjectIdentifier = simiSection.identifier;
            ((ProductOptionTextCell*)cell).textOption.delegate = self;
            ((ProductOptionTextCell*)cell).textOption.clearButtonMode = UITextFieldViewModeWhileEditing;
            [((ProductOptionTextCell*)cell).textOption addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboardInputText) name:UIKeyboardDidShowNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboardInputText) name:UIKeyboardWillHideNotification object:nil];
            [cell addSubview:((ProductOptionTextCell*)cell).textOption];
        }
        ((ProductOptionTextCell*)cell).textOption.placeholder = simiSection.identifier;
        //Gin edit
        if([[SimiGlobalVar sharedInstance] isReverseLanguage]){
            [((ProductOptionTextCell*)cell).textOption setTextAlignment:NSTextAlignmentRight];
            [((ProductOptionTextCell*)cell).textOption setFrame:CGRectMake(0, 0, self.widthTable - 10, simiRow.height)];
        }
        //end
        ((ProductOptionTextCell*)cell).textOption.text = [simiRow.contentRow objectForKey:@"option_value"];
        return cell;
    }
    if ([[simiRow.contentRow valueForKey:@"option_type"] isEqualToString:@"date"]||[[simiRow.contentRow valueForKey:@"option_type"] isEqualToString:@"date_time"]||[[simiRow.contentRow valueForKey:@"option_type"] isEqualToString:@"time"]) {
        if (cell == nil) {
            cell = [[ProductOptionDateTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
            ((ProductOptionDateTimeCell*)cell).datePicker = [[UIDatePicker alloc] init];
            ((ProductOptionDateTimeCell*)cell).datePicker.frame = CGRectMake(paddingEdge, 0.0f, [SimiGlobalVar scaleValue:240.0f], [SimiGlobalVar scaleValue:120.0f]);
            [((ProductOptionDateTimeCell*)cell).datePicker addTarget:self action:@selector(changeDatePicker:) forControlEvents:UIControlEventValueChanged];
            ((ProductOptionDateTimeCell*)cell).datePicker.simiObjectIdentifier = simiSection.identifier;
            [cell addSubview:((ProductOptionDateTimeCell*)cell).datePicker];
            NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
            if ([[simiRow.contentRow objectForKey:@"option_type"] isEqualToString:@"date"]) {
                ((ProductOptionDateTimeCell*)cell).datePicker.datePickerMode = UIDatePickerModeDate;
                [dateFormater setDateFormat:@"yyyy-MM-dd"];
            } else if ([[simiRow.contentRow objectForKey:@"option_type"] isEqualToString:@"date_time"]) {
                ((ProductOptionDateTimeCell*)cell).datePicker.datePickerMode = UIDatePickerModeDateAndTime;
                [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            } else {
                ((ProductOptionDateTimeCell*)cell).datePicker.datePickerMode = UIDatePickerModeTime;
                [dateFormater setDateFormat:@"HH:mm:ss"];
            }
            if ([simiRow.contentRow objectForKey:@"option_value"]) {
                ((ProductOptionDateTimeCell*)cell).datePicker.date = [dateFormater dateFromString:[simiRow.contentRow objectForKey:@"option_value"]];
            } else {
                ((ProductOptionDateTimeCell*)cell).datePicker.date = [NSDate date];
            }
        }
        return cell;
    }
    
    if (cell == nil) {
        cell = [UITableViewCell new];
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return cells.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([(NSString *)[expendSections objectForKey:[allKeys objectAtIndex:section]] boolValue]){
        SCProductOptionSection *simiSection = [cells objectAtIndex:section];
        return  simiSection.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return heightHeader;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *viewHeader = [UIView new];
    [viewHeader setBackgroundColor:[[SimiGlobalVar sharedInstance]colorWithHexString:@"#ededed"]];
    //Gin edit
    viewHeader.tag = section;
    //end
    SCProductOptionSection *simiSection = [cells objectAtIndex:section];
    SCProductOptionRow *simiRow = (SCProductOptionRow*)[simiSection objectAtIndex:0];
    UILabel *lblHeader = [UILabel new];
    [lblHeader setFont:[UIFont fontWithName:THEME_FONT_NAME_REGULAR size:15]];
    [lblHeader setTextColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#131313"]];
    [lblHeader setBackgroundColor:[UIColor clearColor]];
    
    UILabel *lblPrice = [UILabel new];
    [lblPrice setFont:[UIFont fontWithName:THEME_FONT_NAME size:15]];
    [lblPrice setTextColor:THEME_PRICE_COLOR];
    [lblPrice setBackgroundColor:[UIColor clearColor]];
    
    NSString *stringHeaderTitle = @"";
#pragma mark Configurable
    if (self.product.productType == ProductTypeConfigurable) {
        if ([simiSection.simiObjectName isEqualToString:Option_Configurable]) {
            stringHeaderTitle = [NSString stringWithFormat:@"%@ (*)",simiSection.headerTitle];
            lblHeader.numberOfLines = 2;
            lblHeader.text = stringHeaderTitle;
            [lblHeader setFrame:CGRectMake(paddingEdge, 0, widthTitle, heightHeader)];
            [viewHeader addSubview:lblHeader];
        }else if ([simiSection.simiObjectName isEqualToString:Option_Custom])
        {
            stringHeaderTitle = simiSection.headerTitle;
            if ([[simiSection.sectionContent valueForKey:is_required]boolValue]) {
                stringHeaderTitle = [NSString stringWithFormat:@"%@ (*)",stringHeaderTitle];
            }
            lblHeader.numberOfLines = 2;
            lblHeader.text = stringHeaderTitle;
            [lblHeader setFrame:CGRectMake(paddingEdge, 0, widthTitle, heightHeader)];
            [viewHeader addSubview:lblHeader];
            
            [lblPrice setFrame:CGRectMake(self.widthTable - widthValue - 26, 0, widthValue - 10, heightHeader)];
            lblPrice.text = [[SimiFormatter sharedInstance]priceWithPrice:[NSString stringWithFormat:@"%@",[self.selectedOptionPrice valueForKey:simiSection.identifier]]];
            if ([[self.selectedOptionPrice valueForKey:simiSection.identifier] floatValue] == 0) {
                [lblPrice setHidden:YES];
            }
            [lblPrice setTextAlignment:NSTextAlignmentRight];
            [viewHeader addSubview:lblPrice];
        }
#pragma mark Simple & Bundle
    }else if(self.product.productType == ProductTypeSimple || self.product.productType == ProductTypeBundle)
    {
        if ([simiSection.simiObjectName isEqualToString:Option_Custom] || [simiSection.simiObjectName isEqualToString:Option_Bundle])
        {
            stringHeaderTitle = simiSection.headerTitle;
            lblHeader.numberOfLines = 2;
            if ([[simiSection.sectionContent valueForKey:is_required]boolValue]) {
                stringHeaderTitle = [NSString stringWithFormat:@"%@ (*)",stringHeaderTitle];
            }
            lblHeader.text = stringHeaderTitle;
            [lblHeader setFrame:CGRectMake(paddingEdge, 0, widthTitle, heightHeader)];
            [viewHeader addSubview:lblHeader];
            
            [lblPrice setFrame:CGRectMake(self.widthTable - widthValue - 26, 0, widthValue - 10, heightHeader)];
            lblPrice.text = [[SimiFormatter sharedInstance]priceWithPrice:[NSString stringWithFormat:@"%@",[self.selectedOptionPrice valueForKey:simiSection.identifier]]];
            if ([[self.selectedOptionPrice valueForKey:simiSection.identifier] floatValue] == 0) {
                [lblPrice setHidden:YES];
            }
            [lblPrice setTextAlignment:NSTextAlignmentRight];
            [viewHeader addSubview:lblPrice];
        }
#pragma mark Grouped
    }else if (self.product.productType == ProductTypeGrouped)
    {
        if ([simiSection.simiObjectName isEqualToString:Option_Group]) {
            stringHeaderTitle = [NSString stringWithFormat:@"%@ x %@", [simiSection.sectionContent valueForKey:@"option_qty"], [simiSection.sectionContent valueForKey:@"name"]];
            //  Liam Update RTL
            if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
                stringHeaderTitle = [NSString stringWithFormat:@"%@ x %@", simiSection.identifier, [simiRow.contentRow valueForKey:@"option_qty"]];
                [lblHeader setTextAlignment:NSTextAlignmentRight];
            }
            //  End RTL
            lblHeader.text = stringHeaderTitle;
            [lblHeader setFrame:CGRectMake(paddingEdge, 0, self.widthTable - 2 * paddingEdge, heightHeader)];
            lblHeader.numberOfLines = 2;
            [viewHeader addSubview:lblHeader];
        }
    }
    UIImageView *narrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.tableViewOption.frame.size.width - 26, 15, 10, 10)];
    
    if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
        [narrowImage setFrame:CGRectMake(10, 15, 10, 10)];
    }
    
    if ([(NSString *)[self.expendSections objectForKey:[allKeys objectAtIndex:section]] boolValue]) {
        [narrowImage setImage:[UIImage imageNamed:@"ic_narrow_up"]];
    }
    else
    {
        [narrowImage setImage:[UIImage imageNamed:@"ic_narrow_down"]];
    }
    [viewHeader addSubview:narrowImage];
    
    UITapGestureRecognizer  *headerTapped   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionHeaderTapped:)];
    [viewHeader addGestureRecognizer:headerTapped];
    //End
    return viewHeader;
}
//Gin edit
#pragma mark - gesture tapped
- (void)sectionHeaderTapped:(UITapGestureRecognizer *)gestureRecognizer{
    SCProductOptionSection *simiSection = [cells objectAtIndex:gestureRecognizer.view.tag];
    BOOL collapsed  = [[expendSections objectForKey:simiSection.identifier] boolValue];
    if(collapsed){
        [expendSections setObject:@"NO" forKey:[allKeys objectAtIndex:gestureRecognizer.view.tag]];
    }else{
        [expendSections setObject:@"YES" forKey:[allKeys objectAtIndex:gestureRecognizer.view.tag]];
    }
    
    //reload specific section animated
    [self.tableViewOption reloadSections:[NSIndexSet indexSetWithIndex:gestureRecognizer.view.tag] withRowAnimation:UITableViewRowAnimationFade];
    if(!collapsed){
        [self.tableViewOption scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:gestureRecognizer.view.tag] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}
//end
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SCProductOptionSection *simiSection = [cells objectAtIndex:indexPath.section];
    SCProductOptionRow *simiRow = (SCProductOptionRow *)[simiSection objectAtIndex:indexPath.row];
    
    return simiRow.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SCProductOptionSection *simiSection = [cells objectAtIndex:indexPath.section];
    SCProductOptionRow *simiRow = (SCProductOptionRow *)[simiSection objectAtIndex:indexPath.row];
#pragma mark Configurable
    if (self.product.productType == ProductTypeConfigurable) {
        if ([simiSection.simiObjectName isEqualToString:Option_Configurable]) {
            for (int i = 0; i < simiSection.count; i++) {
                if (i != indexPath.row) {
                    SCProductOptionRow *zThemeRowTemp = (SCProductOptionRow *)[simiSection objectAtIndex:i];
                    if ([zThemeRowTemp.contentRow.variantAttributeKey isEqualToString:simiSection.identifier])
                        zThemeRowTemp.contentRow.isSelected = NO;
                }
            }
            if (!simiRow.contentRow.isSelected) {
                simiRow.contentRow.isSelected = YES;
                [self activeDependenceWith:simiRow andKey:simiSection.identifier];
            }
            [self.delegate updatePriceWhenSelectOption];
        }else if ([simiSection.simiObjectName isEqualToString:Option_Custom])
        {
            if ([[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"checkbox"]||[[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"multiple"]) {
                if (!simiRow.contentRow.isSelected) {
                    simiRow.contentRow.isSelected = YES;
                }else
                    simiRow.contentRow.isSelected = NO;
                [self configSelectedOption];
            }else if ([[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"radio"]||[[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"drop_down"])
            {
                for (int i = 0; i < simiSection.count; i++) {
                    if (i != indexPath.row) {
                        SCProductOptionRow *zThemeRowTemp = (SCProductOptionRow *)[simiSection objectAtIndex:i];
                        zThemeRowTemp.contentRow.isSelected = NO;
                    }
                }
                if (!simiRow.contentRow.isSelected) {
                    simiRow.contentRow.isSelected = YES;
                }else
                    simiRow.contentRow.isSelected = NO;
                [self configSelectedOption];
            }
        }
        [self.tableViewOption reloadData];
        return;
    }
#pragma mark Simple
    if (self.product.productType == ProductTypeSimple) {
        if ([simiSection.simiObjectName isEqualToString:Option_Custom])
        {
            if ([[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"checkbox"]||[[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"multiple"]) {
                if (!simiRow.contentRow.isSelected) {
                    simiRow.contentRow.isSelected = YES;
                }else
                    simiRow.contentRow.isSelected = NO;
                [self configSelectedOption];
            }else if ([[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"radio"]||[[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"drop_down"])
            {
                for (int i = 0; i < simiSection.count; i++) {
                    if (i != indexPath.row) {
                        SCProductOptionRow *zThemeRowTemp = (SCProductOptionRow *)[simiSection objectAtIndex:i];
                        zThemeRowTemp.contentRow.isSelected = NO;
                    }
                }
                if (!simiRow.contentRow.isSelected) {
                    simiRow.contentRow.isSelected = YES;
                }else
                    simiRow.contentRow.isSelected = NO;
                [self configSelectedOption];
            }
        }
        [self.tableViewOption reloadData];
        return;
    }
#pragma mark Bundle
    if (self.product.productType == ProductTypeBundle) {
        if ([simiSection.simiObjectName isEqualToString:Option_Bundle])
        {
            if ([[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"checkbox"]||[[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"multiple"]) {
                if (!simiRow.contentRow.isSelected) {
                    simiRow.contentRow.isSelected = YES;
                }else
                    simiRow.contentRow.isSelected = NO;
                [self configSelectedOption];
            }else if ([[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"drop_down"]||[[simiSection.sectionContent valueForKey:@"type"] isEqualToString:@"radio"])
            {
                for (int i = 0; i < simiSection.count; i++) {
                    if (i != indexPath.row) {
                        SCProductOptionRow *zThemeRowTemp = (SCProductOptionRow *)[simiSection objectAtIndex:i];
                        zThemeRowTemp.contentRow.isSelected = NO;
                    }
                }
                if (!simiRow.contentRow.isSelected) {
                    simiRow.contentRow.isSelected = YES;
                }else
                    simiRow.contentRow.isSelected = NO;
                [self configSelectedOption];
            }
        }
        [self.tableViewOption reloadData];
        return;
    }
}

#pragma mark Action Group
- (void)didSelectPlusButtonOption:(id)sender
{
    UIButton *button = (UIButton *)sender;
    SCProductOptionSection *section = nil;
    int currentSectionIndex = -1;
    for (int i = 0; i < cells.count; i++) {
        SCProductOptionSection *sectionTemp = [cells objectAtIndex:i];
        if ([sectionTemp.identifier isEqualToString:(NSString*)(button.simiObjectIdentifier)]) {
            section = sectionTemp;
            currentSectionIndex = i;
            break;
        }
    }
    SCProductOptionRow *row = (SCProductOptionRow*)[section objectAtIndex:0];
    if ([row.contentRow valueForKey:@"option_qty"]) {
        NSInteger count = 1;
        count += [[row.contentRow valueForKey:@"option_qty"] integerValue];
        [row.contentRow setValue:[NSString stringWithFormat:@"%ld", (long)count] forKey:@"option_qty"];
        row.contentRow.isSelected =  YES;
    }else{
        [row.contentRow setValue:@"0" forKey:@"option_qty"];
    }
    if (currentSectionIndex >= 0) {
        [self.tableViewOption reloadSections:[NSIndexSet indexSetWithIndex:currentSectionIndex] withRowAnimation:UITableViewRowAnimationNone];
    }
    [self configSelectedOption];
    [self.delegate updatePriceWhenSelectOption];
}

- (void)didSelectMinusButtonOptionQty:(id)sender
{
    UIButton *button = (UIButton *)sender;
    SCProductOptionSection *section = nil;
    int currentSectionIndex = -1;
    for (int i = 0; i < cells.count; i++) {
        SCProductOptionSection *sectionTemp = [cells objectAtIndex:i];
        if ([sectionTemp.identifier isEqualToString:(NSString*)(button.simiObjectIdentifier)]) {
            section = sectionTemp;
            currentSectionIndex = i;
            break;
        }
    }
    SCProductOptionRow *row = (SCProductOptionRow*)[section objectAtIndex:0];
    if ([[row.contentRow valueForKey:@"option_qty"]intValue] > 0) {
        NSInteger count = [[row.contentRow valueForKey:@"option_qty"] integerValue];
        count -= 1;
        [row.contentRow setValue:[NSString stringWithFormat:@"%ld", (long)count] forKey:@"option_qty"];
        if (count == 0) {
            row.contentRow.isSelected = NO;
        }
    }else{
        [row.contentRow setValue:@"0" forKey:@"option_qty"];
    }
    if (currentSectionIndex >= 0) {
        [self.tableViewOption reloadSections:[NSIndexSet indexSetWithIndex:currentSectionIndex] withRowAnimation:UITableViewRowAnimationNone];
    }
    [self configSelectedOption];
    [self.delegate updatePriceWhenSelectOption];
}

#pragma mark UITextField Delegate
- (void)showKeyboardInputText
{
    isHideKeyBoard = NO;
    if (!isShowKeyBoard) {
        isShowKeyBoard = YES;
        CGRect frame = self.view.frame;
        frame.size.height -= 180;
        self.view.frame = frame;
    }
}

- (void)hideKeyboardInputText
{
    isShowKeyBoard = NO;
    if (!isHideKeyBoard) {
        isHideKeyBoard = YES;
        CGRect frame = self.view.frame;
        frame.size.height += 180;
        self.view.frame = frame;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    SCProductOptionSection *section = nil;
    int currentSectionIndex = -1;
    for (int i = 0; i < cells.count; i++) {
        SCProductOptionSection *sectionTemp = [cells objectAtIndex:i];
        if ([sectionTemp.identifier isEqualToString:(NSString*)(textField.simiObjectIdentifier)]) {
            section = sectionTemp;
            currentSectionIndex = i;
            break;
        }
    }
    SCProductOptionRow *row = (SCProductOptionRow*)[section objectAtIndex:0];
    NSString *text = textField.text;
    [self.selectedOptionPrice setValue:@"" forKey:section.identifier];
    if (text == nil || [text isEqualToString:@""]) {
        [row.contentRow removeObjectForKey:@"option_value"];
        row.contentRow.isSelected = NO;
    } else {
        row.contentRow.isSelected = YES;
        [row.contentRow setValue:textField.text forKey:@"option_value"];
        [section.sectionContent setValue:@"YES" forKey:is_selected];
        if ([row.contentRow valueForKey:@"price_include_tax"] && DISPLAY_PRICES_INSHOP) {
            [self.selectedOptionPrice setValue:[NSString stringWithFormat:@"%@",[row.contentRow valueForKey:@"price_include_tax"]] forKey:section.identifier];
        }else
            [self.selectedOptionPrice setValue:[NSString stringWithFormat:@"%@",[row.contentRow valueForKey:@"price"]] forKey:section.identifier];
    }
    [self.delegate updatePriceWhenSelectOption];
    if (currentSectionIndex >= 0) {
        [self.tableViewOption reloadSections:[NSIndexSet indexSetWithIndex:currentSectionIndex] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark Datetime Picker Action
- (void)changeDatePicker:(UIDatePicker *)datePicker
{
    SCProductOptionSection *section = nil;
    int currentSectionIndex = -1;
    for (int i = 0; i < cells.count; i++) {
        SCProductOptionSection *sectionTemp = [cells objectAtIndex:i];
        if ([sectionTemp.identifier isEqualToString:(NSString*)(datePicker.simiObjectIdentifier)]) {
            section = sectionTemp;
            currentSectionIndex = i;
            break;
        }
    }
    SCProductOptionRow *row = (SCProductOptionRow*)[section objectAtIndex:0];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    if ([[row.contentRow objectForKey:@"option_type"] isEqualToString:@"date"]) {
        [dateFormater setDateFormat:@"yyyy-MM-dd"];
    } else if ([[row.contentRow objectForKey:@"option_type"] isEqualToString:@"date_time"]) {
        [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    } else {
        [dateFormater setDateFormat:@"HH:mm:ss"];
    }
    if ([row.contentRow objectForKey:@"option_value"] == nil) {
        // Change option value and title
        row.contentRow.isSelected = YES;
        if ([row.contentRow valueForKey:@"price_include_tax"] && DISPLAY_PRICES_INSHOP) {
            [self.selectedOptionPrice setValue:[NSString stringWithFormat:@"%@",[row.contentRow valueForKey:@"price_include_tax"]] forKey:section.identifier];
        }else
            [self.selectedOptionPrice setValue:[NSString stringWithFormat:@"%@",[row.contentRow valueForKey:@"price"]] forKey:section.identifier];
        [section.sectionContent setValue:@"YES" forKey:is_selected];
    }
    [section.sectionContent setValue:[dateFormater stringFromDate:datePicker.date] forKey:@"option_value"];
    [self.delegate updatePriceWhenSelectOption];
    if (currentSectionIndex >= 0) {
        [tableViewOption reloadData];
    }
}

#pragma mark Done & Cancel action
- (void)didTouchDone:(id)sender
{
    [self.delegate doneButtonTouch];
}

- (void)didTouchCancel:(id)sender
{
    [self.delegate cancelButtonTouch];
}

#pragma mark Dependence_option_ids
-  (void)activeDependenceWith:(SCProductOptionRow*)row andKey:(NSString*)key
{
    ProductOptionModel *option = row.contentRow;
    
    NSMutableArray *dependenceOptionIds = option.dependIds;
    NSMutableSet *depenceOptionSet = [NSMutableSet setWithArray:dependenceOptionIds];
    int count = 0;
    if (option.isSelected) {
        if (dependenceOptionIds.count > 0) {
            for (NSString *key2 in self.variantsAllKey) {
                VariantAttribute *variantAttribute = [self.variantAttributes valueForKey:key2];
                if (![key2 isEqualToString:key]) {
                    variantAttribute.isSelected = NO;
                    for (ProductOptionModel *optionModel in self.variantOptions) {
                        if ([optionModel.variantAttributeKey isEqualToString:key2]) {
                            NSMutableSet *tempSet = [NSMutableSet setWithArray:optionModel.dependIds];
                            [tempSet intersectSet:depenceOptionSet];
                            if ([[tempSet allObjects] count] > 0) {
                                if (optionModel.isSelected) {
                                    depenceOptionSet = tempSet;
                                    variantAttribute.isSelected = YES;
                                }else
                                    optionModel.hightLight = YES;
                            }else
                            {
                                optionModel.hightLight = NO;
                                optionModel.isSelected = NO;
                            }
                        }
                    }
                    if (variantAttribute.isSelected) {
                        for (ProductOptionModel *optionModel in variantAttribute.arrayOption) {
                            optionModel.hightLight = NO;
                        }
                        count ++;
                    }
                }else
                {
                    for (ProductOptionModel *optionModel in variantAttribute.arrayOption) {
                        if (!optionModel.isSelected) {
                            optionModel.hightLight = NO;
                        }
                    }
                    count++;
                    variantAttribute.isSelected = YES;
                }
            }
        }
    }
    if (depenceOptionSet.count == 1 && count == self.variantsAllKey.count) {
        self.variantSelectedKey = [depenceOptionSet.allObjects objectAtIndex:0];
    }else
        self.variantSelectedKey = @"";
}

- (void)configSelectedOption
{
    if (self.selectedOptionPrice == nil) {
        self.selectedOptionPrice = [[NSMutableDictionary alloc] init];
    }
#pragma mark Custom Option
    for (NSMutableDictionary *custom in self.customs) {
        CGFloat optionPrice = 0;
        NSString *tempKey = [custom valueForKey:@"_id"];
        NSMutableArray *options = [self.customOptions valueForKey:tempKey];
        BOOL isSelected = NO;
        for (ProductOptionModel *opt in options) {
            if (opt.isSelected) {
                CGFloat optionQty = 1.0f;
                if ([[opt valueForKey:@"qty"] floatValue] > 0.01f) {
                    optionQty = [[opt valueForKey:@"qty"] floatValue];
                }
                if ([opt valueForKey:@"price_include_tax"] && DISPLAY_PRICES_INSHOP) {
                    optionPrice += optionQty * [[NSString stringWithFormat:@"%@",[opt valueForKey:@"price_include_tax"]] floatValue];
                }else
                {
                    optionPrice += optionQty * [[NSString stringWithFormat:@"%@",[opt valueForKey:@"price"]] floatValue];
                }
                isSelected = YES;
            }
        }
        if (isSelected) {
            [custom setValue:@"YES" forKey:is_selected];
            [self.selectedOptionPrice setValue:[NSString stringWithFormat:@"%.2f", optionPrice] forKey:tempKey];
        }else{
            [self.selectedOptionPrice removeObjectForKey:tempKey];
            [custom setValue:@"NO" forKey:is_selected];
        }
    }
#pragma mark Bundle Option
    for (NSMutableDictionary *bundleItem in self.bundleItems) {
        CGFloat optionPrice = 0;
        NSString *tempKey = [bundleItem valueForKey:@"_id"];
        NSMutableArray *options = [self.bundleOptions valueForKey:tempKey];
        BOOL isSelected = NO;
        for (ProductOptionModel *opt in options) {
            if (opt.isSelected) {
                CGFloat optionQty = 1.0f;
                if ([[opt valueForKey:@"qty"] floatValue] > 0.01f) {
                    optionQty = [[opt valueForKey:@"qty"] floatValue];
                    
                }
                if ([[self.product valueForKey:@"sale_price_type"]boolValue]) {
                    if (DISPLAY_PRICES_INSHOP) {
                        optionPrice += optionQty *[[opt valueForKey:@"ex_price_include_tax"] floatValue];
                    }else
                    {
                        optionPrice += optionQty *[[opt valueForKey:@"ex_price"] floatValue];
                    }
                }else
                {
                    if ([opt valueForKey:@"price_include_tax"]&& DISPLAY_PRICES_INSHOP) {
                        if ([opt valueForKey:@"sale_price_include_tax"]) {
                            optionPrice += optionQty *[[opt valueForKey:@"sale_price_include_tax"] floatValue];
                        }else
                            optionPrice += optionQty *[[opt valueForKey:@"price_include_tax"] floatValue];
                    }else
                    {
                        if ([opt valueForKey:@"sale_price"]) {
                            optionPrice += optionQty *[[opt valueForKey:@"sale_price"] floatValue];
                        }else
                            optionPrice += optionQty *[[opt valueForKey:@"price"] floatValue];
                    }
                }
                isSelected = YES;
            }
        }
        if (isSelected) {
            [bundleItem setValue:@"YES" forKey:is_selected];
            [self.selectedOptionPrice setValue:[NSString stringWithFormat:@"%.2f", optionPrice] forKey:tempKey];
        }else{
            [self.selectedOptionPrice removeObjectForKey:tempKey];
            [bundleItem setValue:@"NO" forKey:is_selected];
        }
    }
#pragma mark Group Option
    for (ProductOptionModel *groupItem in self.groupOptions) {
        CGFloat optionPrice = 0;
        BOOL isSelected = NO;
        if (groupItem.isSelected) {
            CGFloat optionQty = 1.0f;
            if ([[groupItem valueForKey:@"option_qty"] floatValue] > 0.01f) {
                optionQty = [[groupItem valueForKey:@"option_qty"] floatValue];
                
            }
            if ([groupItem valueForKey:@"price_include_tax"]&& DISPLAY_PRICES_INSHOP) {
                if ([groupItem valueForKey:@"sale_price_include_tax"]) {
                    optionPrice += optionQty *[[groupItem valueForKey:@"sale_price_include_tax"] floatValue];
                }else
                    optionPrice += optionQty *[[groupItem valueForKey:@"price_include_tax"] floatValue];
            }else
            {
                if ([groupItem valueForKey:@"sale_price"]) {
                    optionPrice += optionQty *[[groupItem valueForKey:@"sale_price"] floatValue];
                }else
                    optionPrice += optionQty *[[groupItem valueForKey:@"price"] floatValue];
            }
            isSelected = YES;
        }
        if (isSelected) {
            [self.selectedOptionPrice setValue:[NSString stringWithFormat:@"%.2f", optionPrice] forKey:[groupItem valueForKey:@"_id"]];
        }else{
            [self.selectedOptionPrice removeObjectForKey:[groupItem valueForKey:@"_id"]];
        }
    }
    [self.delegate updatePriceWhenSelectOption];
}
@end


#pragma mark ProductOption Select Cell
@implementation ProductOptionSelectCell
@synthesize lblNameOption, lblPriceExclTax, lblPriceInclTax, imageSelect, isMultiSelect, isSelected, dataCell;
- (void)setDataForCell:(ProductOptionModel *)data
{
    dataCell = [[ProductOptionModel alloc]initWithDictionary:data];
    dataCell.isSelected = data.isSelected;
    dataCell.variantAttributeTitle = data.variantAttributeTitle;
    dataCell.variantAttributeKey = data.variantAttributeKey;
    dataCell.hightLight = data.hightLight;
    dataCell.dependIds = data.dependIds;
    if (lblNameOption == nil) {
        lblNameOption = [[UILabel alloc]init];
        lblNameOption.numberOfLines = 2;
        [lblNameOption setTextColor:[[SimiGlobalVar sharedInstance]colorWithHexString:@"#949494"]];
        [lblNameOption setFont:[UIFont fontWithName:THEME_FONT_NAME size:12]];
        [self addSubview:lblNameOption];
    }
    
    if (lblPriceInclTax == nil) {
        lblPriceInclTax = [[UILabel alloc]init];
        lblPriceInclTax.numberOfLines = 1;
        [lblPriceInclTax setTextAlignment:NSTextAlignmentLeft];
        [lblPriceInclTax setFont:[UIFont fontWithName:THEME_FONT_NAME size:12]];
        [self addSubview:lblPriceInclTax];
    }
    
    float cellHeight = 50;
    float widthCell = SCREEN_WIDTH - 20;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        widthCell = SCREEN_WIDTH *2/3;
    }
    float imageSize = 16;
    float paddingLeft = 10;
    float paddingRight = 10;
    float imageSelectX = widthCell - imageSize - paddingRight;
    float widthPrice = 70;
    float spaceNamePrice = 10;
    float widthName = widthCell - paddingLeft - paddingRight - widthPrice - imageSize - spaceNamePrice;
    
    if (imageSelect == nil) {
        imageSelect = [[UIImageView alloc]initWithFrame:CGRectMake(imageSelectX, (cellHeight - imageSize)/2, imageSize, imageSize)];
        //  Liam Update RTL
        if ([[SimiGlobalVar sharedInstance]isReverseLanguage]) {
            
        }
        //  End RTL
    }
    [lblNameOption setText:[dataCell valueForKey:@"title"]];
    if ([dataCell valueForKey:@"name"]) {
        [lblNameOption setText:[dataCell valueForKey:@"name"]];
    }
    [lblNameOption setFrame:CGRectMake(paddingLeft, 0, widthName, cellHeight)];
    if (self.product != nil) {
        NSString *priceInclTax = @"";
        if ([[self.product valueForKey:@"sale_price_type"]boolValue]) {
            if (DISPLAY_PRICES_INSHOP) {
                priceInclTax = [[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%@",[dataCell valueForKey:@"ex_price_include_tax"]]];
            }else
            {
                priceInclTax = [[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%@",[dataCell valueForKey:@"ex_price"]]];
            }
        }else
        {
            if ([dataCell valueForKey:@"price_include_tax"]&& DISPLAY_PRICES_INSHOP) {
                if ([dataCell valueForKey:@"sale_price_include_tax"]) {
                    priceInclTax = [[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%@",[dataCell valueForKey:@"sale_price_include_tax"]]];
                }else
                    priceInclTax = [[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%@",[dataCell valueForKey:@"price_include_tax"]]];
            }else
            {
                if ([dataCell valueForKey:@"sale_price"]) {
                    priceInclTax = [[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%@",[dataCell valueForKey:@"sale_price"]]];
                }else
                    priceInclTax = [[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%@",[dataCell valueForKey:@"price"]]];
            }
        }
        [lblPriceInclTax setFrame:CGRectMake(paddingLeft + widthName + spaceNamePrice, 0, widthPrice, cellHeight)];
        [lblPriceInclTax setText:[NSString stringWithFormat:@"%@",priceInclTax]];
    }else
    {
        if([dataCell valueForKey:@"price_include_tax"] && DISPLAY_PRICES_INSHOP)
        {
            [lblPriceInclTax setFrame:CGRectMake(paddingLeft + widthName + spaceNamePrice, 0, widthPrice, cellHeight)];
            NSString* priceInclTax = [[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%@",[dataCell valueForKey:@"price_include_tax"]]];
            [lblPriceInclTax setText:[NSString stringWithFormat:@"%@",priceInclTax]];
        }else if([dataCell valueForKey:@"price"])
        {
            [lblPriceInclTax setFrame:CGRectMake(paddingLeft + widthName + spaceNamePrice, 0, widthPrice, cellHeight)];
            NSString* priceInclTax = [[SimiFormatter sharedInstance] priceWithPrice:[NSString stringWithFormat:@"%@",[dataCell valueForKey:@"price"]]];
            [lblPriceInclTax setText:[NSString stringWithFormat:@"%@",priceInclTax]];
        }
    }
    
    if (!self.isMultiSelect) {
        if (dataCell.isSelected) {
            [imageSelect setImage:[UIImage imageNamed:@"ic_selected"]];
        }else
        {
            [imageSelect setImage:[UIImage imageNamed:@"ic_unselected"]];
        }
    }else
    {
        if (dataCell.isSelected) {
            [imageSelect setImage:[UIImage imageNamed:@"ic_multiselected"]];
        }else
        {
            [imageSelect setImage:[UIImage imageNamed:@"ic_unmultiselected"]];
        }
    }
    [self addSubview:imageSelect];
    if (dataCell.hightLight && !dataCell.isSelected) {
        [self setBackgroundColor:[[SimiGlobalVar sharedInstance]colorWithHexString:@"#795548"]];
    }else
    {
        [self setBackgroundColor:[UIColor whiteColor]];
    }
}
@end

#pragma mark Option Text Cell
@implementation ProductOptionTextCell
@synthesize textOption;
@end

#pragma mark DateTime Option Cell

@implementation ProductOptionDateTimeCell
@synthesize datePicker;
@end

@implementation VariantAttribute : NSObject
- (instancetype)init
{
    self = [super init];
    self.arrayOption = [NSMutableArray new];
    return  self;
}
@end
