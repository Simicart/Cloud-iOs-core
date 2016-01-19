//
//  SCProductCollectionViewController.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 8/8/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SCProductCollectionViewController.h"
#import "UILabelDynamicSize.h"
#import "SCProductCollectionViewCell.h"
@interface SCProductCollectionViewController ()

@end

@implementation SCProductCollectionViewController

static NSString * const reuseIdentifier = @"CellTable";

@synthesize productCollection, categoryID, sortType, lbNotFound;
@synthesize isShowOnlyImage;

#pragma mark Main Method
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self viewDidLoadAfter];
}

- (void)viewDidLoadAfter
{
    [self setLayout];
    sortType = ProductCollectionSortNone;
    if (SIMI_SYSTEM_IOS >= 7.0) {
        lbNotFound = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, self.collectionView.frame.size.width - 20, 40)];
    }else{
        lbNotFound = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.collectionView.frame.size.width - 20, 160)];
    }
    [lbNotFound setText:SCLocalizedString(@"There are no products matching the selection.")];
    [lbNotFound setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
    [lbNotFound setTextColor:THEME_COLOR];
    [lbNotFound resizLabelToFit];
    [lbNotFound setTextAlignment:NSTextAlignmentCenter];
    [lbNotFound setHidden:YES];
    [self.collectionView addSubview:lbNotFound];
    
    __block __weak id weakSelf = self;
    [self.collectionView addInfiniteScrollingWithActionHandler:^{
        [weakSelf getProducts];
    }];
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
    
    self.gesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didReceivePinchGesture:)];
    [self.collectionView addGestureRecognizer:self.gesture];
    self.scale = 1;
    self.lastContentOffset = 0;
    if ([[[SimiGlobalVar sharedInstance].store valueForKey:@"view_products_default"]boolValue]) {
        [self getProducts];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self viewWillAppearAfter];
}

- (void)viewWillAppearAfter
{
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UICollectionView Data Source

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SimiProductModel *product = [productCollection objectAtIndex:[indexPath row]];
    NSString *stringCell = [NSString stringWithFormat:@"CELL_ID%@",[product valueForKey:@"_id"]];
    [collectionView registerClass:[SCProductCollectionViewCell class] forCellWithReuseIdentifier:stringCell];
    SCProductCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:stringCell forIndexPath:indexPath];
    if (cell.isShowOnlyImage != isShowOnlyImage) {
        cell.isShowOnlyImage = isShowOnlyImage;
        cell.isChangeLayOut = YES;
    }else
    {
        cell.isChangeLayOut = NO;
    }
    [cell cusSetProductModel:product];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitializedCollectionViewCellAtIndexPath-After" object:cell userInfo:@{@"indexPath": indexPath}];
    return cell;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.productCollection ? [self.productCollection count] : 0;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    [collectionView.collectionViewLayout invalidateLayout];
    return 1;
}

#pragma mark -
#pragma mark UICollectionView Delegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectProductListCellAtIndexPath" object:collectionView userInfo:@{@"indexPath": indexPath}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return;
    }
    
    SimiProductModel *product = [productCollection objectAtIndex:indexPath.row];
    [self.delegate selectedProduct:[product valueForKey:@"_id"]];
}

