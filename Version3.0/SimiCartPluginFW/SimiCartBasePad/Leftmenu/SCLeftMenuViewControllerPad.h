//
//  SCLeftMenuPhoneViewController.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/4/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SimiCartBundle.h"
#import "SCLeftMenuViewController.h"
#import "SCCategoryViewControllerPad.h"
#import "LazyPageScrollView.h"


@interface SCLeftMenuViewControllerPad : SCLeftMenuViewController <LazyPageScrollViewDelegate, SCCategoryViewControllerPad_Delegate>

@property (strong, nonatomic) UIView * menuView;
@property (strong, nonatomic) SCCategoryViewControllerPad * categoryViewController;
@property (strong, nonatomic) LazyPageScrollView * leftMenuPageScrollView;
@property (strong, nonatomic) UIButton *loginButton;

- (void)updateCategoryWithModel:(SimiCategoryModelCollection *)categoryModelCollection categoryId:(NSString *)categoryId categoryName:(NSString *)categoryName;
- (void)updateCategoryWithId:(NSString *)categoryId categoryName:(NSString *)categoryName;

- (void)showCategory;
- (void)showMenu;
@end
