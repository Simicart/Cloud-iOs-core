//
//  SCAppWishlistCoreWorker.m
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 8/25/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SCSearchVoiceCoreWorker.h"
#import <SimiCartBundle/SCHomeViewController.h>
#import <SimiCartBundle/MatrixHomeViewController.h>
#import <SimiCartBundle/ZaraHomeViewController.h>
#import <SimiCartBundle/SCNavigationBarPad.h>
#import "SCSearchVoiceViewController.h"
#import "SCSearchVoicePadViewController.h"
@implementation SCSearchVoiceCoreWorker {
    NSNotification *currentNoti;
    NSNotification *padNoti;
    BOOL *showOnPad;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        
#pragma mark searchVoice Button
        
        //Product More View
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSearchVoiceBtn:) name:@"SCHomeViewControllerViewWillAppear" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSearchVoiceBtn:) name:@"MatrixHomeViewControllerViewWillAppear" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSearchVoiceBtn:) name:@"ZaraHomeViewControllerViewWillAppear" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSearchVoiceBtn:) name:@"SCProductListViewControllerViewWillAppear" object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchVoicePad:) name:@"showSearchVoiceOnPad" object:nil];
        [SimiGlobalVar sharedInstance].isSearchVoice = YES;
    }
    return self;
}

#pragma mark handles

