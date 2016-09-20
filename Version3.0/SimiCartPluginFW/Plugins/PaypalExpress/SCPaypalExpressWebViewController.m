//
//  SCPaypalExpressWebViewController.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 12/19/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SCPaypalExpressWebViewController.h"
#import "SCPaypalExpressModel.h"

#define TASK_BAR_HEIGH 0

@interface SCPaypalExpressWebViewController ()

@end

@implementation SCPaypalExpressWebViewController
{
    SCPaypalExpressModel * paypalModel;
}

@synthesize paypalExpCheckOutWebView
;


- (void)viewDidLoadAfter
{
    [super viewDidLoadAfter];
    [self paypalStart];
    self.reviewAddress = YES;
    
    self.title = SCLocalizedString(@"Paypal Checkout");
    [self.view setBackgroundColor:[UIColor whiteColor]];
    paypalExpCheckOutWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.view.frame.size.height - TASK_BAR_HEIGH)];
    paypalExpCheckOutWebView.delegate = self;
    [paypalExpCheckOutWebView setBackgroundColor:[UIColor whiteColor]];
    //Axe added 251215
    [paypalExpCheckOutWebView setContentMode:UIViewContentModeScaleAspectFill];
    paypalExpCheckOutWebView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin ;
    //
    [self.view addSubview:paypalExpCheckOutWebView];
    [self startLoadingData];
}

- (void)paypalStart
{
    if (paypalModel == nil) {
        paypalModel = [[SCPaypalExpressModel alloc] init];
    }
    [paypalModel startPaypalExpress];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStartPaypalExpress:) name:@"DidStartPaypalExpress" object:nil];
    
}

- (void)didStartPaypalExpress: (NSNotification *)noti
{
    [self removeObserverForNotification:noti];

    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        self.reviewAddress = [(NSNumber *)[paypalModel objectForKey:@"review_address"] boolValue];
        NSURL * url = [NSURL URLWithString:(NSString *)[paypalModel objectForKey:@"url"]];
        
        NSURLRequest * requestObj = [NSURLRequest requestWithURL:url];
        [paypalExpCheckOutWebView loadRequest:requestObj];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
        UIAlertView * warning = [[UIAlertView alloc]initWithTitle:@"" message:[responder responseMessage] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [warning show];
    }
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlRequest = request.URL.absoluteString;
    if ((!([urlRequest rangeOfString:@"return"].location == NSNotFound)) && ([urlRequest rangeOfString:@"stsRedirectUri"].location == NSNotFound)){
        [self.delgate completedWebviewCheckout:self.reviewAddress];
        return NO;
    }
    if (!([urlRequest rangeOfString:@"cancel"].location == NSNotFound)) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    return YES;
}



- (void)webViewDidFinishLoad:(UIWebView *)webView
{
   // NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
   // NSString *currentURL = paypalExpCheckOutWebView.request.URL.absoluteString;
    [self stopLoadingData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    paypalExpCheckOutWebView = nil;
    paypalModel = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"DidStartPaypalExpress" object:nil];
}


@end