#pragma mark GetProducts
- (void)getProducts{
    if (self.productCollection == nil) {
        self.productCollection = [[SimiProductModelCollection alloc] init];
    }
    
    NSInteger offset = self.productCollection.count;
    if (offset >= self.totalNumberProduct && offset > 0) {
        [self.collectionView.infiniteScrollingView stopAnimating];
        return;
    }
    [self.delegate startGetProductModelCollection];
    [self.lbNotFound setHidden:YES];
    if (self.filterParam == nil) {
        self.filterParam = [[NSMutableDictionary alloc]initWithDictionary:@{}];
    }
    switch (self.collectionGetProductType) {
        case ProductListGetProductTypeFromSearch:
        {
            if (self.keySearchProduct && ![self.keySearchProduct isEqualToString:@""] ) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProducts:) name:DidSearchProducts object:self.productCollection];
                if ([self.categoryID isEqualToString:@""] || self.isSearchOnAllProducts || self.categoryID == nil) {
                    [self.productCollection searchOnAllProductsWithKey:self.keySearchProduct offset:offset limit:24 sortType:self.sortType otherParams:@{}];
                }else{
                    [self.productCollection searchProductsWithKey:self.keySearchProduct offset:offset limit:24 categoryId:categoryID sortType:self.sortType otherParams:@{}];
                }
            }
        }
            break;
        case ProductListGetProductTypeFromCategory:
        {
            if (![self.categoryID boolValue]) {
                //Get All Product
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProducts:) name:DidGetAllProducts object:self.productCollection];
                [self.productCollection getAllProductsWithOffset:offset limit:24 sortType:self.sortType otherParams:@{}];
            }else{
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProducts:) name:DidGetProductCollectionWithCategoryId object:self.productCollection];
                [self.productCollection getProductCollectionWithCategoryId:self.categoryID offset:offset limit:24 sortType:self.sortType otherParams:@{}];
            }
        }
            break;
        case ProductListGetProductTypeFromSpot:
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProducts:) name:DidGetAllProducts object:productCollection];
            switch ([[self.spotModel valueForKey:@"type"] integerValue]) {
#pragma mark  Best Seller
                case 1:
                {
                    [self.productCollection getAllProductsWithOffset:0 limit:20 sortType:ProductCollectionSortNone otherParams:@{@"group-type":@"best-sellers"}];
                }
                    break;
#pragma mark Newly Update
                case 2:
                {
                    [productCollection getAllProductsWithOffset:0 limit:20 sortType:ProductCollectionSortNone otherParams:@{@"order":@"updated_at",@"dir":@"desc"}];
                }
                    break;
#pragma mark Recently Added
                case 3:
                {
                    [productCollection getAllProductsWithOffset:0 limit:20 sortType:ProductCollectionSortNone otherParams:@{@"order":@"created_at",@"dir":@"desc"}];
                }
                    break;
#pragma mark Custom
                case 4:
                {
                    NSString *stringIds = @"";
                    if ([[self.spotModel valueForKey:@"products"] isKindOfClass:[NSMutableArray class]]) {
                        NSMutableArray *arrayIds = [[NSMutableArray alloc]initWithArray:[self.spotModel valueForKey:@"products"]];
                        for (int j =0; j < arrayIds.count; j++) {
                            if (j!= 0) {
                                stringIds = [NSString stringWithFormat:@"%@,%@",stringIds,[arrayIds objectAtIndex:j]];
                            }else
                                stringIds = [NSString stringWithFormat:@"%@",[arrayIds objectAtIndex:j]];
                        }
                    }
                    
                    [productCollection getAllProductsWithOffset:0 limit:20 sortType:ProductCollectionSortNone otherParams:@{@"ids":stringIds}];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case ProductListGetProductTypeFromRelateProduct:
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProducts:) name:DidGetAllProducts object:productCollection];
             [productCollection getAllProductsWithOffset:0 limit:20 sortType:ProductCollectionSortNone otherParams:@{@"ids":self.relatedIds}];
        }
            break;
        default:
            break;
    }
    [self.collectionView.infiniteScrollingView startAnimating];
}


