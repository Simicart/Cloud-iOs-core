//
//  SimiNotificationName.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 12/3/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark General
static NSString *ApplicationWillResignActive = @"ApplicationWillResignActive";
static NSString *ApplicationDidBecomeActive = @"ApplicationDidBecomeActive";
static NSString *ApplicationDidFinishLaunching = @"ApplicationDidFinishLaunching";
static NSString *ApplicationDidRegisterForRemote = @"ApplicationDidRegisterForRemote";
static NSString *ApplicationDidReceiveNotificationFromServer = @"ApplicationDidReceiveNotificationFromServer";

static NSString *DidGetActivePlugins = @"DidGetActivePlugins";
static NSString *DidGetSitePlugins = @"DidGetSitePlugins";
static NSString *SCLeftMenuDidSelectRow = @"SCLeftMenuDidSelectRow";
static NSString *DidRegisterDevice = @"DidRegisterDevice";
static NSString *ChangeAppLanguage = @"ChangeAppLanguage";

#pragma mark Product ModelCollection
static NSString *DidGetProductCollectionWithCategoryId = @"DidGetProductCollectionWithCategoryId";
static NSString *DidSearchProducts = @"DidSearchProducts";
static NSString *DidGetSpotProduct = @"DidGetSpotProduct";
static NSString *DidGetRelatedProductCollection = @"DidGetRelatedProductCollection";
static NSString *DidGetAllProducts = @"DidGetAllProducts";
static NSString *DidGetSpotProducts = @"DidGetSpotProducts";

#pragma mark Product ModelCollection
static NSString *DidGetProductWithProductId = @"DidGetProductWithProductId";

#pragma mark Category ModelCollection
static NSString *DidGetCategoryCollection = @"DidGetCategoryCollection";

#pragma mark Category Controller
static NSString *DidSelectCategoryCellAtIndexPath = @"DidSelectCategoryCellAtIndexPath";
static NSString *DidGetCategory = @"DidGetCategory";

#pragma mark Cart Controller
static NSString *DidGetCart = @"DidGetCart";
static NSString *DidAddToCart = @"DidAddToCart";
static NSString *DidChangeCart = @"DidChangeCart";
static NSString *DidPlaceOrderBefore = @"DidPlaceOrder-Before";
static NSString *DidPlaceOrderAfter = @"DidPlaceOrder-After";
static NSString *DidEditQty = @"DidEditQty";
static NSString *DidSelectCartCellAtIndexPath = @"DidSelectCartCellAtIndexPath";
static NSString *PushLoginInCheckout = @"PushLoginInCheckout";
static NSString *InitCartCellBefore = @"InitCartCell-Before";
static NSString *InitCartCellAfter = @"InitCartCell-After";
static NSString *InitProductCellBefore = @"InitProductCell-Before";
static NSString *InitProductCellAfter = @"InitProductCell-After";
static NSString *InitializedProductCartCellBefore = @"InitializedProductCartCell-Before";
static NSString *InitializedProductCartCellAfter = @"InitializedProductCartCell-After";
static NSString *InitializedCartCellBefore = @"InitializedCartCell-Before";
static NSString *InitializedCartCellAfter = @"InitializedCartCell-After";
static NSString *DidMergeQuote = @"DidMergeQuote";
static NSString *DidCreateNewQuote = @"DidCreateNewQuote";
static NSString *DidAddCustomerToQuote = @"DidAddCustomerToQuote";
static NSString *DidAddNewCustomerToQuote = @"DidAddNewCustomerToQuote";

#pragma mark Customer
static NSString *DidLogin = @"DidLogin";
static NSString *DidLogout = @"DidLogout";
static NSString *DidRegister = @"DidRegister";
static NSString *DidGetProfile = @"DidGetProfile";
static NSString *DidGetMerchantInfo = @"DidGetMerchantInfo";
static NSString *DidChangeUserInfo = @"DidChangeUserInfo";
static NSString *DidGetForgotPassword = @"DidGetForgotPassword";
static NSString *PushLoginNormal = @"PushLoginNormal";
static NSString *DidChangeUserPassword = @"DidChangeUserPassword";
static NSString *DidSaveAddress = @"DidSaveAddress";
static NSString *DidSelectAddressCellAtIndexPath = @"DidSelectAddressCellAtIndexPath";
static NSString *DidGetQuotes = @"DidGetQuotes";

#pragma mark Address Model Collection
static NSString *DidGetAddressCollection = @"DidGetAddressCollection";
static NSString *DidGetStateCollection = @"DidGetStateCollection";
static NSString *DidGetCountryCollection = @"DidGetCountryCollection";

#pragma mark Order
static NSString *DidGetShippingMethod = @"DidGetShippingMethod";
static NSString *DidGetPaymentMethod = @"DidGetPaymentMethod";
static NSString *DidSavePaymentMethod = @"DidSavePaymentMethod";
static NSString *DidSaveShippingMethod = @"DidSaveShippingMethod";
static NSString *DidGetOrder = @"DidGetOrder";
static NSString *DidCancelOrder = @"DidCancelOrder";
static NSString *DidGetOrderConfig = @"DidGetOrderConfig";
static NSString *DidSetCouponCode = @"DidSetCouponCode";
static NSString *DidPlaceOrder = @"DidPlaceOrder";
static NSString *DidCompleteReOrder = @"DidCompleteReOrder";
static NSString *PlaceOrderBefore = @"SCOrderViewControllerBeforePlaceOrder";
static NSString *DidUpdatePaymentStatus = @"DidUpdatePaymentStatus";
#pragma mark Orders Model Collection
static NSString *DidGetOrderCollection = @"DidGetOrderCollection";

#pragma mark Banner Model Collection
static NSString *DidGetBanner = @"DidGetBanner";

#pragma mark CSM Model Collection
static NSString *DidGetCMSPages = @"DidGetCMSPages";

#pragma mark Store Model & Model Collection
static NSString *DidGetStore = @"DidGetStore";
static NSString *DidGetThemeConfigure = @"DidGetThemeConfigure";

#pragma mark Home Default Category
static NSString *DidGetHomeCategories = @"DidGetHomeCategories";

#pragma mark Spot Model Collection
static NSString *DidGetSpotCollection = @"DidGetSpotCollection";

#pragma mark Matrix Theme Model
static NSString *Theme01DidGetSpotProducts = @"Theme01DidGetSpotProducts";
static NSString *Theme01DidGetCategoryWidgets = @"Theme01DidGetCategoryWidgets";

#pragma mark Zara Theme Model
static NSString *ZaraThemeDidGetSpotProducts = @"ZTheme-GetSpotProducts";
static NSString *ZaraThemeDidGetCategoryWidgets = @"ZTheme-GetListCategories";



@interface SimiNotificationName : NSObject
@end
