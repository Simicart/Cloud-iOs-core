//
//  SCCreditCardViewController.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 12/16/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import "SCCreditCardViewController.h"

#define CARD_TYPE 0
#define CARD_NUMBER 1
#define EXPIRED_DATE 2
#define CVV 3

static NSString *CREDITCARD_SECTION = @"CreditCardSection";
static NSString *kCardTypeCell = @"CreditCardTypeCell";
static NSString *kCardTypePickerCell = @"CreditCardTypePickerCell";
static NSString *kCardNameCell = @"CreditCardNameCell";
static NSString *kCardNumberCell = @"CreditCardNumbereCell";
static NSString *kCardDateCell = @"CreditCardDateCell";
static NSString *kCardDatePickerCell = @"CreditCardDatePickerCell";
static NSString *kCardCvvCell = @"CreditCardCvvCell";
static NSString *kOtherCell = @"OtherCell";

@interface SCCreditCardViewController ()

@end

@implementation SCCreditCardViewController

@synthesize cardNumberTF, CVVTF, expireTimeTF, rightBarButton, cardInfoTableView, isCompletedText, creditCardImageView, isUseCVV, cardTypeTF, cardType, creditCardList, creditCardPickerView, isSelectingCreditCardType, selectedCardTypeRow, isValidTime, defaultCard, expireOption,isSelectingExpireDate,selectedExpireMonthRow,selectedExpireYearRow;

@synthesize cardCells = _cardCells;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppearBefore:(BOOL)animated
{
    
}