- (void)didGetProducts:(NSNotification *)noti{
    responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        self.totalNumberProduct = (int)[self.productCollection.productIDs count];
        [self.delegate numberProductChange:self.totalNumberProduct];
        [self.collectionView reloadData];
        self.arrayProductID = [[NSMutableArray alloc]initWithArray:self.productCollection.productIDs];
    }
    [self.delegate didGetProductModelCollection:@{}];
    if ([self.productCollection count] == 0) {
        [self.lbNotFound setHidden:NO];
    }else{
        [self.lbNotFound setHidden:YES];
    }
    [self removeObserverForNotification:noti];
    [self.collectionView.infiniteScrollingView stopAnimating];
}
#pragma mark setLayOut
- (void)setLayout
{
    minimumImageSize = 73.75;
    maximumImageSize = 152.5;
    heightLabel = 20;
    padding = 5;
    paddingTop = 38;
    paddingBottom = 40;
    lineSpace = 20;
    if (isShowOnlyImage) {
        UICollectionViewFlowLayout *grid = [[UICollectionViewFlowLayout alloc]init];
        grid.itemSize = [SimiGlobalVar scaleSize:CGSizeMake(minimumImageSize, minimumImageSize)];
        grid.minimumInteritemSpacing = [SimiGlobalVar scaleValue:padding];
        grid.minimumLineSpacing = [SimiGlobalVar scaleValue:padding];
        [self.collectionView reloadData];
        [self.collectionView setCollectionViewLayout:grid animated:YES completion:^(BOOL finished) {
        }];
        [self.collectionView setContentInset:UIEdgeInsetsMake([SimiGlobalVar scaleValue:paddingTop], [SimiGlobalVar scaleValue:5], paddingBottom, [SimiGlobalVar scaleValue:padding])];
        self.collectionView.showsVerticalScrollIndicator = NO;
    }else
    {
        UICollectionViewFlowLayout *grid = [[UICollectionViewFlowLayout alloc]init];
        grid.itemSize = [SimiGlobalVar scaleSize:CGSizeMake(maximumImageSize, maximumImageSize + 2* heightLabel)];
        grid.minimumInteritemSpacing = [SimiGlobalVar scaleValue:padding];
        grid.minimumLineSpacing = [SimiGlobalVar scaleValue:lineSpace];
        __block __weak SCProductCollectionViewController *weakSelf =  self;
        [self.collectionView setCollectionViewLayout:grid animated:YES completion:^(BOOL finished) {
            [weakSelf.collectionView reloadData];
        }];
        [self.collectionView setContentInset:UIEdgeInsetsMake([SimiGlobalVar scaleValue:paddingTop], [SimiGlobalVar scaleValue:padding], paddingBottom, [SimiGlobalVar scaleValue:padding])];
        self.collectionView.showsVerticalScrollIndicator = NO;
    }
}

- (void)didReceivePinchGesture:(UIPinchGestureRecognizer*)gesture
{
    static CGFloat scaleStart;
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        // Take an snapshot of the initial scale
        scaleStart = self.scale;
        return;
    }
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        // Apply the scale of the gesture to get the new scale
        self.scale = scaleStart * gesture.scale;
        if (self.scale > scaleStart && isShowOnlyImage == YES ) {
            isShowOnlyImage = NO;
            [self setLayout];
        }
        
        if (self.scale < scaleStart && isShowOnlyImage == NO) {
            isShowOnlyImage = YES;
            [self setLayout];
        }
    }
}

#pragma mark Scroll View Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (isShowOnlyImage) {
        if (productCollection.count % 4 != 0) {
            numberRow = productCollection.count/4 + 1;
        }else
            numberRow = productCollection.count/4;
        maxScrollOffset = numberRow *(minimumImageSize + padding) - (SCREEN_HEIGHT - 64);
    }else
    {
        if (productCollection.count % 2 != 0) {
            numberRow = productCollection.count/2 +1;
        }else
            numberRow = productCollection.count/2;
        maxScrollOffset = numberRow *(maximumImageSize + 2 *heightLabel + lineSpace) - (SCREEN_HEIGHT - 64);
    }
    if (scrollView.contentOffset.y > - [SimiGlobalVar scaleValue:paddingTop] && scrollView.contentOffset.y < maxScrollOffset) {
        if (self.lastContentOffset > scrollView.contentOffset.y)
        {
            [self.delegate setHideViewToolBar:YES];
        }
        else if (self.lastContentOffset < scrollView.contentOffset.y)
        {
            [self.delegate setHideViewToolBar:NO];
        }
        self.lastContentOffset = scrollView.contentOffset.y;
    }
}
@end
