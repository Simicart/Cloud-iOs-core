//
//  LoyaltyCardViewController.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 1/22/15.
//  Copyright (c) 2015 Magestore. All rights reserved.
//

#import <PassKit/PassKit.h>
#import <SimiCartBundle/UIImageView+WebCache.h>

#import "LoyaltyCardViewController.h"

@interface LoyaltyCardViewController ()

@end

@implementation LoyaltyCardViewController
@synthesize model = _model;

- (void)viewDidLoadBefore
{
    [self setToSimiView];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewDidLoadBefore];
    }else
        [self configureNavigationBarOnViewDidLoad];
    self.title = SCLocalizedString(@"Rewards Card");
    // Show Rewards Card
    UIView *passbook = [[UIView alloc] initWithFrame:CGRectMake(10, 85, 300, 190)];
    passbook.backgroundColor = [[SimiGlobalVar sharedInstance] colorWithHexString:[@"#" stringByAppendingString:[_model objectForKey:@"passbook_background"]]];
    [passbook.layer setCornerRadius:10.0f];
    [passbook.layer setMasksToBounds:YES];
    passbook.tag = 100;
    [self.view addSubview:passbook];
    
    // Logo, Name, Balance
    UIColor *foreground = [[SimiGlobalVar sharedInstance] colorWithHexString:[@"#" stringByAppendingString:[_model objectForKey:@"passbook_foreground"]]];
    UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 44, 44)];
    [logo sd_setImageWithURL:[NSURL URLWithString:[_model objectForKey:@"passbook_logo"]] placeholderImage:nil options:SDWebImageRetryFailed];
    logo.contentMode = UIViewContentModeScaleAspectFit;
    [passbook addSubview:logo];
    
    UILabel *logoText = [[UILabel alloc] initWithFrame:CGRectMake(65, 10, 145, 44)];
    logoText.backgroundColor = [UIColor clearColor];
    logoText.textColor = foreground;
    logoText.font = [UIFont boldSystemFontOfSize:18];
    logoText.adjustsFontSizeToFitWidth = YES;
    logoText.minimumScaleFactor = 0.7f;
    logoText.text = [_model objectForKey:@"passbook_text"];
    [passbook addSubview:logoText];
    
    UILabel *balanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(190, 12, 95, 12)];
    balanceLabel.backgroundColor = [UIColor clearColor];
    balanceLabel.font = [UIFont systemFontOfSize:12];
    balanceLabel.text = SCLocalizedString(@"BALANCE");
    balanceLabel.textColor = [UIColor darkGrayColor];
    balanceLabel.textAlignment = NSTextAlignmentRight;
    [passbook addSubview:balanceLabel];
    
    UILabel *balanceValue = [[UILabel alloc] initWithFrame:CGRectMake(190, 25, 95, 20)];
    balanceValue.backgroundColor = [UIColor clearColor];
    balanceValue.font = [UIFont boldSystemFontOfSize:20];
    balanceValue.text = [_model objectForKey:@"loyalty_redeem"];
    balanceValue.textColor = foreground;
    balanceValue.textAlignment = NSTextAlignmentRight;
    balanceValue.adjustsFontSizeToFitWidth = YES;
    balanceValue.minimumScaleFactor = 0.7f;
    [passbook addSubview:balanceValue];
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 64, 300, 1)];
    separator.backgroundColor = [UIColor whiteColor];
    [passbook addSubview:separator];
    
    // Barcode
    UIView *barcode = [[UIView alloc] initWithFrame:CGRectMake(19, 80, 262, 95)];
    barcode.backgroundColor = [UIColor whiteColor];
    [barcode.layer setCornerRadius:5.0f];
    [barcode.layer setMasksToBounds:YES];
    [passbook addSubview:barcode];
    
    UIImageView *barcodeImg = [[UIImageView alloc] initWithFrame:CGRectMake(7, 10, 248, 60)];
    barcodeImg.contentMode = UIViewContentModeScaleAspectFit;
    [barcodeImg sd_setImageWithURL:[NSURL URLWithString:[self barcodeUrl]] placeholderImage:nil options:SDWebImageRetryFailed];
    [barcode addSubview:barcodeImg];
    
    UILabel *barcodeAlt = [[UILabel alloc] initWithFrame:CGRectMake(5, 80, 252, 15)];
    barcodeAlt.textAlignment = NSTextAlignmentCenter;
    barcodeAlt.font = [UIFont systemFontOfSize:14];
    barcodeAlt.text = [_model objectForKey:@"passbook_alt"];
    [barcode addSubview:barcodeAlt];
    
    // Passbook Button // Only Show for iPhone with passkit
    if ([PKPassLibrary isPassLibraryAvailable]) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(100, 290, 120, 40);
        [btn setImage:[UIImage imageNamed:@"add_to_passbook"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(showPassbook) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIView *passbook = [self.view viewWithTag:100];
        passbook.center = CGPointMake(self.view.center.x, 150);
    }else
        [super viewWillAppearBefore:YES];
}

- (NSString *)barcodeUrl
{
    return [NSString stringWithFormat:@"%@loyalty/passes/barcode/code/%@", kBaseURL, [_model objectForKey:@"passbook_barcode"]];
}

- (void)showPassbook
{
    NSString *url = [NSString stringWithFormat:@"%@loyalty/passes/index", kBaseURL];
    [self startLoadingData];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *fileData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
        PKPass *pass = [[PKPass alloc] initWithData:fileData error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            PKAddPassesViewController *viewController = [[PKAddPassesViewController alloc] initWithPass:pass];
            if (viewController) {
                [self presentViewController:viewController animated:YES completion:nil];
            }
            [self stopLoadingData];
        });
    });
}

@end
