//
//  FacebookConnect.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 6/7/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "FacebookConnect.h"

@implementation FacebookConnect
{
    MoreActionView* moreActionView;
    float widthFacebookView;
    UILabel* lblLikeCount;
    UIImageView* imgLikeCount;
    BOOL isProductMoreView;
    UIView *commentView;
    FBSDKLikeControl* fbLikeControl;
}
@synthesize btnComment, btnShare, btnClearAllFacebookCookies;
@synthesize isShowFacebookView, isHideTabBar, isShowComment;
@synthesize tagFacebookView, section, productModel, productMoreVC;
@synthesize stringFacebookAppID, stringHtml;
@synthesize tagView, facebookView, fbLikeButton, webComment, activityView;
@synthesize buttonFacebook;

- (instancetype)initWithObject:(id)object
{
    self = [super init];
    if (self) {
#pragma mark Event For Core & Matrix Theme
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationDidBecomeActive" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationWillTerminate" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SimiFaceBookWorker_StartLoginWithFaceBook" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCProductMoreViewController_InitViewMoreAction" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCProductMoreViewControllerViewWillAppear" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCProductMoreViewControllerViewWillDisappear" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationDidBecomeActive" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCProductMoreViewController-BeforeTouchMoreAction" object:nil];
        stringFacebookAppID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"FacebookAppID"];

    }
    return self;
}


