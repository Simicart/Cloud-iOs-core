//
//  SimiViewController.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/10/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiViewController.h"
#import "SimiGlobalVar.h"
#import "SDWebImageManager.h"
#import "SCThemeWorker.h"

static NSString *dimView = @"DIMVIEW";
static int tagViewFog = 123456;
@interface SimiViewController ()

@end

@implementation SimiViewController

@synthesize simiLoading, isInPopover;

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
    [self configureLogo];
    [self configureNavigationBarOnViewDidLoad];
}

- (void)viewDidLoad{
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.view setBackgroundColor:THEME_APP_BACKGROUND_COLOR];
    self.preferredContentSize = CGSizeMake(SCREEN_WIDTH*2/3, SCREEN_HEIGHT*2/3);
    [self viewDidLoadBefore];
    [super viewDidLoad];
    [self viewDidLoadAfter];
    Class eventClass = self.class;
    while ([eventClass isSubclassOfClass:[SimiViewController class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@ViewDidLoad", NSStringFromClass(eventClass)] object:self];
        if (SIMI_DEBUG_ENABLE) {
            NSLog(@"%@ViewDidLoad", NSStringFromClass(eventClass));
        }
        eventClass = [eventClass superclass];
    }
    if (SIMI_SYSTEM_IOS >= 7.0) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
    }
}

- (void)viewDidLoadAfter
{
    
}

- (void)setToSimiView{
    self.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    [self configureNavigationBarOnViewWillAppear];
}

- (void)viewWillAppear:(BOOL)animated{
    // Dispatch Event for Appear
    Class eventClass = self.class;
    while ([eventClass isSubclassOfClass:[SimiViewController class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@ViewWillAppear", NSStringFromClass(eventClass)] object:self];
        if (SIMI_DEBUG_ENABLE) {
            NSLog(@"%@ViewWillAppear", NSStringFromClass(eventClass));
        }
        eventClass = [eventClass superclass];
    }
    _isPresented = self.isBeingPresented;
    _didAppear = YES;
    [self viewWillAppearBefore:animated];
    [super viewWillAppear:animated];
    [self viewWillAppearAfter:animated];
}

- (void)viewWillAppearAfter:(BOOL)animated
{
    
}
- (void)viewDidAppearBefore:(BOOL)animated
{
    
}
- (void)viewDidAppear:(BOOL)animated
{
    Class eventClass = self.class;
    while ([eventClass isSubclassOfClass:[SimiViewController class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@ViewDidAppear", NSStringFromClass(eventClass)] object:self];
        if (SIMI_DEBUG_ENABLE) {
            NSLog(@"%@ViewDidAppear", NSStringFromClass(eventClass));
        }
        eventClass = [eventClass superclass];
    }
    _isPresented = self.isBeingPresented;
    [self viewDidAppearBefore:animated];
    [super viewWillAppear:animated];
    [self viewDidAppearAfter:animated];
}

- (void)viewDidAppearAfter:(BOOL)animated
{
    
}

- (void)viewWillDisappearBefore:(BOOL)animated
{
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Dispatch Event for Appear
    Class eventClass = self.class;
    while ([eventClass isSubclassOfClass:[SimiViewController class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@ViewWillDisappear", NSStringFromClass(eventClass)] object:self];
        if (SIMI_DEBUG_ENABLE) {
            NSLog(@"%@ViewWillDisappear", NSStringFromClass(eventClass));
        }
        eventClass = [eventClass superclass];
    }
    [self viewWillDisappearBefore:animated];
    [super viewWillDisappear:animated];
    [self viewWillDisappearAfter:animated];
}

- (void)viewWillDisappearAfter:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"%@ did receive memory warning", self);
}

- (void)startLoadingData{
    if (!simiLoading.isAnimating) {
        CGRect frame = self.view.frame;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && self.navigationController) {
            if (frame.size.width > self.navigationController.view.frame.size.width) {
                frame = self.navigationController.view.frame;
            }
        }
        
        simiLoading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        simiLoading.hidesWhenStopped = YES;
        simiLoading.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        [self.view addSubview:simiLoading];
        self.view.userInteractionEnabled = NO;
        [simiLoading startAnimating];
        if (_didAppear) {
            self.view.alpha = 0.5;
        }
    }
}

- (void)stopLoadingData{
    self.view.userInteractionEnabled = YES;
    self.view.alpha = 1;
    [simiLoading stopAnimating];
    [simiLoading removeFromSuperview];
}

- (void)didReceiveNotification:(NSNotification *)noti{
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
};

- (void)goBackPreviousControllerAnimated:(BOOL)animated{
    if (_isPresented || isInPopover) {
        if (_isPresented) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            [_popover dismissPopoverAnimated:YES];
        }
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (NSString *)formatTitleString:(NSString *)title
{
    SimiTheme *theme = [SimiTheme singleton];
    if([theme respondsToSelector:@selector(formatTitleString:)]){
        return [theme formatTitleString:title];
    }
    return title;
}

#pragma mark Configure NavigationBar
- (void)configureNavigationBarOnViewDidLoad
{
    if (SIMI_SYSTEM_IOS >= 7.0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.edgesForExtendedLayout = UIRectEdgeBottom;
        self.navigationController.navigationBar.barTintColor = THEME_COLOR;
    }
    self.navigationItem.leftItemsSupplementBackButton = YES;
    self.hidesBottomBarWhenPushed = YES;
    [self.tabBarController.tabBar setHidden:YES];
}

- (void)configureNavigationBarOnViewWillAppear
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.navigationItem.leftBarButtonItems = [[[SCThemeWorker sharedInstance]navigationBarPhone]leftButtonItems];
        self.navigationItem.rightBarButtonItems = [[[SCThemeWorker sharedInstance]navigationBarPhone]rightButtonItems];
    }else
    {
        self.navigationItem.leftBarButtonItems = [[[SCThemeWorker sharedInstance]navigationBarPad]leftButtonItems];
        self.navigationItem.rightBarButtonItems = [[[SCThemeWorker sharedInstance]navigationBarPad]rightButtonItems];
    }
}

- (void)configureLogo
{
    UIImageView *imageViewLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 240, 44)];
    imageViewLogo.image = [UIImage imageNamed:@"logo"];
    imageViewLogo.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = imageViewLogo;
}

