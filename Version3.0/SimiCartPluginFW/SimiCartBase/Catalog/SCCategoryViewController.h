

#import <UIKit/UIKit.h>
#import "SimiViewController.h"
#import "SimiCategoryModel.h"
#import "SimiMutableArray.h"
#import "SimiProductModel.h"
#import "SimiViewController.h"
#import "SimiTableView.h"
#import "SimiProductModelCollection.h"
#import "SimiCategoryModelCollection.h"
#import "SCProductViewController.h"

static NSString *CATEGORY_ROW_LIST_PRODUCT = @"CATEGORY_ROW_LIST_PRODUCT";
static NSString *CATEGORY_ROW_CHILD     = @"CATEGORY_ROW_CHILD";
static NSString *CATEGORY_LOADING_CELL  = @"CATEGORY_LOADING_CELL";

@interface SCCategoryViewController : SimiViewController<UITableViewDataSource, UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate>
{
    UILabel *lbcategoryFather;
    UIButton *btnViewAll;
    float paddingLeft;
    float heightTopCell;
    float widthViewAll;
    float sizeImageViewAll;
    float itemWidth;
    float itemHeight;
}
@property (strong, nonatomic) SimiTableView *tableViewCategory;
@property (strong, nonatomic) SimiCategoryModelCollection *categoryCollection;
@property (strong, nonatomic) NSMutableArray *cells;
@property (strong, nonatomic) NSString *categoryId;
@property (strong, nonatomic) NSString *categoryRealName;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) SimiProductModelCollection *productCollection;
@property (nonatomic) ProductCollectionSortType sortType;
@property (nonatomic, strong) NSMutableArray *arrayProductID;
@property (nonatomic) BOOL didGetCategoryProducts;
@property (nonatomic) BOOL didGetCategoryCollection;

- (void)getCategoryProducts;
- (void)getCategoryCollection;
@end


@interface SCCategoryCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) SimiProductModel *product;
@property (strong, nonatomic)  NSString *name;
@property (strong, nonatomic)  NSString *imagePath;
@property (strong, nonatomic) NSString *productID;
@property (strong, nonatomic) NSString *price;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *priceLabel;
-(void)setProduct:(SimiProductModel *)pr;
@end