#pragma mark Notification Facebook for Core & Matrix Theme
- (void)didReceiveNotification:(NSNotification *)noti
{
    float sizeButton = 50;
    if([noti.name isEqualToString:@"SCProductMoreViewController_InitViewMoreAction"])
    {
        moreActionView = noti.object;
        if(!buttonFacebook ){
            buttonFacebook = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, sizeButton, sizeButton)];
            [buttonFacebook setImage:[UIImage imageNamed:@"facebookconnect_ic_detail"] forState:UIControlStateNormal];
            [buttonFacebook setImageEdgeInsets:UIEdgeInsetsMake(9, 9, 9, 9)];
            [buttonFacebook.layer setCornerRadius:sizeButton/2.0f];
            [buttonFacebook.layer setShadowOffset:CGSizeMake(1, 1)];
            [buttonFacebook.layer setShadowRadius:2];
            buttonFacebook.layer.shadowOpacity = 0.5;
            [buttonFacebook setBackgroundColor:[UIColor whiteColor]];
            [buttonFacebook addTarget:self action:@selector(didTouchFacebook) forControlEvents:UIControlEventTouchUpInside];
            moreActionView.numberIcon += 1;
            [moreActionView.arrayIcon addObject:buttonFacebook];
        }
        [self removeObserverForNotification:noti];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCProductMoreViewController-AfterInitViewMore" object:nil];
    }
    else if([noti.name isEqualToString:@"SCProductMoreViewController-AfterInitViewMore"])
    {
        [self removeObserverForNotification:noti];
        productModel = [noti.userInfo valueForKey:@"productModel"];
        [productModel setValue:@"https://simicart.com" forKey:@"product_url"];
        productMoreVC = [noti.userInfo valueForKey:@"controller"];
        
        float sizeLikeView = 68;
        UIView *facebookLikeView = [[UIView alloc] initWithFrame:CGRectMake([SimiGlobalVar scaleValue:5], -5, sizeLikeView, sizeLikeView)];
        
        UIImageView* iMoreView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_bg_more"]];
        iMoreView.frame = CGRectMake(0, 0, sizeLikeView, sizeLikeView);
        iMoreView.contentMode = UIViewContentModeScaleAspectFit;
        
        if (fbLikeControl == nil) {
            fbLikeControl = [[FBSDKLikeControl alloc]initWithFrame:CGRectMake(0,sizeLikeView/5,sizeLikeView, sizeLikeView)];
            fbLikeControl.transform = CGAffineTransformMakeScale(0.7, 0.7);
            fbLikeControl.likeControlStyle = FBSDKLikeControlStyleBoxCount;
        }
        fbLikeControl.objectID = @"https://simicart.com";
        
        /*
        if (fbLikeButton == nil) {
            fbLikeButton = [[FBSDKLikeButton alloc]initWithFrame:CGRectMake(sizeLikeView/6, sizeLikeView/4 + 3,2*sizeLikeView/3, sizeLikeView/4)];
        }
 
        fbLikeButton.titleLabel.font = [UIFont fontWithName:THEME_FONT_NAME_REGULAR size:10];
      
        fbLikeButton.objectID = [productModel valueForKey:@"product_url"];
        
        [fbLikeButton addTarget:self action:@selector(didClickLikeButton) forControlEvents:UIControlEventTouchUpInside];
        lblLikeCount = [[UILabel alloc]initWithFrame:CGRectMake(sizeLikeView/4, sizeLikeView/2 + 3,sizeLikeView/2, sizeLikeView/3)];
        lblLikeCount.font = [UIFont fontWithName:THEME_FONT_NAME size:10];
        lblLikeCount.textColor = [UIColor grayColor];
        lblLikeCount.textAlignment = NSTextAlignmentCenter;
        
        imgLikeCount = [[UIImageView alloc] initWithFrame:CGRectMake(sizeLikeView/4, sizeLikeView/2 ,sizeLikeView/2, sizeLikeView/3)];
        imgLikeCount.image = [UIImage imageNamed:@"like_box"];
        imgLikeCount.contentMode = UIViewContentModeScaleToFill;
        [facebookLikeView addSubview:fbLikeButton];
        [facebookLikeView addSubview:imgLikeCount];
        [facebookLikeView addSubview:lblLikeCount];
        */
        [facebookLikeView addSubview:iMoreView];
        [facebookLikeView addSubview:fbLikeControl];
        [facebookLikeView setBackgroundColor:[UIColor clearColor]];
        btnComment = [[UIButton alloc]initWithFrame:CGRectMake([SimiGlobalVar scaleValue:92], 5, sizeButton, sizeButton)];
        [btnComment setImage:[UIImage imageNamed:@"facebookconnect_comment"] forState:UIControlStateNormal];
        
        [btnComment setImageEdgeInsets:UIEdgeInsetsMake(9, 9, 9, 9)];
        [btnComment.layer setCornerRadius:sizeButton/2.0f];
        [btnComment.layer setShadowOffset:CGSizeMake(1, 1)];
        [btnComment.layer setShadowRadius:2];
        btnComment.layer.shadowOpacity = 0.5;
        [btnComment setBackgroundColor:[UIColor whiteColor]];
        [btnComment addTarget:self action:@selector(didClickCommentButton) forControlEvents:UIControlEventTouchUpInside];
        
        btnShare = [[UIButton alloc]initWithFrame:CGRectMake([SimiGlobalVar scaleValue:170], 5, sizeButton, sizeButton)];
        [btnShare setImage:[UIImage imageNamed:@"facebookconnect_share"] forState:UIControlStateNormal];
        [btnShare setImageEdgeInsets:UIEdgeInsetsMake(9, 9, 9, 9)];
        [btnShare.layer setCornerRadius:sizeButton/2.0f];
        [btnShare.layer setShadowOffset:CGSizeMake(1, 1)];
        [btnShare.layer setShadowRadius:2];
        btnShare.layer.shadowOpacity = 0.5;
        [btnShare setBackgroundColor:[UIColor whiteColor]];
        [btnShare addTarget:self action:@selector(didClickShareButton) forControlEvents:UIControlEventTouchUpInside];
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            widthFacebookView = SCREEN_WIDTH - buttonFacebook.frame.size.width - 30;
        else
            widthFacebookView = 250;
        
        facebookView = [UIView new];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            facebookView.frame =  CGRectMake(SCREEN_WIDTH - buttonFacebook.frame.size.width - 15, moreActionView.frame.origin.y - moreActionView.heightMoreView + buttonFacebook.frame.origin.y -5, 0, buttonFacebook.frame.size.height+10);
        else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            facebookView.frame =  CGRectMake(SCREEN_WIDTH - buttonFacebook.frame.size.width - 350, moreActionView.frame.origin.y - moreActionView.heightMoreView + buttonFacebook.frame.origin.y -5, 0, buttonFacebook.frame.size.height+10);
        [facebookView addSubview:facebookLikeView];
        [facebookView addSubview:btnComment];
        [facebookView addSubview:btnShare];
        
        [productMoreVC.view addSubview:facebookView];
        facebookView.clipsToBounds = YES;
//        [self updateLikeLabel];
        [productMoreVC.view addSubview:facebookView];
    }
    else if([noti.name isEqualToString:@"SCProductMoreViewController-BeforeTouchMoreAction"]){
        if(moreActionView.isShowViewMoreAction && isShowFacebookView){
            CGRect frame = facebookView.frame;
            frame.origin.x += widthFacebookView;
            frame.size.width = 0;
            [UIView animateWithDuration:0.15f animations:^{
                [facebookView setFrame:frame];
                [buttonFacebook setTransform:CGAffineTransformMakeRotation(0)];
            } completion:^(BOOL finished) {
                
            }];
            isShowFacebookView = !isShowFacebookView;
        }
    }
    else if([noti.name isEqualToString:@"SCProductViewControllerPad-AfterConfigAddToCartButton"])
    {
        
    }else if ([noti.name isEqualToString:@"ApplicationWillTerminate"])
    {
        NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray* facebookCookies = [cookies cookiesForURL:
                                    [NSURL URLWithString:@"https://facebook.com"]];
        for (NSHTTPCookie* cookie in facebookCookies) {
            [cookies deleteCookie:cookie];
        }
    }else if([noti.name isEqualToString:@"SimiFaceBookWorker_StartLoginWithFaceBook"])
    {
//        isLoginWithComment = NO;
//        [btnCommentWithOtherAccount setHidden:YES];
    }else if([noti.name isEqualToString:@"SCProductMoreViewControllerViewWillAppear"]){
        isProductMoreView = YES;
    }else if([noti.name isEqualToString:@"SCProductMoreViewControllerViewWillDisappear"]){
        isProductMoreView = NO;
    }else if([noti.name isEqualToString:@"ApplicationDidBecomeActive"]){
        if(isProductMoreView){
//            [self updateLikeLabel];
        }
    }
}



