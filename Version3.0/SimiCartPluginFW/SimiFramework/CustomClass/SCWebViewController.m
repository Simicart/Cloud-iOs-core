//
//  SCWebViewController.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/3/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SCWebViewController.h"

@interface SCWebViewController ()

@end

@implementation SCWebViewController

@synthesize webTitle, urlPath, content;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoadBefore
{
    [self setToSimiView];
    [super viewDidLoadBefore];
    _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    _webView.scalesPageToFit = YES;
    _webView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_webView];
    
    if (!content) {
        _webView.delegate = self;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
        [request addValue:@"YES" forHTTPHeaderField:@"Mobile-App"];
        [_webView loadRequest:request];
    }else{
        NSString *htmlString =[NSString stringWithFormat:@"<style type=\"text/css\">*{font-family: %@; font-size: %i !important;}</style>%@", @"ProximaNova-Light",20,content];
        [_webView loadHTMLString:htmlString baseURL:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setPreferredContentSize:CGSizeMake(3*SCREEN_WIDTH/4, 3*SCREEN_HEIGHT/4)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUrlPath:(NSString *)path{
    if (![urlPath isEqualToString:path]) {
        urlPath = [path copy];
        if (([urlPath rangeOfString:@"http://"].location == NSNotFound) && ([urlPath rangeOfString:@"https://"].location == NSNotFound)) {
            urlPath = [NSString stringWithFormat:@"http://%@", urlPath];
        }
        url = [NSURL URLWithString:urlPath];
    }
}

- (void)setWebTitle:(NSString *)title{
    if (![webTitle isEqualToString:title]) {
        webTitle = [title copy];
        self.title = webTitle;
    }
}

#pragma mark WebView Delegates
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [self startLoadingData];
    webView.hidden = YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self stopLoadingData];
    webView.hidden = NO;
    if (webTitle == nil || webTitle.length == 0) {
        [self setWebTitle:[webView stringByEvaluatingJavaScriptFromString:@"document.title"]];
    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:error.localizedDescription delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
    [alertView show];
    [self stopLoadingData];
    webView.hidden = NO;
}

@end
