//
//  SimiGlobalVar.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/19/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimiCustomerModel.h"
#import "SimiStoreModel.h"
#import "SimiCartModelCollection.h"
//  Liam Update 150402
#import "SimiAddressModelCollection.h"
#import "SimiStoreModelCollection.h"
#import "SimiCurrencyModelCollection.h"
#import "SimiCurrencyModel.h"
#import "SimiTheme.h"
#import "DownloadModelCollection.h"

//Type of process data received from server
typedef NS_ENUM(NSInteger, ModelActionType) {
    ModelActionTypeGet,    //0 - Get all data
    ModelActionTypeInsert, //1 - Get more and insert to last
    ModelActionTypeDelete, //2 - Delete all data
    ModelActionTypeEdit    //3 - Edit data
};

//Type of sort product collection
typedef NS_ENUM(NSInteger, ProductCollectionSortType) {
    ProductCollectionSortNone,           //0 - Random
    ProductCollectionSortPriceLowToHigh, //1 - Sort product collection by price from low->high
    ProductCollectionSortPriceHighToLow, //2 - Sort product collection by price from high->low
    ProductCollectionSortNameASC,        //3 - Sort product collection by name from a -> z
    ProductCollectionSortNameDESC        //4 - Sort product collection by name from z -> a
};

//Type of show payment
typedef NS_ENUM(NSInteger, PaymentShowType){
    PaymentShowTypeNull,
    PaymentShowTypeNone,        //1 - Show nothing
    PaymentShowTypeSDK,         //2 - Show by SDK
    PaymentShowTypeRedirect,     //3 - Show by redirect link
    PaymentShowTypeCreditCard,  //4 - Show credit card
};

//Type of payment status
typedef NS_ENUM(NSInteger, PaymentStatus){
    PaymentStatusPending,       //0 - User did payment unsuccessful
    PaymentStatusApproved,      //1 - User did payment successful
    PaymentStatusCancelled      //2 - User cancelled payment
};



//Type of theme
typedef NS_ENUM(NSInteger, ThemeShow)
{
    ThemeShowDefault,
    ThemeShowMatrixTheme,
    ThemeShowZTheme
};

//Type of phone
typedef NS_ENUM(NSInteger, CurrentVersionPhoneUsing)
{
    CurrentVersionPhoneUsingiPhone5andBefore,
    CurrentVersionPhoneUsingiPhone6,
    CurrentVersionPhoneUsingiPhone6Plus
};

// Device Info
#define SIMI_DEBUG_ENABLE [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"SIMI_DEBUG_ENABLE"] boolValue]
#define SIMI_DEVELOPMENT_ENABLE [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"SIMI_DEVELOPMENT_ENABLE"] boolValue]
#define SIMI_THEME_ENABLE [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"SIMI_THEME_ENABLE"] boolValue]
#define ZTHEME_ENABLE [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"ZTHEME_ENABLE"] boolValue]
#define SIMI_SYSTEM_IOS [[UIDevice currentDevice].systemVersion floatValue]
#define SCREEN_WIDTH    ((SIMI_SYSTEM_IOS >= 8)?[[UIScreen mainScreen] bounds].size.width:[[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT   ((SIMI_SYSTEM_IOS >= 8)?[[UIScreen mainScreen] bounds].size.height:[[UIScreen mainScreen] bounds].size.height)

// Theme Information
#define THEME_NAME [SimiGlobalVar getThemeName]
#define THEME_COLOR [SimiGlobalVar getThemeColor:@selector(themeColor)] ? [SimiGlobalVar getThemeColor:@selector(themeColor)] : [[SimiGlobalVar sharedInstance] themeColor]
#define THEME_FONT_NAME [SimiGlobalVar getFontName]
#define THEME_FONT_NAME_REGULAR [SimiGlobalVar getFontNameRegular]
#define THEME_FONT_SIZE [SimiGlobalVar getFontSize]
#define THEME_FONT_SIZE_REGULAR [SimiGlobalVar getFontSizeRegular]