- (void)didClickShareButton
{
    if([productModel valueForKey:@"product_url"]){
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        if ([productModel valueForKey:@"product_url"]) {
            content.contentURL = [NSURL URLWithString:[productModel valueForKey:@"product_url"]];
        }
        if ([productModel valueForKey:@"product_name"]) {
            content.contentTitle = [NSString stringWithFormat:@"%@",[productModel valueForKey:@"product_name"]];
        }
        NSMutableArray *arrayImage = (NSMutableArray *)[productModel valueForKey:@"product_images"];
        if (arrayImage.count > 0) {
            content.imageURL = [NSURL URLWithString:[arrayImage objectAtIndex:0]];
        }
        if ([productModel valueForKey:@"product_short_description"] && ![[productModel valueForKey:@"product_short_description"] isEqualToString:@""]) {
            content.contentDescription = [NSString stringWithFormat:@"%@",[productModel valueForKey:@"product_short_description"]];
        }
        
        [FBSDKShareDialog showFromViewController:productMoreVC
                                     withContent:content
                                            delegate:nil];
    }
}

- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

- (void)didClickCommentButton
{
    if([productModel valueForKey:@"product_url"]){
        isShowComment = YES;
        commentView = [[UIView alloc]init];
        commentView.tag = tagView;
        UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            commentView.frame = [UIScreen mainScreen].bounds;
        }else
        {
            commentView.frame = currentVC.view.bounds;
        }
        [commentView setBackgroundColor:[UIColor clearColor]];
        UIImageView *imgBackground = [[UIImageView alloc]initWithFrame:commentView.bounds];
        [imgBackground setBackgroundColor:[UIColor blackColor]];
        [imgBackground setAlpha:0.5];
        imgBackground.userInteractionEnabled = YES;
        [commentView addSubview:imgBackground];
        
        CGRect frame = commentView.bounds;
        frame.origin.x += 10;
        frame.origin.y += 20;
        frame.size.width -= 20;
        frame.size.height -= 30;
        UIView *viewContent = [[UIView alloc]initWithFrame:frame];
        [viewContent setBackgroundColor:[UIColor whiteColor]];
        [viewContent.layer setCornerRadius:10.0f];
        [viewContent.layer setMasksToBounds:YES];
        [commentView addSubview:viewContent];
        
        btnClearAllFacebookCookies = [[UIButton alloc]initWithFrame:CGRectMake(20, 25, frame.size.width - 60, 35)];
        [btnClearAllFacebookCookies setTitle:@"Logout your facebook account" forState:UIControlStateNormal];
        [btnClearAllFacebookCookies setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnClearAllFacebookCookies setBackgroundColor:[UIColor colorWithRed:70.0/255 green:98.0/255 blue:158.0/255 alpha:1.0]];
        [btnClearAllFacebookCookies.layer setCornerRadius:5.0f];
        [btnClearAllFacebookCookies.layer setMasksToBounds:YES];
        [btnClearAllFacebookCookies addTarget:self action:@selector(didClearAllFacebookCookies) forControlEvents:UIControlEventTouchUpInside];
        [btnClearAllFacebookCookies.titleLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
        [commentView addSubview:btnClearAllFacebookCookies];
        
        
        UIButton *btnClose = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width - 40, 20, 50, 50)];
        [btnClose setImage:[UIImage imageNamed:@"facebookconnect_close"] forState:UIControlStateNormal];
        [btnClose setImageEdgeInsets:UIEdgeInsetsMake(10, 26, 26, 10)];
        [btnClose setBackgroundColor:[UIColor clearColor]];
        [btnClose addTarget:self action:@selector(didClickClose) forControlEvents:UIControlEventTouchUpInside];
        [commentView addSubview:btnClose];
        
        CGRect frameWebView = frame;
        frameWebView.origin.y += 50;
        frameWebView.size.height -= 60;
        webComment = [[UIWebView alloc]initWithFrame:frameWebView];
        webComment.delegate = self;
        stringHtml = @"\
        <!DOCTYPE html>\
        <html xmlns:fb='http://ogp.me/ns/fb#'>\
        <head>\
        <meta name='viewport' content='width=%f, initial-scale=1.0'>\
        </head>\
        <body high=100%>\
        <div id='fb-root'></div>\
        <script>\
        window.fbAsyncInit = function() {\
        FB.init({\
        appId      : '%@',\
        cookie     : true,\
        status     : true,\
        xfbml      : true\
        });\
        FB.Event.subscribe('xfbml.render', function(response) {\
        FB.Canvas.setSize();\
        });\
        };\
        (function(d, s, id){\
        var js, fjs = d.getElementsByTagName(s)[0];\
        if (d.getElementById(id)) {return;}\
        js = d.createElement(s); js.id = id;\
        js.src = 'http://connect.facebook.net/en_US/all.js';\
        fjs.parentNode.insertBefore(js, fjs);\
        }(document, 'script', 'facebook-jssdk'));\
        </script>\
        <div class='fb-comments' data-href='%@' data-numposts='5' data-colorscheme='light'></div>\
        </body>\
        </html>\
        <style type=\"text/css\">\
        .fb_hide_iframes iframe {\
        left: 0;\
        top:0;\
        right:0;\
        bottom:0;\
        }\
        </style>\
        ";
        stringHtml = [NSString stringWithFormat:stringHtml,frameWebView.size.width,stringFacebookAppID,[productModel valueForKey:@"product_url"] ];
        [webComment loadHTMLString:stringHtml baseURL:[NSURL URLWithString:[productModel valueForKey:@"product_url"]]];
        
        [commentView addSubview:webComment];
        
        activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityView.frame = webComment.frame;
        activityView.hidesWhenStopped = YES;
        [commentView addSubview:activityView];
        [activityView startAnimating];
        
        webComment.alpha = 1.0;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
            if (currentVC.tabBarController.tabBar.isHidden) {
                isHideTabBar = YES;
            }
            currentVC.tabBarController.tabBar.hidden = YES;
            [currentVC.view addSubview:commentView];
        }else
        {    UIWindow *currentVC = [[UIApplication sharedApplication] keyWindow];
            [currentVC addSubview:commentView];
        }
    }
}

