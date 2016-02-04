//
//  SCCategoryViewController.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/11/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SCCategoryViewController.h"
#import "SimiResponder.h"
#import "SCProductListViewController.h"
#import "UIImageView+WebCache.h"
#import "SimiProductModelCollection.h"
#import "SimiFormatter.h"
#import "SimiSection.h"
#import "SCProductViewController.h"
#import "AFViewShaker.h"
#import "SimiCacheData.h"
@interface SCCategoryViewController ()

@end

@implementation SCCategoryViewController

@synthesize  tableViewCategory, productCollection,categoryCollection,sortType,collectionView,categoryId,categoryRealName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        paddingLeft = SCREEN_WIDTH/20;
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoadBefore
{
    [super viewDidLoadBefore];
    [self setToSimiView];
    heightTopCell = 50;
    widthViewAll = 80;
    sizeImageViewAll = 8;
    itemHeight = 165;
    itemWidth = 110;
    if (self.categoryId == nil) {
        self.categoryId = @"";
    }
    
    CGRect frame = self.view.frame;
    tableViewCategory = [[SimiTableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    tableViewCategory.dataSource = self;
    tableViewCategory.delegate = self;
    tableViewCategory.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [tableViewCategory setBackgroundColor:[UIColor clearColor]];
    tableViewCategory.showsVerticalScrollIndicator = NO;
    [self.view addSubview:tableViewCategory];
    
    [self setCells:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:ApplicationWillResignActive object:nil];
    // Liam Update for Cache Data
    if (![categoryId isEqualToString:@""]) {
        if ([[SimiCacheData sharedInstance].dataCategories valueForKey:categoryId]) {
            categoryCollection = [[SimiCategoryModelCollection alloc]initWithArray:[[SimiCacheData sharedInstance].dataCategories valueForKey:categoryId]];
            self.didGetCategoryCollection = YES;
        };
        if ([[SimiCacheData sharedInstance].dataCategoryProducts valueForKey:categoryId]) {
            productCollection = [[SimiProductModelCollection alloc]initWithArray:[[SimiCacheData sharedInstance].dataCategoryProducts valueForKey:categoryId]];
            self.arrayProductID = [[NSMutableArray alloc]initWithArray:[[SimiCacheData sharedInstance].dataCategoryProductIDs valueForKey:categoryId]];
            self.didGetCategoryProducts = YES;
        };
    }else
    {
        if ([[SimiCacheData sharedInstance].dataCategories valueForKey:@"all"]) {
            categoryCollection = [[SimiCategoryModelCollection alloc]initWithArray:[[SimiCacheData sharedInstance].dataCategories valueForKey:@"all"]];
            self.didGetCategoryCollection = YES;
        };
        if ([[SimiCacheData sharedInstance].dataCategoryProducts valueForKey:@"all"]) {
            productCollection = [[SimiProductModelCollection alloc]initWithArray:[[SimiCacheData sharedInstance].dataCategoryProducts valueForKey:@"all"]];
            self.arrayProductID = [[NSMutableArray alloc]initWithArray:[[SimiCacheData sharedInstance].dataCategoryProductIDs valueForKey:@"all"]];
            self.didGetCategoryProducts = YES;
        };
    }
    if (productCollection == nil || categoryCollection == nil || productCollection.count == 0 || categoryCollection.count == 0) {
        [self.tableViewCategory setHidden:YES];
        [self startLoadingData];
    }else
    {
        [self setCells:nil];
    }
    if (categoryCollection == nil || categoryCollection.count == 0) {
        [self getCategoryCollection];
    }
    if (productCollection == nil || productCollection.count == 0) {
        [self getCategoryProducts];
    }
    //  End Cache
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark setCells

- (void)setCells:(NSMutableArray *)cells{
    if (cells) {
        _cells = cells;
    }else{
        _cells = [[NSMutableArray alloc] init];
        SimiSection *section = [[SimiSection alloc] init];
        
        if (productCollection.count > 0) {
            SimiRow *row = [[SimiRow alloc] init];
            row.identifier = CATEGORY_ROW_LIST_PRODUCT;
            row.height = 200;
            [section addRow:row];
        }
        if (categoryCollection.count > 0) {
            for (int i = 0; i < categoryCollection.count; i++) {
                SimiCategoryModel *model = [categoryCollection objectAtIndex:i];
                SimiRow *row = [[SimiRow alloc] init];
                row.identifier = CATEGORY_ROW_CHILD;
                row.height = 45;
                row.data = model;
                [section addRow:row];
            }
        }
        [_cells addObject:section];
    }
    [tableViewCategory reloadData];
}



#pragma mark getCategoryColection
- (void)getCategoryCollection{
    
    if (categoryCollection == nil) {
        categoryCollection = [[SimiCategoryModelCollection alloc] init];
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    if(self.categoryId && ![self.categoryId isEqualToString:@""])
        [params setValue:self.categoryId forKey:@"filter[parent]"];
    else
        [params setValue:@"0" forKey:@"filter[parent][exists]"];
    [categoryCollection removeAllObjects];
    [categoryCollection getCategoryCollectionWithParentId:self.categoryId params:params];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:DidGetCategoryCollection object:categoryCollection];
}


- (void)didReceiveNotification:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        if ([noti.name isEqualToString:DidGetCategoryCollection]) {
            [self setCells:nil];
            if (![self.categoryId isEqualToString:@""]) {
                [[SimiCacheData sharedInstance].dataCategories setObject:self.categoryCollection forKey:self.categoryId];
            }else
                [[SimiCacheData sharedInstance].dataCategories setObject:self.categoryCollection forKey:@"all"];
        }
        
        if ([noti.name isEqualToString:DidGetAllProducts] || [noti.name isEqualToString:DidGetProductCollectionWithCategoryId]) {
            [self removeObserverForNotification:noti];
            [self setCells:nil];
            self.arrayProductID = self.productCollection.productIDs;
            if (![self.categoryId isEqualToString:@""]) {
                [[SimiCacheData sharedInstance].dataCategoryProducts setObject:self.productCollection forKey:self.categoryId];
                if (self.arrayProductID) {
                    [[SimiCacheData sharedInstance].dataCategoryProductIDs setObject:self.arrayProductID forKey:self.categoryId];
                }
            }else
            {
                [[SimiCacheData sharedInstance].dataCategoryProducts setObject:self.productCollection forKey:@"all"];
                if (self.arrayProductID ) {
                    [[SimiCacheData sharedInstance].dataCategoryProductIDs setObject:self.arrayProductID forKey:@"all"];
                }
            }
        }
    }
    if ([noti.name isEqualToString:DidGetCategoryCollection]) {
        self.didGetCategoryCollection = YES;
    }else if([noti.name isEqualToString:DidGetAllProducts] || [noti.name isEqualToString:DidGetProductCollectionWithCategoryId])
    {
        self.didGetCategoryProducts = YES;
    }
    if (self.didGetCategoryCollection && self.didGetCategoryProducts) {
        [self stopLoadingData];
        [self.tableViewCategory setHidden:NO];
    }
    if ([noti.name isEqualToString:ApplicationWillResignActive]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:ApplicationDidBecomeActive object:nil];
        return;
    }
    if ([noti.name isEqualToString:ApplicationDidBecomeActive]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ApplicationDidBecomeActive object:nil];
        return;
    }
}
#pragma mark getCategoryProduct
- (void)getCategoryProducts{
    if (productCollection == nil) {
        productCollection = [[SimiProductModelCollection alloc] init];
    }
    if([categoryId isEqualToString:@""]){
        [productCollection getAllProductsWithOffset:0 limit:10 sortType:sortType otherParams:@{}];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:DidGetAllProducts object:self.productCollection];
    }else{
        [productCollection getProductCollectionWithCategoryId:categoryId offset:0 limit:10 sortType:sortType otherParams:@{}];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:DidGetProductCollectionWithCategoryId object:self.productCollection];
    }
}