#pragma mark Reload Right Bar Items
- (void)reloadRightBarItemsPad
{
    self.navigationItem.rightBarButtonItems = nil;
    self.navigationItem.rightBarButtonItems = [[[SCThemeWorker sharedInstance]navigationBarPad] rightButtonItems];
    if ([[[SCThemeWorker sharedInstance]navigationBarPad] isShowSearchBar]) {
        self.navigationItem.leftItemsSupplementBackButton = NO;
        self.navigationItem.hidesBackButton = YES;
        [[[[SCThemeWorker sharedInstance]navigationBarPad] searchBar] becomeFirstResponder];
    }else
    {
        self.navigationItem.leftItemsSupplementBackButton = YES;
        self.navigationItem.hidesBackButton = NO;
    }
}

#pragma mark Image Fog
- (void)hiddenScreenWhenShowPopOver
{
    UIImageView *imageFogView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [imageFogView setBackgroundColor:[UIColor whiteColor]];
    [imageFogView setAlpha:0.5];
    imageFogView.tag = tagViewFog;
    [self.view addSubview:imageFogView];
}

- (void)showScreenWhenHiddenPopOver
{
    for (UIView *imageFogView in self.view.subviews) {
        if (imageFogView.tag == tagViewFog) {
            [imageFogView removeFromSuperview];
        }
    }
}
- (void)showAlertContactSimiCartWithMessage:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"") message:SCLocalizedString(message) delegate:self cancelButtonTitle:SCLocalizedString(@"Close") otherButtonTitles:@"Contact Us",nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
            [self sendEmailToStoreWithEmail:@[@"support@simicart.com"] andEmailContent:@""];
            break;
        default:
            break;
    }
}

- (void)sendEmailToStoreWithEmail:(NSArray *)email andEmailContent:(NSString *)emailContent
{
    if([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setToRecipients:email];
        
        [controller setSubject:[NSString stringWithFormat:@""]];
        [controller setMessageBody:emailContent isHTML:NO];
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [self presentViewController:controller animated:YES completion:NULL];
        }
        else {
            [self presentViewController:controller animated:YES completion:NULL];
        }
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"You haven’t setup email account") message:SCLocalizedString(@"You must go to Settings/ Mail, Contact, Calendars and choose Add Account.")
                                                       delegate:self cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    
    if(result==MFMailComposeResultCancelled)
    {
        [controller dismissViewControllerAnimated:YES completion:NULL];
    }
    if(result==MFMailComposeResultSent)
    {  UIAlertView *sent=[[UIAlertView alloc]initWithTitle:SCLocalizedString(@"Your Email was sent succesfully.") message:nil delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles:nil];
        [sent show];
        [controller dismissViewControllerAnimated:YES completion:NULL];
    }
    if(result==MFMailComposeResultFailed)
    {UIAlertView *sent=[[UIAlertView alloc]initWithTitle:SCLocalizedString(@"Failed") message:SCLocalizedString(@"Your mail was not sent") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles:nil];
        [sent show];
        
        [controller dismissViewControllerAnimated:YES completion:NULL];
        
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