//  King Update 151004
#define THEME_NAVIGATION_ICON_COLOR [[SimiGlobalVar sharedInstance] navigationIconColor]
#define THEME_TEXT_COLOR [[SimiGlobalVar sharedInstance] textColor]
#define THEME_LIGHT_TEXT_COLOR [[SimiGlobalVar sharedInstance] lightTextColor]
#define THEME_MENU_TEXT_COLOR [[SimiGlobalVar sharedInstance] menuTextColor]
#define THEME_MENU_BACKGROUND_COLOR [[SimiGlobalVar sharedInstance] menuBackgroundColor]
#define THEME_MENU_LINE_COLOR [[SimiGlobalVar sharedInstance] menuLineColor]
#define THEME_MENU_ICON_COLOR [[SimiGlobalVar sharedInstance] menuIconColor]
#define THEME_BUTTON_BACKGROUND_COLOR [[SimiGlobalVar sharedInstance] buttonBackgroundColor]
#define THEME_BUTTON_TEXT_COLOR [[SimiGlobalVar sharedInstance] buttonTextColor]
#define THEME_APP_BACKGROUND_COLOR [[SimiGlobalVar sharedInstance] appBackgroundColor]
#define THEME_CONTENT_COLOR [[SimiGlobalVar sharedInstance] contentColor]
#define THEME_CONTENT_PLACEHOLDER_COLOR [[SimiGlobalVar sharedInstance] placeHolderColor]
#define THEME_LINE_COLOR [[SimiGlobalVar sharedInstance] lineColor]
#define THEME_IMAGE_BORDER_COLOR [[SimiGlobalVar sharedInstance] imageBorderColor]
#define THEME_ICON_COLOR [[SimiGlobalVar sharedInstance] iconColor]
#define THEME_PRICE_COLOR [[SimiGlobalVar sharedInstance] priceColor]
#define THEME_SPECIAL_PRICE_COLOR [[SimiGlobalVar sharedInstance] specialPriceColor]
#define THEME_SECTION_COLOR [[SimiGlobalVar sharedInstance] sectionColor]
#define THEME_SEARCH_BOX_BACKGROUND_COLOR [[SimiGlobalVar sharedInstance] searchBoxBackgroundColor]
#define THEME_SEARCH_TEXT_COLOR [[SimiGlobalVar sharedInstance] searchTextColor]
#define THEME_SEARCH_ICON_COLOR [[SimiGlobalVar sharedInstance] searchIconColor]
#define THEME_OUT_STOCK_BACKGROUND_COLOR [[SimiGlobalVar sharedInstance] outStockBackgroundColor]
#define THEME_OUT_STOCK_TEXT_COLOR [[SimiGlobalVar sharedInstance] outStockTextColor]
#define THEME_ADD_CART_COLOR [SimiGlobalVar getThemeColor:@selector(addToCartColor)] ? [SimiGlobalVar getThemeColor:@selector(addToCartColor)] : [[SimiGlobalVar sharedInstance] themeColor]
#define THEME_IMAGE_COLOR_OVERLAY [SimiGlobalVar getThemeConfig:@selector(isColorOverlay)]

// Store and theme utilities
#define CURRENCY_SYMBOL [[SimiGlobalVar sharedInstance] currencySymbol]
#define CURRENCY_CODE [[SimiGlobalVar sharedInstance] currencyCode]
#define LOCALE_IDENTIFIER [[SimiGlobalVar sharedInstance] localeIdentifier]
#define COUNTRY_CODE [[SimiGlobalVar sharedInstance] countryCode]
#define COUNTRY_NAME [[SimiGlobalVar sharedInstance] countryName]
#define COLOR_WITH_HEX(hex) [[SimiGlobalVar sharedInstance] colorWithHexString:hex]
#define THEME_COLOR_IS_LIGHT ([[SimiGlobalVar sharedInstance] getLightDegreeOfColor: THEME_COLOR]) <= 0.81 ? YES : NO

// Customer config
#define PREFIX_SHOW [[SimiGlobalVar sharedInstance] prefixShow]
#define SUFFIX_SHOW [[SimiGlobalVar sharedInstance] suffixShow]
#define DOBFIX_SHOW [[SimiGlobalVar sharedInstance] dobShow]
#define TAXVAT_SHOW [[SimiGlobalVar sharedInstance] taxvatShow]
#define GENDER_SHOW [[SimiGlobalVar sharedInstance] genderShow]

#define DISPLAY_PRICES_INSHOP [[SimiGlobalVar sharedInstance] displayPricesInShop]

//Re-define localize string macro
#define SCLocalizedString(key) [[SimiGlobalVar sharedInstance] localizedStringForKey:key]