/*
-(void)searchVoicePad:(NSNotification *)noti {
    padNoti = noti;
    SCNavigationBarPad *naviPad = padNoti.object;
    [naviPad.voiceSearchButton addTarget:self action:@selector(searchVoiceBtnHandle) forControlEvents:(UIControlEventTouchUpInside)];
}
*/
-(void)showSearchVoiceBtn:(NSNotification *)noti
{
    currentNoti = noti;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        padNoti = noti;
    } else {
        if ([noti.object isKindOfClass:[SCHomeViewController class]]) {
            SCHomeViewController *homeViewController = noti.object;
            [homeViewController.searchBarHome setFrame:[SimiGlobalVar scaleFrame:CGRectMake(5, 5, 310 - 28 - 5, 28)]];
            [homeViewController.searchBarBackground setFrame:homeViewController.searchBarHome.frame];
            self.searchVoiceBtn = [[UIButton alloc] initWithFrame:[SimiGlobalVar scaleFrame:CGRectMake(282, 0, 38, 38)]];
            self.searchVoiceBtn.backgroundColor = [UIColor clearColor];
            self.searchVoiceBtn.imageView.backgroundColor = THEME_SEARCH_BOX_BACKGROUND_COLOR;
            [self.searchVoiceBtn setAlpha:0.9f];
            [self.searchVoiceBtn setImage:[UIImage imageNamed:@"ic_small_micro" ] forState:UIControlStateNormal];
            [self.searchVoiceBtn setImageEdgeInsets:(UIEdgeInsetsMake(5, 5, 5, 5))];
            self.searchVoiceBtn.imageView.clipsToBounds = YES;
            self.searchVoiceBtn.enabled = YES;
            [self.searchVoiceBtn addTarget:self action:@selector(searchVoiceBtnHandle) forControlEvents:(UIControlEventTouchUpInside)];
            [homeViewController.view addSubview:self.searchVoiceBtn];
        } else if ([noti.object isKindOfClass:[MatrixHomeViewController class]]) {
            MatrixHomeViewController *homeViewController = noti.object;
            [homeViewController.searchBarHome setFrame:[SimiGlobalVar scaleFrame:CGRectMake(5, 5, 310 - 28 - 5, 28)]];
            [homeViewController.searchBarBackground setFrame:homeViewController.searchBarHome.frame];
            self.searchVoiceBtn = [[UIButton alloc] initWithFrame:[SimiGlobalVar scaleFrame:CGRectMake(282, 0, 38, 38)]];
            self.searchVoiceBtn.backgroundColor = [UIColor clearColor];
            self.searchVoiceBtn.imageView.backgroundColor = THEME_SEARCH_BOX_BACKGROUND_COLOR;
            [self.searchVoiceBtn setAlpha:0.9f];
            [self.searchVoiceBtn setImage:[UIImage imageNamed:@"ic_small_micro" ] forState:UIControlStateNormal];
            [self.searchVoiceBtn setImageEdgeInsets:(UIEdgeInsetsMake(5, 5, 5, 5))];
            self.searchVoiceBtn.imageView.clipsToBounds = YES;
            self.searchVoiceBtn.enabled = YES;
            [self.searchVoiceBtn addTarget:self action:@selector(searchVoiceBtnHandle) forControlEvents:(UIControlEventTouchUpInside)];
            [homeViewController.view addSubview:self.searchVoiceBtn];
        } else if ([noti.object isKindOfClass:[ZaraHomeViewController class]]) {
            ZaraHomeViewController *homeViewController = noti.object;
            [homeViewController.searchBarHome setFrame:[SimiGlobalVar scaleFrame:CGRectMake(5, 5, 310 - 28 - 5, 28)]];
            [homeViewController.searchBarBackground setFrame:homeViewController.searchBarHome.frame];
            self.searchVoiceBtn = [[UIButton alloc] initWithFrame:[SimiGlobalVar scaleFrame:CGRectMake(282, 0, 38, 38)]];
            self.searchVoiceBtn.backgroundColor = [UIColor clearColor];
            self.searchVoiceBtn.imageView.backgroundColor = THEME_SEARCH_BOX_BACKGROUND_COLOR;
            [self.searchVoiceBtn setAlpha:0.9f];
            [self.searchVoiceBtn setImage:[UIImage imageNamed:@"ic_small_micro" ] forState:UIControlStateNormal];
            [self.searchVoiceBtn setImageEdgeInsets:(UIEdgeInsetsMake(5, 5, 5, 5))];
            self.searchVoiceBtn.imageView.clipsToBounds = YES;
            self.searchVoiceBtn.enabled = YES;
            [self.searchVoiceBtn addTarget:self action:@selector(searchVoiceBtnHandle) forControlEvents:(UIControlEventTouchUpInside)];
            [homeViewController.view addSubview:self.searchVoiceBtn];
        } else if ([noti.object isKindOfClass:[SCProductListViewController class]]) {
            SCProductListViewController *homeViewController = noti.object;
            [homeViewController.searchProduct setFrame:[SimiGlobalVar scaleFrame:CGRectMake(5, 5, 310 - 28 - 5, 28)]];
            [homeViewController.searchBarBackground setFrame:homeViewController.searchProduct.frame];
            self.searchVoiceBtn = [[UIButton alloc] initWithFrame:[SimiGlobalVar scaleFrame:CGRectMake(282, 0, 38, 38)]];
            self.searchVoiceBtn.backgroundColor = [UIColor clearColor];
            self.searchVoiceBtn.imageView.backgroundColor = THEME_SEARCH_BOX_BACKGROUND_COLOR;
            [self.searchVoiceBtn setAlpha:0.9f];
            [self.searchVoiceBtn setImage:[UIImage imageNamed:@"ic_small_micro" ] forState:UIControlStateNormal];
            [self.searchVoiceBtn setImageEdgeInsets:(UIEdgeInsetsMake(5, 5, 5, 5))];
            self.searchVoiceBtn.imageView.clipsToBounds = YES;
            self.searchVoiceBtn.enabled = YES;
            [self.searchVoiceBtn addTarget:self action:@selector(searchVoiceBtnHandle) forControlEvents:(UIControlEventTouchUpInside)];
            [homeViewController.view addSubview:self.searchVoiceBtn];
        }
    }
}

-(void)finishAction:(NSString *)result {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.searchVoicePadViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.searchVoiceViewController dismissViewControllerAnimated:YES completion:nil];
        if ([currentNoti.object isKindOfClass:[SCHomeViewController class]]) {
            SCHomeViewController *homeViewController = currentNoti.object;
            homeViewController.searchBarHome.text = result;
            [homeViewController searchBarSearchButtonClicked:homeViewController.searchBarHome];
        } else if ([currentNoti.object isKindOfClass:[MatrixHomeViewController class]]) {
            MatrixHomeViewController *homeViewController = currentNoti.object;
            homeViewController.searchBarHome.text = result;
            [homeViewController searchBarSearchButtonClicked:homeViewController.searchBarHome];
        } else if ([currentNoti.object isKindOfClass:[ZaraHomeViewController class]]) {
            ZaraHomeViewController *homeViewController = currentNoti.object;
            homeViewController.searchBarHome.text = result;
            [homeViewController searchBarSearchButtonClicked:homeViewController.searchBarHome];
        } else if ([currentNoti.object isKindOfClass:[SCProductListViewController class]]) {
            SCProductListViewController *homeViewController = currentNoti.object;
            homeViewController.searchProduct.text = result;
            [homeViewController searchBarSearchButtonClicked:homeViewController.searchProduct];
        }
    }
}