- (void)viewDidLoadAfter
{
    [super viewDidLoadAfter];
    self.title = [self formatTitleString:SCLocalizedString(@"Credit Card")];
    rightBarButton = [[UIBarButtonItem alloc] initWithTitle:SCLocalizedString(@"Done") style:UIBarButtonItemStyleDone target:self action:@selector(saveCardInfo)];
    cardInfoTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    cardInfoTableView.dataSource = self;
    cardInfoTableView.delegate = self;
    cardInfoTableView.scrollEnabled = NO;
    isCompletedText = NO;
    isSelectingExpireDate = NO;
    isSelectingCreditCardType = NO;
    cardType = [defaultCard valueForKey:@"card_type"];
    [self.view addSubview:cardInfoTableView];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    selectedCardTypeRow = -1;
    if (SIMI_SYSTEM_IOS >= 9) {
        cardInfoTableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkCreditCardType{
    
}


- (void)saveCardInfo{
    NSString *cardNumber = [cardNumberTF.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSArray *expiredTime = [expireTimeTF.text componentsSeparatedByString:@" / "];
    NSString *expiredMonth = [expiredTime objectAtIndex:0];
    NSString *expiredYear = [NSString stringWithFormat:@"20%@", [expiredTime objectAtIndex:1]];
    NSString *cvv = CVVTF.text;
    [self.delegate didEnterCreditCardWithCardType:cardType cardNumber:cardNumber expiredMonth:expiredMonth expiredYear:expiredYear cvv:cvv];
    [self.navigationController popToViewController:(UIViewController *)self.delegate animated:YES];
}

- (void)checkIsCompletedText{
    if (cardTypeTF.text.length > 0 && cardNumberTF.text.length > 0 && isValidTime) {
        if (isUseCVV) {
            if (CVVTF.text.length > 0) {
                isCompletedText = YES;
            }else{
                isCompletedText = NO;
            }
        }else{
            isCompletedText = YES;
        }
    }else{
        isCompletedText = NO;
    }
    self.navigationItem.rightBarButtonItem.enabled = self.isCompletedText;
}

#pragma mark - Init Cart Cells
- (SimiTable *)cardCells
{
    if (_cardCells) {
        return _cardCells;
    }
    _cardCells = [SimiTable new];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitCreditCardCell-Before" object:_cardCells];
    
    SimiSection *cardSection = [_cardCells addSectionWithIdentifier:CREDITCARD_SECTION];
    [cardSection addRowWithIdentifier:kCardTypeCell height:45];
    if(isSelectingCreditCardType){
        [cardSection addRowWithIdentifier:kCardTypePickerCell height:170];
    }
    [cardSection addRowWithIdentifier:kCardNumberCell height:45];
    [cardSection addRowWithIdentifier:kCardDateCell height:45];
    if(isSelectingExpireDate){
        [cardSection addRowWithIdentifier:kCardDatePickerCell height:170];
    }
    [cardSection addRowWithIdentifier:kCardCvvCell height:45];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitCreditCardCell-After" object:_cardCells];
    return _cardCells;
}

- (void)reloadData
{
    _cardCells = nil;
    [self.cardInfoTableView reloadData];
}

#pragma mark Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.cardCells count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self.cardCells objectAtIndex:section] count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[[self.cardCells objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]] height];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cardCells objectAtIndex:[indexPath section]];
    SimiRow *row = [section objectAtIndex:[indexPath row]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedCreditCardCell-Before" object:row];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return (UITableViewCell *)self.simiObjectIdentifier;
    }
    UITableViewCell *aCell;
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 45);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        frame.size.width = 680;
    }
    frame.origin.x += 15;
    frame.size.width -= 15;
    #pragma mark - Init Cart Cells
    if ([section.identifier isEqualToString:CREDITCARD_SECTION]) {
        if ([row.identifier isEqualToString:kCardTypeCell]) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCardTypeCell];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCardTypeCell];
            }
            if (cardTypeTF == nil) {
                cardTypeTF = [[UITextField alloc] initWithFrame:frame];
                cardTypeTF.placeholder = [NSString stringWithFormat:@"%@:",SCLocalizedString(@"Card Type")];
                cardTypeTF.tag = CARD_TYPE;
                cardTypeTF.delegate = self;
                cardTypeTF.userInteractionEnabled = NO;
                if(defaultCard != nil)
                {
                    cardTypeTF.text = [defaultCard valueForKey:@"card_type"];
                    
                    for (int i=0; i<creditCardList.count; i++) {
                        if([cardTypeTF.text isEqualToString:[[creditCardList objectAtIndex:i] valueForKey:@"cc_name"] ])
                        {
                            selectedCardTypeRow = i;
                            break;
                        }
                    }
                }
            }
            [cell addSubview:cardTypeTF];
            aCell = cell;
        }else if ([row.identifier isEqualToString:kCardTypePickerCell]) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCardTypePickerCell];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCardTypePickerCell];
            }
            if (creditCardPickerView == nil) {
                creditCardPickerView = [[UIPickerView alloc] init];
                creditCardPickerView.delegate = self;
                creditCardPickerView.dataSource = self;
                creditCardPickerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 170);
                creditCardPickerView.tag = CARD_TYPE;
                creditCardPickerView.backgroundColor = [UIColor whiteColor];
            }
            [cell addSubview:creditCardPickerView];
            aCell = cell;
        }else if ([row.identifier isEqualToString:kCardNumberCell]) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCardNumberCell];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCardNumberCell];
            }
            if (cardNumberTF == nil) {
                cardNumberTF = [[UITextField alloc] initWithFrame:frame];
                cardNumberTF.placeholder = [NSString stringWithFormat:@"%@:",SCLocalizedString(@"Card Number")];
                cardNumberTF.keyboardType = UIKeyboardTypeNumberPad;
                cardNumberTF.tag = CARD_NUMBER;
                cardNumberTF.delegate = self;
                cardNumberTF.clearButtonMode = UITextFieldViewModeWhileEditing;
                if(defaultCard != nil)
                {
                    cardNumberTF.text = [defaultCard valueForKey:@"card_number"];
                }
            }
            [cell addSubview:cardNumberTF];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            aCell = cell;
        }else if ([row.identifier isEqualToString:kCardDateCell]){
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCardDateCell];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCardDateCell];
            }
            if (expireTimeTF == nil) {
                expireTimeTF = [[UITextField alloc] initWithFrame:frame];
                expireTimeTF.placeholder = SCLocalizedString(@"Expired: MM/YY");
                expireTimeTF.keyboardType = UIKeyboardTypeNumberPad;
                expireTimeTF.tag = EXPIRED_DATE;
                expireTimeTF.delegate = self;
                expireTimeTF.clearButtonMode = UITextFieldViewModeWhileEditing;
                expireTimeTF.userInteractionEnabled = NO;

                if(defaultCard != nil)
                {
                    expireTimeTF.text = [NSString stringWithFormat:@"%@ / %@", [defaultCard valueForKey:@"expired_month"], [[defaultCard valueForKey:@"expired_year"] substringFromIndex:(((NSString*)[defaultCard valueForKey:@"expired_year"]).length-2)]];
                    selectedExpireMonthRow = [((NSString*)[defaultCard valueForKey:@"expired_month"]) intValue]-1;
                    
                    NSDate *currentDate = [NSDate date];
                    NSCalendar* calendar = [NSCalendar currentCalendar];
                    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate];
                    selectedExpireYearRow = [[defaultCard valueForKey:@"expired_year"] intValue] - [components year];
                }
                
                if (expireTimeTF.text.length == 7) {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"MM / yy"];
                    NSDate *newDate = [dateFormatter dateFromString:expireTimeTF.text];
                    if (newDate == nil) {
                        isValidTime = NO;
                        expireTimeTF.textColor = [UIColor redColor];
                    }else{
                        isValidTime = YES;
                        expireTimeTF.textColor = [UIColor blackColor];
                    }
                }else{
                    isValidTime = NO;
                }
            }
            [cell addSubview:expireTimeTF];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            aCell = cell;
        }else if ([row.identifier isEqualToString:kCardDatePickerCell]){
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCardDatePickerCell];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCardDatePickerCell];
            }
            if (expireOption == nil) {
                expireOption = [[UIPickerView alloc] init];
                expireOption.delegate = self;
                expireOption.dataSource = self;
                expireOption.frame = CGRectMake(0, 0, self.view.frame.size.width, 170);
                expireOption.tag = EXPIRED_DATE;
                expireOption.backgroundColor = [UIColor whiteColor];
            }
            [expireOption setHidden:NO];
            [cell addSubview:expireOption];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            aCell = cell;
        }else if ([row.identifier isEqualToString:kCardCvvCell]){
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCardCvvCell];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCardCvvCell];
            }
            if (CVVTF == nil && isUseCVV) {
                CVVTF = [[UITextField alloc] initWithFrame:frame];
                CVVTF.placeholder = SCLocalizedString(@"CVV");
                CVVTF.keyboardType = UIKeyboardTypeNumberPad;
                CVVTF.tag = CVV;
                CVVTF.delegate = self;
                CVVTF.clearButtonMode = UITextFieldViewModeWhileEditing;
                if(defaultCard != nil)
                {
                    CVVTF.text = [defaultCard valueForKey:@"cc_id"];
                }
            }
            [cell addSubview:CVVTF];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            aCell = cell;
        }
    }
    if (aCell == nil) {
        aCell = [UITableViewCell new];
    }
    self.simiObjectIdentifier = aCell;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedCreditCardCell-After" object:aCell];
    return aCell;
}