@interface SimiGlobalVar : NSObject

@property (strong, nonatomic) NSString *currencySymbol;
@property (strong, nonatomic) SimiCustomerModel *customer;
@property (strong, nonatomic) NSString *quoteId;
@property (strong, nonatomic) SimiStoreModel *store;
@property (strong, nonatomic) SimiStoreModel *appConfigure;
@property (strong, nonatomic) SimiCartModelCollection *cart;
@property (strong, nonatomic) SimiAddressModelCollection *countryColllection;
@property (strong, nonatomic) SimiAddressModelCollection *addressBookCollection;
@property (strong, nonatomic) SimiStoreModelCollection *storeModelCollection;
@property (strong, nonatomic) SimiCurrencyModelCollection *currencyModelCollection;
@property (strong, nonatomic) DownloadModelCollection *downloadModelCollection;
@property (strong, nonatomic) SimiModel *currentLocale;

@property (nonatomic) BOOL isNeedReloadAddressBookCollection;
@property (nonatomic) BOOL isReverseLanguage;
@property (nonatomic) BOOL isDefaultAddress;
@property (nonatomic) BOOL isDefaultPayment;
@property (nonatomic) BOOL isLogin;
@property (nonatomic) BOOL isGettingCart;
@property (nonatomic) BOOL needGetCart;
@property (nonatomic) BOOL isCloudVersion;
@property (nonatomic) BOOL needGetDownloadItems;

@property (nonatomic) ThemeShow themeUsing;
@property (nonatomic) CurrentVersionPhoneUsing phoneUsing;


+ (instancetype)sharedInstance;
- (UIImage *)imageFromColor:(UIColor *)color;
- (UIColor *)colorWithHexString:(NSString *)str;
- (UIColor *)colorWithHexString:(NSString *)str alpha:(CGFloat)alpha;
- (UIColor *)colorWithHex:(UInt32)col;
- (UIColor *)darkerColorForColor:(UIColor *)c;
- (UIColor *)themeColor;
- (void)resetQuote;
+ (UIColor *)getThemeColor:(SEL)themeSelector;
+ (BOOL)getThemeConfig:(SEL)themeSelector;
+ (NSString *)getThemeName;
+ (NSString *)getFontName;
+ (NSString *)getFontNameRegular;

//  King Update 151004
- (UIColor *)navigationIconColor;
- (UIColor *)menuTextColor;
- (UIColor *)menuBackgroundColor;
- (UIColor *)menuLineColor;
- (UIColor *)menuIconColor;
- (UIColor *)buttonBackgroundColor;
- (UIColor *)buttonTextColor;
- (UIColor *)appBackgroundColor;
- (UIColor *)contentColor;
- (UIColor *)placeHolderColor;
- (UIColor *)lineColor;
- (UIColor *)imageBorderColor;
- (UIColor *)iconColor;
- (UIColor *)priceColor;
- (UIColor *)specialPriceColor;
- (UIColor *)sectionColor;
- (UIColor *)searchBoxBackgroundColor;
- (UIColor *)searchTextColor;
- (UIColor *)searchIconColor;
- (UIColor *)outStockBackgroundColor;
- (UIColor *)outStockTextColor;
- (UIColor *)textColor;
- (UIColor *)lightTextColor;

+ (CGFloat)getFontSize;
+ (CGFloat)getFontSizeRegular;
+ (CGFloat)scaleValue:(CGFloat) inputValue;
+ (CGSize)scaleSize:(CGSize) inputSize;
+ (CGRect)scaleFrame:(CGRect) inputFrame;

- (NSString *)currencySymbol;
- (NSString *)currencyCode;
- (NSString *)currencyPosition;
- (NSString *)localeIdentifier;
- (NSString *)countryCode;
- (NSString *)countryName;
- (NSString *)localizedStringForKey:(NSString *)key;
- (NSString *)countryCollectionStorePath;
- (CGFloat)getLightDegreeOfColor:(UIColor *)color;
- (NSString *)prefixShow;
- (NSString *)suffixShow;
- (NSString *)dobShow;
- (NSString *)taxvatShow;
- (NSString *)genderShow;
- (BOOL) isShowZeroPrice;
- (BOOL) displayPricesInShop;
//Axe added
- (NSString* )thousandSeparator;
- (NSString* )decimalSeparator;
-(NSString *) numberOfDecimals;

@end
