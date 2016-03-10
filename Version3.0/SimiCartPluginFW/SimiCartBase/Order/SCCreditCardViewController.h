//
//  SCCreditCardViewController.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 12/16/13.
//  Copyright (c) 2013 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimiModel.h"
#import "SimiViewController.h"
#import "SimiTable.h"

@protocol SCCreditCardViewDelegates <NSObject>
- (void)didEnterCreditCardWithCardName:(NSString*)cardName cardType:(NSDictionary *)cardType cardNumber:(NSString *)number expiredMonth:(NSString *)expiredMonth expiredYear:(NSString *)expiredYear cvv:(NSString *)CVV;
@end

@interface SCCreditCardViewController : SimiViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) SimiTable *cardCells;

@property (strong, nonatomic) UITableView *cardInfoTableView;
@property (strong, nonatomic) UIBarButtonItem *rightBarButton;
@property (strong, nonatomic) UITextField *cardNumberTF;
@property (strong, nonatomic) UITextField *expireTimeTF;
@property (strong, nonatomic) UITextField *CVVTF;
@property (strong, nonatomic) UITextField *cardTypeTF;
@property (strong, nonatomic) UITextField *cardName;
@property (strong, nonatomic) NSMutableDictionary *cardType;
@property (nonatomic) BOOL isCompletedText;
@property (strong, nonatomic) UIPopoverController * popThankController;
@property (strong, nonatomic) id<SCCreditCardViewDelegates> delegate;
@property (strong, nonatomic) UIImageView *creditCardImageView;
@property (strong, nonatomic) NSMutableArray *creditCardList;
@property (nonatomic) BOOL isUseCVV;
@property (nonatomic) BOOL isSelectingCreditCardType;
@property (nonatomic) BOOL isSelectingExpireDate;
@property (nonatomic) BOOL isValidTime;
@property (nonatomic) NSInteger selectedCardTypeRow;
@property (nonatomic) NSInteger selectedExpireMonthRow;
@property (nonatomic) NSInteger selectedExpireYearRow;
@property (strong, nonatomic) UIPickerView *creditCardPickerView;
@property (strong, nonatomic) NSIndexPath *cardTypePickerIndexPath;
@property (strong, nonatomic) NSIndexPath *expireDatePickerIndexPath;
@property (strong, nonatomic) NSDictionary *defaultCard;
@property (strong, nonatomic) UIPickerView *expireOption;

@property (strong, nonatomic) SimiModel *creditCard;

- (void)saveCardInfo;
- (void)checkCreditCardType;

@end
