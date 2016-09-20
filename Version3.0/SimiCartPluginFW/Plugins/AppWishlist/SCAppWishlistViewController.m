//
//  SCAppWishlistViewController.m
//  SimiCartPluginFW
//
//  Created by Cody Nguyen on 8/26/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SCAppWishlistViewController.h"
#import <SimiCartBundle/SCProductViewControllerPad.h>
#import <SimiCartBundle/MBProgressHUD.h>
#import <SimiCartBundle/SCThemeWorker.h>


static NSString *WISHLIST_COLLECTION_VIEW_CELL = @"WishlistCollectionViewCell";
static NSString *WISHLIST_DELETE_CONFIRMATION_ALERT = @"WishlistDeleteConfirmationAlert";

@interface SCAppWishlistViewController ()
{
    UIImageView *backGroundImageView;
}
@end

@implementation SCAppWishlistViewController

@synthesize wishlistModelCollection,wishlistCollectionView,header,emptyLabel;

- (void)viewDidLoadBefore
{
    [self configureLogo];
    [self configureNavigationBarOnViewDidLoad];
    [self setToSimiView];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    /*
    wishlistModelCollection = [SCAppWishlistModelCollection new];
    CGFloat headerHeight = 50;
    
    if (wishlistCollectionView == nil) {
        
        UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            flowLayout.itemSize = CGSizeMake(SCREEN_WIDTH, 150);
        else
            flowLayout.itemSize = CGSizeMake(SCREEN_WIDTH/2, 250);
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing =0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        wishlistCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height -64) collectionViewLayout:flowLayout];
        wishlistCollectionView.showsHorizontalScrollIndicator = NO;
        wishlistCollectionView.showsVerticalScrollIndicator = NO;
        [wishlistCollectionView setCollectionViewLayout:flowLayout animated:YES];
        [wishlistCollectionView setBackgroundColor:[UIColor clearColor]];
        [wishlistCollectionView setDelegate:self];
        [wishlistCollectionView setDataSource:self];
        [wishlistCollectionView setContentInset:UIEdgeInsetsMake(headerHeight, 0, 0, 0)];
        [self.view addSubview:wishlistCollectionView];
    }
    if (header ==nil) {
        header= [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, headerHeight)];
        [header setBackgroundColor:[[SimiGlobalVar sharedInstance] colorWithHexString:@"#eeeeee"]];
        [header setAlpha:0.95f];
        
        UILabel * shareWishlistLabel = [UILabel new];
        [shareWishlistLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
        shareWishlistLabel.text = SCLocalizedString(@"Share Wishlist");
        CGFloat textWidth = [[shareWishlistLabel text] sizeWithAttributes:@{NSFontAttributeName:[shareWishlistLabel font]}].width;
        [shareWishlistLabel setTextColor:[UIColor blackColor]];
        
        UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 60 - textWidth, 0, textWidth + 50, headerHeight)];
        [shareButton addTarget:self action:@selector(didTouchShareButton:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *shareIcon = [[UIImageView alloc]initWithFrame:CGRectMake(shareButton.frame.origin.x + 10, 15, 20, 20)];
        [shareIcon setImage:[UIImage imageNamed:@"ic_share"]];
        [shareWishlistLabel setFrame:CGRectMake(shareButton.frame.origin.x + 40, 10, textWidth, 30)];
        
        [header addSubview:shareWishlistLabel];
        [header addSubview:shareIcon];
        [header addSubview:shareButton];
        [self.view addSubview:header];
    }
    if (emptyLabel == nil) {
        emptyLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT/2 - 100, SCREEN_WIDTH, 30)];
        [emptyLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
        [emptyLabel setTextAlignment:NSTextAlignmentCenter];
        [emptyLabel setText:SCLocalizedString(@"Your Wishlist is empty")];
        [emptyLabel setHidden:YES];
        [self.view addSubview:emptyLabel];
    }
    
    [self getWishlist];
    */
}

-(void)viewWillAppear:(BOOL)animated
{
//    [super viewWillAppear:animated];
//    [self getWishlist];
}

- (void)viewDidAppearBefore:(BOOL)animated
{
    if (backGroundImageView == nil) {
        backGroundImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
        [backGroundImageView setImage:[UIImage imageNamed:@"demo_wishlist"]];
        [self.view addSubview:backGroundImageView];
    }
    [self showAlertContactSimiCartWithMessage:@"This feature can only be accessed with the fully synced version. Please contact SimiCart by email or chat with us"];
}

#pragma mark Get Wishlist
-(void)getWishlist
{
    [self startLoadingData];
    [wishlistModelCollection removeAllObjects];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetWishlist:) name:@"DidGetWishlist" object:nil];
    [wishlistModelCollection getWishlistProducts:0 limit:0 sortType:0 otherParams:nil];
}