- (BOOL)indexPathHasPicker:(NSIndexPath *)indexPath
{
    return (isSelectingCreditCardType && self.cardTypePickerIndexPath.row == indexPath.row);
}

#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *section = [self.cardCells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:[indexPath row]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectCreditCardCellAtIndexPath" object:row userInfo:@{@"tableView": tableView, @"indexPath": indexPath}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return;
    }
    if([row.identifier isEqualToString:kCardTypeCell]){
        if (!isSelectingCreditCardType) {
            isSelectingCreditCardType = YES;
            isSelectingExpireDate = NO;
        }else{
            isSelectingCreditCardType = NO;
        }
        [self reloadData];
    }else if([row.identifier isEqualToString:kCardDateCell]){
        if (!isSelectingExpireDate) {
            isSelectingExpireDate = YES;
            isSelectingCreditCardType = NO;
        }else{
            isSelectingExpireDate = NO;
        }
        [self reloadData];
    }else{
        isSelectingCreditCardType = NO;
        isSelectingExpireDate = NO;
    }
    
}

#pragma mark Picker View Data Source
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    if(pickerView.tag == CARD_TYPE)
        return 1;
    else if(pickerView.tag == EXPIRED_DATE)
        return 2;
    return 0;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if(pickerView.tag == CARD_TYPE)
        return creditCardList.count;
    else if(pickerView.tag == EXPIRED_DATE)
        return 12;
    return 0;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    if(pickerView.tag == CARD_TYPE)
        return 45;
    else
        return 30;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    if(pickerView.tag == CARD_TYPE && isSelectingCreditCardType)
    {
        NSString *creditCardCode = [[creditCardList objectAtIndex:row] valueForKey:@"code"];
        UIView *creditCardView = [[UIView alloc] init];
        UIImageView *imageView = [[UIImageView alloc] init];
        if ([creditCardCode isEqualToString:@"american_express"]) {
            imageView.image = [UIImage imageNamed:@"card_amex.png"];
        }else if ([creditCardCode isEqualToString:@"visa"]){
            imageView.image = [UIImage imageNamed:@"card_visa.png"];
        }else if ([creditCardCode isEqualToString:@"masterCard"]){
            imageView.image = [UIImage imageNamed:@"card_mastercard.png"];
        }else if ([creditCardCode isEqualToString:@"discover"]){
            imageView.image = [UIImage imageNamed:@"card_discover.png"];
        }
        
        imageView.frame = CGRectMake(40, 2.5, 64, 40);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.userInteractionEnabled = NO;
        [creditCardView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 10, 0, 200, 45);
        [label setText:[[creditCardList objectAtIndex:row] valueForKey:@"cc_name"]];
        [creditCardView addSubview:label];
        
        return creditCardView;
    }
    else if(pickerView.tag == EXPIRED_DATE && isSelectingExpireDate)
    {
        if(component == 0)
        {
            UILabel *label = [[UILabel alloc] init];
            label.frame = CGRectMake(0, 0, self.view.frame.size.width/2, 30);
            [label setText:[NSString stringWithFormat:@"%02d",(int)row+1]];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setFont:[UIFont boldSystemFontOfSize:20]];
            return label;
        }
        else
        {
            UILabel *label = [[UILabel alloc] init];
            label.frame = CGRectMake(self.view.frame.size.width/2, 0, self.view.frame.size.width/2, 30);
            NSDate *currentDate = [NSDate date];
            NSCalendar* calendar = [NSCalendar currentCalendar];
            NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate];
            [components year]; // gives you year
            [label setText:[NSString stringWithFormat:@"%d",(int)([components year]+row)]];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setFont:[UIFont boldSystemFontOfSize:20]];
            return label;
        }
    }
    return nil;
}

