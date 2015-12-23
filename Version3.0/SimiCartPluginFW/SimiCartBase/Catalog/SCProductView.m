//
//  SCProductView.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/11/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SCProductView.h"

@implementation SCProductView
- (instancetype)initWithFrame:(CGRect)frame productID:(NSString *)productID_
{
    self = [super init];
    if (self) {
        [self setFrame:frame];
        [self setBackgroundColor:[UIColor clearColor]];
        beginTag = 100;
        self.productID = productID_;
        self.productModel = [SimiProductModel new];
        self.heightScrollView = CGRectGetHeight(self.frame);
        self.widthScrollView = CGRectGetWidth(self.frame);
        self.topMark = 0;
        self.bottomMark = 0;
        self.offsetZoomed = -1;
        activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicatorView.hidesWhenStopped = YES;
        [activityIndicatorView setFrame:self.bounds];
        [self addSubview:activityIndicatorView];
    }
    return self;
}

- (void)getProductDetail
{
    [activityIndicatorView startAnimating];
    self.isGotProduct = YES;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetProduct:) name:DidGetProductWithProductId object:self.productModel];
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [params setValue:[NSString stringWithFormat:@"%ld", (long)SCREEN_WIDTH *2] forKey:@"width"];
        [params setValue:[NSString stringWithFormat:@"%ld", ((long)SCREEN_HEIGHT - 64)*2] forKey:@"height"];
        [self.productModel getProductWithProductId:self.productID params:params];
    }else{
        [params setValue:[NSString stringWithFormat:@"%d", 624*2] forKey:@"width"];
        [params setValue:[NSString stringWithFormat:@"%d", 704*2] forKey:@"height"];
        [self.productModel getProductWithProductId:self.productID params:params];
    }
}

- (void)didGetProduct:(NSNotification*)noti
{
    [activityIndicatorView stopAnimating];
    [activityIndicatorView removeFromSuperview];
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([noti.name isEqualToString:DidGetProductWithProductId]) {
        if ([responder.status isEqualToString:@"SUCCESS"]) {
            self.isDidGetProduct = YES;
            self.productImages = (NSMutableArray *)[self.productModel valueForKey:@"images"];
            self.productID = [self.productModel valueForKey:@"_id"];
            self.numberImage = (int)[(NSArray *)[self.productModel valueForKey:@"images"] count];
            self.scrollViewProductImages = [[UIScrollView alloc]initWithFrame:self.bounds];
            [self.scrollViewProductImages setBackgroundColor:[UIColor clearColor]];
            self.scrollViewProductImages.tag = BIG_SCROLL_VIEW_TAG;
            self.scrollViewProductImages.delegate = self;
            self.scrollViewProductImages.showsVerticalScrollIndicator = NO;
            [self.scrollViewProductImages setContentSize:CGSizeMake(self.widthScrollView, self.heightScrollView*self.productImages.count)];
            for (int i = 0; i < self.productImages.count; i++) {
                UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, self.heightScrollView*i + self.topMark, self.widthScrollView, self.heightScrollView - self.topMark - self.bottomMark)];
                [scrollView setBackgroundColor:[UIColor clearColor]];
                [scrollView setMaximumZoomScale:3.0];
                scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                [scrollView setMinimumZoomScale:1.0];
                scrollView.delegate = self;
                scrollView.tag = i;
                
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
                tapGesture.numberOfTapsRequired = 2;
                [scrollView addGestureRecognizer:tapGesture];
                
                UITapGestureRecognizer *oneTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneTapImage:)];
                oneTapGesture.numberOfTapsRequired = 1;
                [scrollView addGestureRecognizer:oneTapGesture];
                
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:scrollView.bounds];
                [imageView sd_setImageWithURL:[[self.productImages objectAtIndex:i] valueForKey:@"url"] placeholderImage:[UIImage imageNamed:@"logo"] options:SDWebImageRetryFailed];
                [imageView setContentMode:UIViewContentModeScaleAspectFit];
                [scrollView addSubview:imageView];
                [self.scrollViewProductImages addSubview:scrollView];
            }
            if (self.productImages.count == 0) {
                UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, self.topMark, self.widthScrollView, self.heightScrollView - self.topMark - self.bottomMark)];
                [scrollView setBackgroundColor:[UIColor clearColor]];
                [scrollView setMaximumZoomScale:3.0];
                scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                [scrollView setMinimumZoomScale:1.0];
                scrollView.delegate = self;
                scrollView.tag = 0;
                
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
                tapGesture.numberOfTapsRequired = 2;
                [scrollView addGestureRecognizer:tapGesture];
                
                UITapGestureRecognizer *oneTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneTapImage:)];
                oneTapGesture.numberOfTapsRequired = 1;
                [scrollView addGestureRecognizer:oneTapGesture];
                
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:scrollView.bounds];
                [imageView setImage:[UIImage imageNamed:@"logo"]];
                [imageView setContentMode:UIViewContentModeScaleAspectFit];
                [scrollView addSubview:imageView];
                [self.scrollViewProductImages addSubview:scrollView];
            }
            [self.scrollViewProductImages setPagingEnabled:YES];
            [self addSubview:self.scrollViewProductImages];
            [self.delegate didGetProductDetailWithProductID:self.productID];
        }
        [[NSNotificationCenter defaultCenter]removeObserverForNotification:noti];
    }
    if (self.numberImage > 1) {
        float sizeItem = 8;
        float distanceItem = 7;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            sizeItem = 12;
            distanceItem = 10;
        }
        float heightViewPageControl = sizeItem * self.numberImage + distanceItem*(self.numberImage - 1);
        _viewPageControl = [[UIView alloc]initWithFrame:CGRectMake(15, (CGRectGetHeight(self.frame) - heightViewPageControl)/2, sizeItem, heightViewPageControl)];
        for (int i = 0; i < self.numberImage; i++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, i*(sizeItem + distanceItem), sizeItem, sizeItem)];
            imageView.tag = beginTag + i;
            [_viewPageControl addSubview:imageView];
        }
        
        [self setImagePageControl:0];
        [self addSubview:_viewPageControl];
    }
}

