//
//  SCTermConditionViewController.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 7/10/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SCTermConditionViewController.h"

@interface SCTermConditionViewController ()

@end

@implementation SCTermConditionViewController
@synthesize termAndCondition;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoadAfter
{
    [super viewDidLoadAfter];
    // Do any additional setup after loading the view.
    self.title = [termAndCondition objectForKey:@"name"];
    
    // Term and condition view
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [webView loadHTMLString:[termAndCondition objectForKey:@"content"] baseURL:nil];
    [self.view addSubview:webView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