#pragma mark Picker View Delegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if(pickerView.tag == CARD_TYPE)
    {
        selectedCardTypeRow = row;
        cardTypeTF.text = [[creditCardList objectAtIndex:row] valueForKey:@"title"];
        cardType = [[creditCardList objectAtIndex:row] valueForKey:@"code"];
        [self checkIsCompletedText];
    }
    else if(pickerView.tag == EXPIRED_DATE)
    {
        if(component == 0)
            selectedExpireMonthRow = row;
        else
            selectedExpireYearRow = row;
        NSDate *currentDate = [NSDate date];
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate];
        [components year];
        expireTimeTF.text = [NSString stringWithFormat:@"%02d / %@", (int)(selectedExpireMonthRow+1), [[NSString stringWithFormat:@"%d",(int)(selectedExpireYearRow+[components year])] substringFromIndex:2]];
        if (expireTimeTF.text.length == 7) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM / yy"];
            NSDate *newDate = [dateFormatter dateFromString:expireTimeTF.text];
            if (newDate == nil) {
                isValidTime = NO;
                expireTimeTF.textColor = [UIColor redColor];
            }else{
                isValidTime = YES;
                expireTimeTF.textColor = [UIColor blackColor];
            }
        }else{
            isValidTime = NO;
        }
    }
    [self checkIsCompletedText];
}

