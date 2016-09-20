//
//  SCPaypalExpressAddressEditViewController.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 12/22/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SCPaypalExpressAddressEditViewController.h"

@interface SCPaypalExpressAddressEditViewController ()

@end

@implementation SCPaypalExpressAddressEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewDidLoadBefore
{
    [super viewDidLoadBefore];
    UIBarButtonItem *button = [[UIBarButtonItem alloc]initWithTitle:SCLocalizedString(@"Save") style:UIBarButtonItemStyleDone target:self action:@selector(saveAddressPaypalRewrite)];
    self.navigationItem.rightBarButtonItem = button;
    
    //self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
}

// actually like the parrent but without the post data to server
- (void)saveAddressPaypalRewrite{
    if (self.isNewCustomer) {
        NSString *password = [self.form objectForKey:@"customer_password"];
        NSString *confirm  = [self.form objectForKey:@"confirm_password"];
        if (![password isEqualToString:confirm]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(@"Password and Confirm password don't match.") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
            [alertView show];
            return;
        }
    }
    // Valid Form
    if (![self.form isDataValid]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(@"Please select all (*) fields") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
        return;
    }
    [self.address removeAllObjects];
    [self.address addData:self.form];
    if ([self.form objectForKey:@"name"]) {
        [self.address setValue:[[self.form objectForKey:@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"name"];
    }
    [self.address saveToLocal];
    [self.delegate didSaveAddress:self.address];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
