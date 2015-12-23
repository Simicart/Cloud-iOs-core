//
//  SimiCart.h
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/12/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiBlock.h"
#import "SimiController.h"
#import "SimiCartSelector.h"

// Tre View Library
#import "SimiTreeView.h"
#import "UIView+SimiCart.h"
#import "SimiListView.h"
#import "SimiPageView.h"

// Block Library
#import "SimiCartMenuBlock.h"
#import "SimiCartBannerBlock.h"
#import "SimiCartTabsBlock.h"

// Form Library
#import "SimiFormBlock.h"
#import "SimiFormAbstract.h"
#import "SimiFormRow.h"
#import "SimiFormCheckbox.h"
#import "SimiFormText.h"
#import "SimiFormNumber.h"
#import "SimiFormTextArea.h"
#import "SimiFormEmail.h"
#import "SimiFormPassword.h"
#import "SimiFormSelect.h"
#import "SimiFormSelectOptions.h"
#import "SimiFormBoolean.h"
#import "SimiFormCCDate.h"
#import "SimiFormCCNumber.h"
#import "SimiFormCvv.h"
#import "SimiFormDate.h"

// Grid Library
#import "SimiGridBlock.h"
#import "SimiProductListBlock.h"

// Global Methods - SimiCart
@interface SimiCart : NSObject

/*!
 Block structure in SimiCart
 */
+ (SimiBlock *)rootBlock;
+ (SimiBlock *)createBlock:(NSString *)aClass;

/*!
 View tree global access
 */
+ (UIView *)overlayer;

+ (UIWindow *)mainWindow;
+ (UIView *)rootView;

+ (NSArray *)findViews:(NSString *)pattern;
+ (UIView *)view:(NSString *)pattern;

@end