- (void)setImagePageControl:(int)index
{
    for (UIView *subview in _viewPageControl.subviews) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            UIImageView *imageView = (UIImageView*)subview;
            if (imageView.tag == (index + beginTag)) {
                [imageView setImage:[[UIImage imageNamed:@"ic_pagecontrolchoice"] imageWithColor:[UIColor grayColor]]];
            }else
            {
                [imageView setImage:[[UIImage imageNamed:@"ic_pagecontrolnochoice"] imageWithColor:[UIColor grayColor]]];
            }
        }
    }
}

- (void)tapImage:(UITapGestureRecognizer *)gesture{
    UIScrollView *scrollView = (UIScrollView *)gesture.view;
    if ([scrollView zoomScale] > 1) {
        [scrollView setZoomScale:1 animated:YES];
        scrollView.scrollEnabled = NO;
    }else{
        CGPoint touchLocation = [gesture locationInView: scrollView];
        
        CGSize scrollViewSize = scrollView.bounds.size;
        
        CGFloat w = scrollViewSize.width/2;
        CGFloat h = scrollViewSize.height/2;
        CGFloat x = touchLocation.x-(w/2.0);
        CGFloat y = touchLocation.y-(h/2.0);
        
        CGRect rectTozoom=CGRectMake(x, y, w, h);
        [scrollView zoomToRect:rectTozoom animated:YES];
        [scrollView setZoomScale:2 animated:YES];
        [scrollView setScrollEnabled:YES];
    }
    return;
}

- (void)oneTapImage:(UITapGestureRecognizer *)gesture
{
    [self.delegate touchImage];
}

#pragma mark UIScrollView Delegates
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.tag == BIG_SCROLL_VIEW_TAG) {
        CGFloat pageWidth = self.scrollViewProductImages.frame.size.height;
        int page = floor((self.scrollViewProductImages.contentOffset.y - pageWidth / 2) / pageWidth) + 1;
        [self setImagePageControl:page];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView.tag == BIG_SCROLL_VIEW_TAG) {
        int offsetBig = scrollView.contentOffset.y / self.scrollViewProductImages.frame.size.height;
        //Scroll smallScrollView
        if (self.offsetZoomed > -1 && self.offsetZoomed != offsetBig) {
            UIScrollView *zoomedScrollView = [self.scrollViewProductImages.subviews objectAtIndex:self.offsetZoomed];
            zoomedScrollView.zoomScale = 1.0;
            zoomedScrollView.scrollEnabled = NO;
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.isTouchInSmallScrollView = NO;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    int offset = self.scrollViewProductImages.contentOffset.y / self.scrollViewProductImages.frame.size.height;
    self.offsetZoomed = offset;
    return [scrollView.subviews objectAtIndex:0];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    CGSize boundsSize = scrollView.bounds.size ;
    UIImageView *imageView = [[scrollView subviews] objectAtIndex:0];
    CGRect contentsFrame = imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    }else{
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    imageView.frame = contentsFrame;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if (scale == 1) {
        scrollView.scrollEnabled = NO;
    }else
    {
        scrollView.scrollEnabled = YES;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
