//
//  OrderWebViewController.h
//  SimiCartPluginFW
//
//  Created by Axe on 10/13/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import "SimiCartBundle.h"

@interface OrderWebViewController : SimiViewController<UIWebViewDelegate>

@property (strong, nonatomic) UIWebView* mainWebView;
@property (strong, nonatomic) NSString* stringURL;
@end