-(void) webViewLoadComment{
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *stringURL = [NSString stringWithFormat:@"%@",request.URL];
    if ([stringURL containsString:@"facebook.com/plugins/comments.php?api_key"]) {
        [activityView stopAnimating];
        [activityView removeFromSuperview];
    }else if([stringURL containsString:@"facebook.com/plugins/close_popup.php"]){
        [webComment loadHTMLString:stringHtml baseURL:[NSURL URLWithString:[productModel valueForKey:@"product_url"]]];
    }else if([stringURL containsString:[productModel valueForKey:@"product_url"]]){
        NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray *allCookies = [cookies cookies];
        btnClearAllFacebookCookies.hidden = YES;
        for(NSHTTPCookie *cookie in allCookies) {
            if([[cookie domain] rangeOfString:@"facebook.com"].location != NSNotFound) {
                btnClearAllFacebookCookies.hidden = NO;
                return YES;
            }
        }
    }
    return YES;
}



- (void)didClearAllFacebookCookies
{
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    NSArray *allCookies = [cookies cookies];
    
    for(NSHTTPCookie *cookie in allCookies) {
        NSLog(@"%@",cookie);
        if([[cookie domain] rangeOfString:@"facebook.com"].location != NSNotFound) {
            [cookies deleteCookie:cookie];
        }
    }

    [webComment loadHTMLString:stringHtml baseURL:[NSURL URLWithString:[productModel valueForKey:@"product_url"]]];
}

