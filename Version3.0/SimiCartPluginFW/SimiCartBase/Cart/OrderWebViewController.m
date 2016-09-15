//
//  OrderWebViewController.m
//  SimiCartPluginFW
//
//  Created by Axe on 10/13/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import "OrderWebViewController.h"
#import "SCNavigationBarPhone.h"
#import "SCThemeWorker.h"

@interface OrderWebViewController ()

@end

@implementation OrderWebViewController
@synthesize mainWebView;

- (void)viewDidLoad {
    [super viewDidLoad];
    mainWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:mainWebView];
    mainWebView.delegate = self;
    NSURL* url = [NSURL URLWithString:self.stringURL];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [mainWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewWillAppearBefore:(BOOL)animated{
}

#pragma mark webview delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [self startLoadingData];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self stopLoadingData];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{

}


-(void) viewWillDisappear:(BOOL)animated {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
    [[[SCThemeWorker sharedInstance] navigationBarPhone].cartBadge setBadgeValue:@""];
        [[[SCThemeWorker sharedInstance] navigationBarPhone].cartViewController getCart];
    }else{
        [[[SCThemeWorker sharedInstance] navigationBarPad].cartBadge setBadgeValue:@""];
        [[[SCThemeWorker sharedInstance] navigationBarPad].cartViewController getCart];
    }
    [self.navigationController popToRootViewControllerAnimated:NO];
}
#pragma mark Get Cart Data
//- (void)getCart{
//    if (![SimiGlobalVar sharedInstance].isGettingCart) {
//        [SimiGlobalVar sharedInstance].isGettingCart = YES;
//        SimiCartModel *cart = [[SimiGlobalVar sharedInstance] cart];
//        if (cart == nil) {
//            cart = [SimiCartModel new];
//        }
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetCart:) name:DidGetCart object:cart];
//        [self startLoadingData];
//        [cart getCartItemsWithParams:nil cartId:@"566ab811e2bc7378687b23d3"];
//    }
//}

@end
