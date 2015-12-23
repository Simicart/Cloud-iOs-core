//
//  SimiCartModel.h
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/7/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiModelCollection.h"
#import "SimiProductModel.h"
#import "SimiCartModel.h"

@interface SimiCartModel : SimiModel

- (void)editQtyInCartWithData:(NSArray *)data cartId:(NSString *)cartId;

/*
 Notification name: DidMergeQuote
 */
- (void)mergeQuote:(NSString *)sourceQuoteId withQuote:(NSString *)desQuoteId;
/*
 
 Notification name: DidGetCart
 */
- (void)getCartItemsWithParams:(NSDictionary *)params cartId:(NSString *)cartId;

/*
 Notification name: DidAddToCart
 */
- (void)addToCartWithProduct:(SimiProductModel *)product;


/*
 Notification name: DidEditQty
 */
//- (void)editQtyInCartWithData:(NSArray *)data;

//- (NSInteger)indexOfObject:(SimiCartModel *)cartItem;

/*
 Notification name: DidCreateQuote
 */
- (void)createNewQuote;

/*
 Notification name: DidAddCustomerToQuote
*/
- (void)addCustomerToQuote:(NSMutableDictionary*)params;

/*
 Notification name: DidEditQty
 */
- (void)deleteCartItemWithCartId:(NSString *)cartId itemId:(NSString *)itemId;

@end