#pragma mark Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _cells.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    SimiSection *simiSection = [_cells objectAtIndex:section];
   
    return simiSection.rows.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    return simiRow.height;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    SimiRow *simiRow = [simiSection.rows objectAtIndex:indexPath.row];
    UITableViewCell *cell;
    if ([simiRow.identifier isEqualToString:CATEGORY_ROW_LIST_PRODUCT]){
        cell = [tableView dequeueReusableCellWithIdentifier:simiRow.identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simiRow.identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if(categoryRealName == nil){
                categoryRealName = [SCLocalizedString(@"all categories") uppercaseString];
            }
            
            lbcategoryFather = [[UILabel alloc]initWithFrame:CGRectMake(paddingLeft, 0, SCREEN_WIDTH - widthViewAll - paddingLeft, heightTopCell)];
            lbcategoryFather.text =[categoryRealName uppercaseString];
            lbcategoryFather.textColor = THEME_CONTENT_COLOR;
            [lbcategoryFather setFont: [UIFont fontWithName:THEME_FONT_NAME size:15]];
            [cell addSubview:lbcategoryFather];
            
            btnViewAll = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - widthViewAll, 0, 50, heightTopCell)];
            [btnViewAll setTitle:SCLocalizedString(@"View all") forState:UIControlStateNormal];
            [btnViewAll.titleLabel setFont: [UIFont fontWithName:THEME_FONT_NAME size:14]];
            [btnViewAll setTitleColor:THEME_CONTENT_COLOR forState:UIControlStateNormal];
            [btnViewAll addTarget:self action:@selector(didClickViewAll:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:btnViewAll];
            
            UIImageView *imgViewAll = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 25, (heightTopCell - sizeImageViewAll)/2, sizeImageViewAll, sizeImageViewAll)];
            [imgViewAll setImage:[UIImage imageNamed:@"ic_view_all"]];
            [cell addSubview:imgViewAll];
            //Gin edit
            if([[SimiGlobalVar sharedInstance]isReverseLanguage])
            {
            }
            //end
            UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
            [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
            collectionView =[[UICollectionView alloc] initWithFrame:CGRectMake(0, heightTopCell, SCREEN_WIDTH, itemHeight) collectionViewLayout:layout];
            [collectionView setContentInset:UIEdgeInsetsMake(0, paddingLeft, 0, 0)];
            collectionView.dataSource = self;
            collectionView.delegate = self;
            [collectionView setBackgroundColor:[UIColor clearColor]];
            collectionView.showsHorizontalScrollIndicator = NO;
            [cell addSubview: collectionView];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        // Gin edit Shaker  rung image
        if(categoryCollection.count > 0){
            AFViewShaker * viewShaker = [[AFViewShaker alloc] initWithView:self.collectionView];
            [viewShaker shakeWithDuration:1 completion:^{
            }];
        }
        //end
    }
    else if ([simiRow.identifier isEqualToString:CATEGORY_ROW_CHILD]){
        NSString *childCategoryIdentifier = [NSString stringWithFormat:@"%@_%@",simiRow.identifier, [simiRow.data valueForKey:@"_id"]];
        cell = [tableView dequeueReusableCellWithIdentifier:childCategoryIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:childCategoryIdentifier];
            CGRect frame = cell.textLabel.frame;
            frame.origin.x = paddingLeft;
            cell.textLabel.frame = frame;
            cell.textLabel.text =  [simiRow.data valueForKey:@"name"];
            cell.textLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE];
            [cell.textLabel setTextColor:THEME_CONTENT_COLOR];
            if([[SimiGlobalVar sharedInstance]isReverseLanguage])
            {
                [cell.textLabel setTextAlignment:NSTextAlignmentRight];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.userInteractionEnabled = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    if (cell == nil) {
        cell = [UITableViewCell new];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[NSNotificationCenter defaultCenter] postNotificationName:DidSelectCategoryCellAtIndexPath object:tableView userInfo:@{@"indexPath": indexPath}];
    if (self.isDiscontinue) {
        self.isDiscontinue = NO;
        return;
    }
    SimiSection *section = [_cells objectAtIndex:indexPath.section];
    SimiRow *row = [section objectAtIndex:indexPath.row];
    if ([row.identifier isEqualToString:CATEGORY_ROW_CHILD]) {
        BOOL hasChild = [[row.data valueForKey:@"has_children"] boolValue];
        if (hasChild){
            SCCategoryViewController *nextController = [[SCCategoryViewController alloc]init];
            [nextController setCategoryId:[row.data valueForKey:@"_id"]];
            [nextController setCategoryRealName:[row.data valueForKey:@"name"]];
            [self.navigationController pushViewController:nextController animated:YES];
        }else{
            SCProductListViewController *nextController = [[SCProductListViewController alloc]init];;
            [nextController setCategoryID: [row.data valueForKey:@"_id"]];
            nextController.categoryName = [row.data valueForKey:@"name"];
            [self.navigationController pushViewController:nextController animated:YES];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark  CollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [productCollection count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(itemWidth, itemHeight);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [[productCollection objectAtIndex:indexPath.row] valueForKey:@"_id"];
    [self.collectionView registerClass:[SCCategoryCollectionViewCell class] forCellWithReuseIdentifier:identifier];
    SCCategoryCollectionViewCell *cell =[self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.backgroundColor = THEME_APP_BACKGROUND_COLOR;
    [cell setProduct:[productCollection objectAtIndex:indexPath.row]];
    return  cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SimiProductModel *product = [productCollection objectAtIndex:indexPath.row];
    SCProductViewController *productViewController = [SCProductViewController new];
    productViewController.arrayProductsID = self.arrayProductID;
    productViewController.firstProductID = [product valueForKey:@"_id"];
    [self.navigationController pushViewController:productViewController animated:YES];
}
#pragma mark View All Action
- (void)didClickViewAll:(id)senderz
{
    SCProductListViewController *nextController = [[SCProductListViewController alloc]init];;
    [nextController setCategoryID: self.categoryId];
    [nextController setCategoryName:self.categoryRealName];
    [self.navigationController pushViewController:nextController animated:YES];
}
@end


#pragma mark CategoryCollectionCell
@implementation SCCategoryCollectionViewCell
@synthesize imageView,nameLabel,priceLabel,price,productID,name,imagePath,product;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (imageView == nil) {
            imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 110, 110)];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.layer.borderWidth = 1.0f;
           [imageView.layer setBorderColor: THEME_IMAGE_BORDER_COLOR.CGColor];
            [self addSubview:imageView];
        }
        if (nameLabel == nil) {
            nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,imageView.frame.size.height+imageView.frame.origin.y , frame.size.width-10, 15)];
            [nameLabel setNumberOfLines:3];
            [nameLabel setLineBreakMode:NSLineBreakByTruncatingTail];
            [nameLabel setTextAlignment:NSTextAlignmentLeft];
            [nameLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:11]];
            [nameLabel setTextColor:THEME_CONTENT_COLOR];
            [self addSubview:nameLabel];
        }
        if (priceLabel == nil) {
            priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, nameLabel.frame.size.height+nameLabel.frame.origin.y , frame.size.width-10, 15)];
            [priceLabel setNumberOfLines:1];
            [priceLabel setTextAlignment:NSTextAlignmentLeft];
            [priceLabel setFont: [UIFont fontWithName:THEME_FONT_NAME size:11]];
            [priceLabel setTextColor:THEME_PRICE_COLOR];
            [self addSubview:priceLabel];
        }
        if([[SimiGlobalVar sharedInstance] isReverseLanguage]){
            [nameLabel setTextAlignment:NSTextAlignmentRight];
            [nameLabel setLineBreakMode:NSLineBreakByTruncatingHead];
            [priceLabel setTextAlignment:NSTextAlignmentRight];
        }
    }
    return self;
}