-(void)didGetWishlist: (NSNotification *)noti
{
    [self stopLoadingData];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        if (wishlistModelCollection.count > 0) {
            self.sharingMessage =  [(NSDictionary *)[responder.other objectAtIndex:0] objectForKey:@"sharing_message"];
            self.sharingUrl =  [(NSDictionary *)[responder.other objectAtIndex:0] objectForKey:@"sharing_url"];
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.margin = 10.f;
            hud.yOffset = 150 - SCREEN_HEIGHT/2;
            hud.removeFromSuperViewOnHide = YES;
            [hud hide:YES afterDelay:1];
            
            [wishlistCollectionView reloadData];
            [header setHidden:NO];
            [emptyLabel setHidden:YES];
        }
        else
        {
            [header setHidden:YES];
            [emptyLabel setHidden:NO];
        }
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:responder.responseMessage delegate:self cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alert show];
    }
    [self removeObserverForNotification:noti];
}


#pragma mark UICollectionView DataSources
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return wishlistModelCollection.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView registerClass:[SCAppWishlistCollectionViewCell class] forCellWithReuseIdentifier:WISHLIST_COLLECTION_VIEW_CELL];
    SCAppWishlistCollectionViewCell *wishlistCell = [collectionView dequeueReusableCellWithReuseIdentifier:WISHLIST_COLLECTION_VIEW_CELL forIndexPath:indexPath];
    wishlistCell.layer.borderWidth = 0.5f;
    wishlistCell.layer.borderColor = [[SimiGlobalVar sharedInstance]colorWithHexString:@"#e8e8e8"].CGColor;
    wishlistCell.delegate = self;
    wishlistCell.product = [wishlistModelCollection objectAtIndex:indexPath.row];
    return wishlistCell;
}

#pragma mark Did Touch Share Button
-(void)didTouchShareButton:(id)sender
{
    [self shareWithText:self.sharingMessage andURL:self.sharingUrl andButton:sender];
}

#pragma mark Share Wishlist
- (void)shareWithText:(NSString *)sharingText andURL:(NSString *)url andButton:(UIButton *)button
{
    NSString *shareString = sharingText;
    NSURL *shareUrl = [NSURL URLWithString:url];
    shareString = [shareString stringByReplacingOccurrencesOfString:[shareUrl absoluteString] withString:@""];
    NSArray *activityItems = [NSArray arrayWithObjects:shareString, shareUrl, nil];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        [self presentViewController:activityViewController animated:YES completion:nil];
    else {
        UIPopoverController *popOver = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
        [popOver presentPopoverFromRect:CGRectMake(0, 0, 40, 40) inView:button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}


#pragma mark Remove From Wishlist
- (void)removeProductWithWishlistId: (NSString *)idOnWishlist
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @""
                          message: SCLocalizedString(@"Are you sure want to remove?")
                          delegate: self
                          cancelButtonTitle: SCLocalizedString(@"Cancel")
                          otherButtonTitles: SCLocalizedString(@"Yes"), nil];
    alert.simiObjectName = WISHLIST_DELETE_CONFIRMATION_ALERT;
    alert.simiObjectIdentifier = idOnWishlist;
    [alert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.simiObjectName isEqualToString:WISHLIST_DELETE_CONFIRMATION_ALERT]){
        switch (buttonIndex) {
            case 0:
            {
            }
                break;
            case 1:
            {
                NSString *idOnWishlist = (NSString *)alertView.simiObjectIdentifier;
                [self startLoadingData];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemoveProductFromWishlist:) name:@"DidRemoveProductFromWishlist" object:nil];
                [wishlistModelCollection removeAllObjects];
                [wishlistModelCollection removeProductFromWishlist:idOnWishlist otherParams:nil];
            }
                break;
        }
    }
}

-(void)didRemoveProductFromWishlist: (NSNotification *)noti
{
    [self stopLoadingData];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        [wishlistCollectionView reloadData];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:responder.responseMessage delegate:self cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alert show];
        [self getWishlist];
    }
    [self removeObserverForNotification:noti];
}

#pragma mark Add Wishlist Product To Cart
- (void)addProductToCartWithWishlistId: (NSString *)idOnWishlist
{
    [self startLoadingData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddWishlistProductToCart:) name:@"DidAddWishlistProductToCart" object:nil];
    [wishlistModelCollection removeAllObjects];
    [wishlistModelCollection addWishlistProductToCart:idOnWishlist otherParams:nil];
}

-(void)didAddWishlistProductToCart: (NSNotification *)noti
{
    [self stopLoadingData];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [[[[SCThemeWorker sharedInstance] navigationBarPad] cartViewControllerPad] getCart];
        else
            [[[[SCThemeWorker sharedInstance] navigationBarPhone] cartViewController] getCart];
        
        [wishlistCollectionView reloadData];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:responder.responseMessage delegate:self cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alert show];
        [self getWishlist];
    }
    [self removeObserverForNotification:noti];
}

#pragma mark OpenProductDetail
- (void)openProductViewWithId: (NSString *)productId
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        SCProductViewController *nextVC = [[SCProductViewController alloc]init];
        nextVC.productId = productId;
        [self.navigationController pushViewController:nextVC animated:YES];
    }
    else
    {
        SCProductViewControllerPad *nextVC = [[SCProductViewControllerPad alloc]init];
        nextVC.productId = productId;
        [self.navigationController pushViewController:nextVC animated:YES];
        
    }
}

#pragma mark Dealloc
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
