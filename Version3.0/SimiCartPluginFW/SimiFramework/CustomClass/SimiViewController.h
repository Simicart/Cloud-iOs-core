//
//  SimiViewController.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/10/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject+SimiObject.h"
#import <MessageUI/MessageUI.h>
@interface SimiViewController : UIViewController<UIAlertViewDelegate,MFMailComposeViewControllerDelegate>

/*
 The function viewDidLoad raise notification name: [NSString stringWithFormat:@"%@ViewDidLoad", NSStringFromClass(self.class)]
 
 Method viewWillAppear raise noti: [NSString stringWithFormat:@"%@-ViewWillAppear", NSStringFromClass(self.class)]
 
 Method viewWillAppear raise noti: [NSString stringWithFormat:@"%@-ViewWillDisappear", NSStringFromClass(self.class)]
 
 */
- (void)viewDidLoadBefore;
- (void)viewDidLoadAfter;
// Two methods are called before and after run UIViewController::viewDidLoad

- (void)viewWillAppearBefore:(BOOL)animated;
- (void)viewWillAppearAfter:(BOOL)animated;
// Two methods are called before and after run UIViewController::viewWillAppear

- (void)viewDidAppearBefore:(BOOL)animated;
- (void)viewDidAppearAfter:(BOOL)animated;

- (void)viewWillDisappearBefore:(BOOL)animated;
- (void)viewWillDisappearAfter:(BOOL)animated;
// Two methods are called before and after run UIViewController::viewWillDisappear

@property (strong, nonatomic) UIActivityIndicatorView *simiLoading;
@property (nonatomic) BOOL isPresented;
@property (nonatomic) BOOL isInPopover;
@property (strong, nonatomic) UIPopoverController *popover;
@property (nonatomic) BOOL didAppear;

- (void)setToSimiView;
- (void)startLoadingData;
- (void)stopLoadingData;
- (void)goBackPreviousControllerAnimated:(BOOL)animated;

//Formar navigationItem title
- (NSString *)formatTitleString:(NSString *)title;

- (void)configureNavigationBarOnViewDidLoad;
- (void)configureNavigationBarOnViewWillAppear;
- (void)configureLogo;

- (void)reloadRightBarItemsPad;
- (void)hiddenScreenWhenShowPopOver;
- (void)showScreenWhenHiddenPopOver;
- (void)showAlertContactSimiCartWithMessage:(NSString*)message;
- (void)sendEmailToStoreWithEmail:(NSArray *)email andEmailContent:(NSString *)emailContent;
@end