- (void)setProduct:(SimiProductModel *)pr{
    if (![product isEqual:pr]) {
        product = pr;
        if ([product valueForKey:@"images"] && [[product valueForKey:@"images"] isKindOfClass:[NSArray class]]) {
            NSMutableArray *arrayImage = [[NSMutableArray alloc]initWithArray:[product valueForKey:@"images"]];
            if (arrayImage.count > 0) {
                self.imagePath = [[arrayImage objectAtIndex:0]valueForKey:@"url"];
            }
        }else
            [self.imageView setImage:[UIImage imageNamed:@"logo"]];
        self.name = [product valueForKey:@"name"];
        self.productID = [product valueForKey:@"_id"];
        self.price = [product valueForKey:@"price"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidDrawProductImageView" object:self userInfo:@{@"imageView": imageView, @"product": product}];
}

- (void)setName:(NSString *)n{
    if (![n isKindOfClass:[NSNull class]]) {
        if (![n isEqualToString:name]) {
            name = [n copy];
            nameLabel.text = name;
            nameLabel.font = [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 4];
        }
    }
}

-(void)setImagePath:(NSString *)ip{
    if (![imagePath isEqualToString:ip]) {
        imagePath = [ip copy];
        NSURL *url = [NSURL URLWithString:imagePath];
        [imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"logo"]];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
    }
}

- (void)setProductID:(NSString *)pid{
    if (![pid isEqualToString:productID]) {
        productID = [pid copy];
    }
}

-(void)setPrice:(NSString *)p{
    if (![price isEqualToString:p]) {
        price = [p copy];
        priceLabel.text = [[SimiFormatter sharedInstance] priceWithPrice:price];
        [UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 4];
    }
}

@end