-(void)searchTextAction
{
    [self.searchVoiceViewController dismissViewControllerAnimated:YES completion:nil];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
    } else {
        if ([currentNoti.object isKindOfClass:[SCHomeViewController class]]) {
            SCHomeViewController *homeViewController = currentNoti.object;
            
            [homeViewController.searchBarHome becomeFirstResponder];
        } else if ([currentNoti.object isKindOfClass:[MatrixHomeViewController class]]) {
            MatrixHomeViewController *homeViewController = currentNoti.object;
            [homeViewController.searchBarHome becomeFirstResponder];
        } else if ([currentNoti.object isKindOfClass:[ZaraHomeViewController class]]) {
            ZaraHomeViewController *homeViewController = currentNoti.object;
            [homeViewController.searchBarHome becomeFirstResponder];
        } else if ([currentNoti.object isKindOfClass:[SCProductListViewController class]]) {
            SCProductListViewController *homeViewController = currentNoti.object;
            [homeViewController.searchProduct becomeFirstResponder];
        }
    }
}

-(void)tryAgainAction {
    
}

-(void)cancelAction {
    [self.searchVoiceViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)searchVoiceBtnHandle
{
    // check pad or phone
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        /*
        if (self.searchVoicePadViewController == nil) {
            self.searchVoicePadViewController = [[SCSearchVoicePadViewController alloc] init];
        }
        self.searchVoicePadViewController.delegate = self;
        UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
        UIViewController *viewController = [[(UINavigationController *)currentVC viewControllers] lastObject];
        for (UIViewController *viewControllerTemp in viewController.navigationController.viewControllers) {
            if ([viewControllerTemp isKindOfClass:[SCCartViewControllerPad class]]) {
                [viewControllerTemp.navigationController popToViewController:viewControllerTemp animated:YES];
                return;
            }
        }
        [(UINavigationController *)currentVC presentViewController:self.searchVoicePadViewController animated:YES completion:nil];
         */
    } else {
        SimiViewController *currentViewController = currentNoti.object;
        if (self.searchVoiceViewController == nil) {
            self.searchVoiceViewController = [[SCSearchVoiceViewController alloc] init];
        }
        self.searchVoiceViewController.delegate = self;
        [currentViewController presentViewController:self.searchVoiceViewController animated:YES completion:nil];
    }
    
}
// implement pad delegate
-(void)iPadFinishAction:(NSString *)result {
    [self.searchVoicePadViewController dismissViewControllerAnimated:YES completion:nil];
    SCNavigationBarPad *naviPad = padNoti.object;
    if (naviPad.searchBar ==nil) {
        naviPad.searchBar = [UISearchBar new];
        naviPad.searchBar.placeholder = SCLocalizedString(@"Search");
        for ( UIView * subview in [[naviPad.searchBar.subviews objectAtIndex:0] subviews] )
        {
            if ([subview isKindOfClass:NSClassFromString(@"UISearchBarTextField") ] ) {
                UITextField *searchView = (UITextField *)subview ;
                if ([[SimiGlobalVar sharedInstance] isReverseLanguage]) {
                    [searchView setTextAlignment:NSTextAlignmentRight];
                }
            }
        }
    }
    
    naviPad.searchBar.tintColor = THEME_SEARCH_TEXT_COLOR;
    naviPad.searchBar.text = result;
    [naviPad searchBarSearchButtonClicked:naviPad.searchBar];
}

/*
-(void)iPadSearchTextAction
{
    [self.searchVoicePadViewController dismissViewControllerAnimated:YES completion:nil];
    SCNavigationBarPad *naviPad = padNoti.object;
    [naviPad didSelectSearchButton:naviPad.searchBar];
}
*/
-(void)iPadTryAgainAction {
    
}

-(void)iPadCancelAction {
    [self.searchVoicePadViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
