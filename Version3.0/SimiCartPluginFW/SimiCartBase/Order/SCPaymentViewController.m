//
//  SCPaymentViewController.m
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 3/2/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SCPaymentViewController.h"
#import "SCThankYouPageViewController.h"
#import "SCAppDelegate.h"

@implementation SCPaymentViewController

-(void) configureNavigationBarOnViewWillAppear{
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPayment:)];
    backButton.title = SCLocalizedString(@"Cancel");
    NSMutableArray* leftBarButtons = [NSMutableArray arrayWithArray:self.navigationController.navigationItem.leftBarButtonItems];
    [leftBarButtons addObjectsFromArray:@[backButton]];
    self.navigationItem.leftBarButtonItems = leftBarButtons;
}

-(void) cancelPayment:(id) sender{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Confirmation") message:SCLocalizedString(@"Are you sure that you want to cancel the order?") delegate:self cancelButtonTitle:SCLocalizedString(@"Cancel") otherButtonTitles:SCLocalizedString(@"OK"), nil];
    [alertView show];
    alertView.tag = 0;
}



-(void) moveToThankyouPageWithNotification:(NSNotification *)noti{
    SimiResponder* responder = [noti.userInfo valueForKey:@"responder"];
    if([responder.status isEqualToString:@"SUCCESS"]){
        SCThankYouPageViewController* thankyouPage = [SCThankYouPageViewController new];
        NSDictionary* errors = [noti.object objectForKey:@"errors"];
        if(errors){
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[errors valueForKey:@"code"] message:[errors valueForKey:@"message"] delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles:nil, nil];
            [self.navigationController popToRootViewControllerAnimated:YES];
            [alert show];
        }else{
            thankyouPage.order = noti.object;
            [thankyouPage.navigationItem setHidesBackButton:YES];
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                [self.navigationController pushViewController:thankyouPage animated:YES];
            else{
                [self.navigationController popToRootViewControllerAnimated:YES];
                UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
                UIViewController *viewController = [[(UINavigationController *)currentVC viewControllers] lastObject];
                UINavigationController* nvThankyou = [[UINavigationController alloc] initWithRootViewController:thankyouPage];
                UIPopoverController* tkPopover = [[UIPopoverController alloc] initWithContentViewController:nvThankyou];
                thankyouPage.popOver = tkPopover;
                [tkPopover  presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:viewController.view permittedArrowDirections:0 animated:YES];
                NSLog(@"%@", self.navigationController.viewControllers);
            }
        }
    }else{
        [self.navigationController popToRootViewControllerAnimated:YES];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message: SCLocalizedString(responder.message) delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles:nil, nil];
        [alertView show];
    }
    [super didReceiveNotification:noti];

}

//UIAlertViewDelegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 0){
        if(buttonIndex == alertView.cancelButtonIndex){
            
        }else {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveToThankyouPageWithNotification:) name:DidCancelOrder object:nil];
            [self startLoadingData];
            if(self.order)
                [self.order cancelAnOrder:[self.order valueForKey:@"_id"]];
            else{
                [self.navigationController popToRootViewControllerAnimated:YES];
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Thank you") message:SCLocalizedString(@"Your order is cancelled.") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles:nil, nil];
                [alertView show];
            }
        }
    }
}



@end