-(void)didClickClose
{
    UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[currentVC.view.subviews lastObject] removeFromSuperview];
        if (!isHideTabBar) {
            currentVC.tabBarController.tabBar.hidden = YES;
        }
    }else
    {
//        [[currentVC.view.subviews lastObject] removeFromSuperview];
        [commentView removeFromSuperview];
    }
}

-(void) didTouchFacebook{
 
    if (!isShowFacebookView) {
        CGRect frame = facebookView.frame;
        frame.origin.x -= widthFacebookView;
        frame.size.width = widthFacebookView;
        [UIView animateWithDuration:0.15f animations:^{
            [facebookView setFrame:frame];
            [buttonFacebook setTransform:CGAffineTransformMakeRotation(M_PI_4)];
        } completion:^(BOOL finished) {
            
        }];
    }else
    {
        CGRect frame = facebookView.frame;
        frame.origin.x += widthFacebookView;
        frame.size.width = 0;
        [UIView animateWithDuration:0.15f animations:^{
            [facebookView setFrame:frame];
            [buttonFacebook setTransform:CGAffineTransformMakeRotation(0)];
        } completion:^(BOOL finished) {
            
        }];
    }
    
    isShowFacebookView = !isShowFacebookView;
}

/*
-(void) updateLikeLabel{
    if([productModel valueForKey:@"product_url"]){
        [productMoreVC startLoadingData];
        NSString* productURL = [NSString stringWithFormat:@"%@",[productModel valueForKey:@"product_url"]];
        NSString* requestURL = [NSString stringWithFormat:@"https://graph.facebook.com/fql?q=SELECT like_count FROM link_stat WHERE url = \"%@\"",productURL];
      
        NSURL* url = [NSURL URLWithString:[requestURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        NSURLResponse *response;
        NSError *error;
        //send it synchronous
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if(!error && responseData){
            NSDictionary* data = [NSJSONSerialization JSONObjectWithData:responseData
                                                                 options:kNilOptions
                                                                   error:&error];
            if(((NSDictionary*)[data objectForKey:@"data"]).count>0 && [[[data objectForKey:@"data"] objectAtIndex:0] objectForKey:@"like_count"]){
                lblLikeCount.text = [NSString stringWithFormat:@"%@", [[[data objectForKey:@"data"] objectAtIndex:0] objectForKey:@"like_count"]];
            }
        }
        [productMoreVC stopLoadingData];
    }
    
}

-(void) didClickLikeButton{
    
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(updateLikeLabel) userInfo:nil repeats:NO];
    [productMoreVC startLoadingData];
   
}
 */
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