-(void)dissmissAllPickerView
{
    if(isSelectingCreditCardType)
    {
        [cardInfoTableView beginUpdates];
        isSelectingCreditCardType =  NO;
        
        self.cardTypePickerIndexPath = nil;
        NSInteger row = 1;
        [creditCardPickerView setHidden:YES];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        NSIndexPath *removeIndexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [cardInfoTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:removeIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [cardInfoTableView deselectRowAtIndexPath:indexPath animated:YES];
        _cardCells = nil;
        creditCardPickerView = nil;
        [cardInfoTableView endUpdates];
    }
    if(isSelectingExpireDate)
    {
        [cardInfoTableView beginUpdates];
        isSelectingExpireDate =  NO;
        
        self.expireDatePickerIndexPath = nil;
        NSInteger row = 3;
        [expireOption setHidden:YES];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        NSIndexPath *removeIndexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [cardInfoTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:removeIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [cardInfoTableView deselectRowAtIndexPath:indexPath animated:YES];
        _cardCells = nil;
        [cardInfoTableView endUpdates];
    }
}

#pragma mark Text Field Delegates
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField.tag == CARD_TYPE && textField.tag == EXPIRED_DATE) {
        return NO;
    }
    [self dissmissAllPickerView];
    [self checkIsCompletedText];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    switch (textField.tag) {
        case CARD_NUMBER:{
            NSString *textAfterReplacing = [textField.text stringByReplacingCharactersInRange:range withString:string];
            
            // In order to make the cursor end up positioned correctly, we need to explicitly reposition it after we inject spaces into the text.
            // No matter how the user changes the content - whether by deletion, insertion, or replacement of existing content by selecting and typing or pasting - we always want the cursor to end up at the end of the replacement string.
            // targetCursorPosition keeps track of where the cursor needs to end up as we modify the string, and at the end we set the cursor position to it.
            NSUInteger targetCursorPosition = range.location + [string length];
            
            NSString *cardNumberWithoutSpaces = [self removeNonDigits:textAfterReplacing andPreserveCursorPosition:&targetCursorPosition];
            
            if ([cardNumberWithoutSpaces length] > 16) {
                // If the user is trying to enter more than 16 digits, we cancel the entire operation and leave the text field as it was.
                return NO;
            }
            
            NSString *cardNumberWithSpaces = [self insertSpacesEveryFourDigitsIntoString:(NSString *)cardNumberWithoutSpaces andPreserveCursorPosition:&targetCursorPosition];
            
            textField.text = cardNumberWithSpaces;
            UITextPosition *targetPosition = [textField positionFromPosition:[textField beginningOfDocument] offset:targetCursorPosition];
            [textField setSelectedTextRange:[textField textRangeFromPosition:targetPosition toPosition:targetPosition]];
            [self checkIsCompletedText];
            return NO;
        }
            break;
        case EXPIRED_DATE:{
            if (range.location == 7) {
                return NO;
            }else{
                NSString *textAfterReplacing = [textField.text stringByReplacingCharactersInRange:range withString:string];
                NSUInteger targetCursorPosition = range.location + [string length];
                NSString *expiredDateWithoutSpaces = [self removeNonDigits:textAfterReplacing andPreserveCursorPosition:&targetCursorPosition];
                
                if ([expiredDateWithoutSpaces length] > 5) {
                    return NO;
                }
                
                NSString *expiredDateWithSlash = [self insertSlashEveryTwoDigitsIntoString:(NSString *)expiredDateWithoutSpaces andPreserveCursorPosition:&targetCursorPosition];
                
                textField.text = expiredDateWithSlash;
                UITextPosition *targetPosition = [textField positionFromPosition:[textField beginningOfDocument] offset:targetCursorPosition];
                [textField setSelectedTextRange:[textField textRangeFromPosition:targetPosition toPosition:targetPosition]];
                
                if (textField.text.length == 7) {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"MM / yy"];
                    NSDate *newDate = [dateFormatter dateFromString:textField.text];
                    if (newDate == nil) {
                        isValidTime = NO;
                        textField.textColor = [UIColor redColor];
                    }else{
                        isValidTime = YES;
                        textField.textColor = [UIColor blackColor];
                    }
                }else{
                    isValidTime = NO;
                }
                [self checkIsCompletedText];
                return NO;
            }
        }
            break;
        case CVV:{
            [self checkIsCompletedText];
        }
            break;
        default:
            break;
    }
    return YES;
}

