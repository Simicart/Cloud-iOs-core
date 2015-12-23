//
//  SCProductViewController.h
//  SimiCartPluginFW
#import "SimiCartBundle.h"
#import "SCProductViewController.h"
#import "SimiFormatter.h"
#import "SCProductView.h"
#import "WYPopoverController.h"
#import "SCProductOptionViewController.h"
#import "SCProductMoreViewController.h"

@interface SCProductViewController : SimiViewController<UIScrollViewDelegate, SCProductView_Delegate, WYPopoverControllerDelegate, SCProductOptionViewController_Delegate >
{
    BOOL isSelectedFullOptions;
    BOOL isLoading;
    
    float heightViewAction;
    float widthShortButton;
    float widthLongButton;
    float heightNavigation;
    float paddingEdge;
    float spaceBetweenButton;
    float heightButton;
    float heightShadow;
    float cornerRadius;
}

@property (nonatomic) NSInteger numberOfRequired;
@property (strong, nonatomic) SimiProductModel *product;
@property (strong, nonatomic) NSString *productId;
@property (strong, nonatomic) NSArray *allKeys;
@property (strong, nonatomic) NSMutableDictionary *optionDict;
@property (strong, nonatomic) NSMutableDictionary *selectedOptionPrice;

@property (nonatomic, strong) UIScrollView *scrollViewProducts;
@property (nonatomic, strong) NSMutableArray *arrayProductsID;
@property (nonatomic, strong) NSMutableArray *arrayProductsView;
@property (nonatomic, strong) NSString *firstProductID;
@property (nonatomic) float heightScrollView;
@property (nonatomic) float widthScrollView;
@property (nonatomic) int currentIndexProductOnArray;

@property (nonatomic, strong) UIView *viewToolBar;
@property (nonatomic, strong) UILabel *labelProductName;
@property (nonatomic, strong) UILabel *lblRegularPrice;
@property (nonatomic, strong) UILabel *lblSpecialPrice;
@property (nonatomic, strong) UIView *crossLine;
@property (nonatomic, strong) UIButton *detailButon;
@property (nonatomic, strong) UIImageView *moreInfoImage;
@property (nonatomic, strong) UILabel *moreLabel;

@property (nonatomic, strong) UIButton *buttonAddToCart;
@property (nonatomic, strong) UIButton *buttonSelectOption;
@property (nonatomic, strong) UIImageView *imageShadowAddToCart;
@property (nonatomic, strong) UIImageView *imageShadowSelectOption;
@property (nonatomic, strong) UIView *viewAction;
@property (nonatomic) BOOL hadCurrentProductModel;
@property (nonatomic) BOOL isShowOnlyImage;
@property (nonatomic) BOOL isFirtLoadProduct;
@property (nonatomic, strong) WYPopoverController *optionPopoverController;
@property (nonatomic, strong) SCProductOptionViewController *optionViewController;

@property (nonatomic, strong) UIImageView *currentImageProduct;
// Check open option from Add To Cart, if Yes and all require options are selected, add product to cart
@property (nonatomic) BOOL isOpenOptionFromAddToCart;

@property (nonatomic, strong) NSMutableArray *variantsAllKey;
@property (nonatomic, strong) NSMutableArray *variants;
@property (nonatomic, strong) NSMutableArray *variantOptions;
@property (nonatomic, strong) NSString *variantSelectedKey;

@property (nonatomic, strong) NSMutableArray *customs;
@property (nonatomic, strong) NSMutableDictionary *customOptions;

@property (nonatomic, strong) NSMutableArray *bundleItems;
@property (nonatomic, strong) NSMutableDictionary *bundleOptions;

@property (nonatomic, strong) NSMutableArray *groupItems;
@property (nonatomic, strong) NSMutableArray *groupOptions;

@property (nonatomic) BOOL hasOption;


- (void)configureProductViewWithStatus:(BOOL)isStatus;
- (void)addToCart;
- (NSInteger)countNumberOfRequired;
- (BOOL)isCheckedAllRequiredOptions;
- (void)processingOptions;
- (void)changeStateActionButtonWithState:(BOOL)state;
@end