/*
 Removes non-digits from the string, decrementing `cursorPosition` as
 appropriate so that, for instance, if we pass in `@"1111 1123 1111"`
 and a cursor position of `8`, the cursor position will be changed to
 `7` (keeping it between the '2' and the '3' after the spaces are removed).
 */
- (NSString *)removeNonDigits:(NSString *)string andPreserveCursorPosition:(NSUInteger *)cursorPosition {
    NSUInteger targetCursorPositionInOriginalReplacementString = *cursorPosition;
    NSMutableString *digitsOnlyString = [NSMutableString new];
    for (NSUInteger i=0; i<[string length]; i++) {
        unichar characterToAdd = [string characterAtIndex:i];
        if (isdigit(characterToAdd)) {
            NSString *stringToAdd = [NSString stringWithCharacters:&characterToAdd length:1];
            [digitsOnlyString appendString:stringToAdd];
        }
        else {
            if (i < targetCursorPositionInOriginalReplacementString) {
                (*cursorPosition)--;
            }
        }
    }
    
    return digitsOnlyString;
}

/*
 Inserts spaces into the string to format it as a credit card number,
 incrementing `cursorPosition` as appropriate so that, for instance, if we
 pass in `@"111111231111"` and a cursor position of `7`, the cursor position
 will be changed to `8` (keeping it between the '2' and the '3' after the
 spaces are added).
 */
- (NSString *)insertSpacesEveryFourDigitsIntoString:(NSString *)string andPreserveCursorPosition:(NSUInteger *)cursorPosition {
    NSMutableString *stringWithAddedSpaces = [NSMutableString new];
    NSUInteger cursorPositionInSpacelessString = *cursorPosition;
    for (NSUInteger i=0; i<[string length]; i++) {
        if ((i>0) && ((i % 4) == 0)) {
            [stringWithAddedSpaces appendString:@" "];
            if (i < cursorPositionInSpacelessString) {
                (*cursorPosition)++;
            }
        }
        unichar characterToAdd = [string characterAtIndex:i];
        NSString *stringToAdd = [NSString stringWithCharacters:&characterToAdd length:1];
        [stringWithAddedSpaces appendString:stringToAdd];
    }
    
    return stringWithAddedSpaces;
}

- (NSString *)insertSlashEveryTwoDigitsIntoString:(NSString *)string andPreserveCursorPosition:(NSUInteger *)cursorPosition {
    NSMutableString *stringWithAddedSlash = [NSMutableString new];
    NSUInteger cursorPositionInSlashlessString = *cursorPosition;
    for (NSUInteger i=0; i<[string length]; i++) {
        if ((i>0) && ((i % 2) == 0)) {
            [stringWithAddedSlash appendString:@" / "];
            if (i < cursorPositionInSlashlessString) {
                (*cursorPosition) += 3;
            }
        }
        unichar characterToAdd = [string characterAtIndex:i];
        NSString *stringToAdd = [NSString stringWithCharacters:&characterToAdd length:1];
        [stringWithAddedSlash appendString:stringToAdd];
    }
    
    return stringWithAddedSlash;
}

@end
