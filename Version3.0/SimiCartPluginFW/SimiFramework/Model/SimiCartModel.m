//
//  SimiCartModel.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/7/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiCartModel.h"
#import "SimiCartAPI.h"
#import "SimiFormatter.h"
#import <CommonCrypto/CommonDigest.h>

@implementation SimiCartModel

- (void)mergeQuote:(NSString *)sourceQuoteId withQuote:(NSString *)desQuoteId{
    currentNotificationName = DidMergeQuote;
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:sourceQuoteId forKey:@"source_quoteId"];
    [params setValue:desQuoteId forKey:@"des_quoteId"];
    [self preDoRequest];
    [(SimiCartAPI *)[self getAPI] mergeQuoteWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)getCartItemsWithParams:(NSDictionary *)params cartId:(NSString *)cartId{
    currentNotificationName = DidGetCart;
    NSString *extendsUrl = @"";
    if(cartId && ![cartId isEqualToString:@""])
        extendsUrl = [@"/" stringByAppendingString:cartId];
    [self preDoRequest];
    [(SimiCartAPI *)[self getAPI] getCartItemsWithParams:params extendsUrl:(NSString *)extendsUrl target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)addToCartWithProduct:(SimiProductModel *)product{
    currentNotificationName = DidAddToCart;
//    [self preDoRequest];
    [self preDoRequest];
    NSString *extendUrl = [NSString stringWithFormat:@"/%@/items",[SimiGlobalVar sharedInstance].quoteId];
    [(SimiCartAPI *)[self getAPI] addToCartWithParams:product extendUrl:extendUrl target:self selector:@selector(didFinishRequest:responder:)];
}
- (void)editQtyInCartWithData:(NSArray *)data cartId:(NSString *) cartId{
    currentNotificationName = DidEditQty;
    [self preDoRequest];
    NSString *extendsUrl = cartId;
    if([data valueForKey:@"_id"])
        extendsUrl = [@"/" stringByAppendingString:[cartId stringByAppendingString:[@"/items/" stringByAppendingString:[data valueForKey:@"_id"]]]];
    NSString *qty = [data valueForKey:@"qty"];
    modelActionType = ModelActionTypeEdit;
    [(SimiCartAPI *)[self getAPI] editCartItemsWithParams:@{@"qty": qty} extendsUrl:extendsUrl target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)deleteCartItemWithCartId:(NSString *)cartId itemId:(NSString *)itemId{
    currentNotificationName = DidEditQty;
    [self preDoRequest];
    NSString *extendsUrl = cartId;
    if(itemId)
        extendsUrl = [@"/" stringByAppendingString:[cartId stringByAppendingString:[@"/items/" stringByAppendingString:itemId]]];
    modelActionType = ModelActionTypeEdit;
    [(SimiCartAPI *)[self getAPI] deleteCartItem:extendsUrl target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)createNewQuote
{
    currentNotificationName = DidCreateNewQuote;
    NSMutableDictionary *params = [NSMutableDictionary new];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *input = [dateFormatter stringFromDate:[NSDate date]];
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    [params setValue:output forKey:@"session_id"];
    [params setValue:@"0" forKey:@"orig_order_id"];
    [params setValue:[SimiGlobalVar sharedInstance].currencyCode forKey:@"quote_currency_code"];
    [params setValue:[SimiGlobalVar sharedInstance].currencyCode forKey:@"base_currency_code"];
    [params setValue:[SimiGlobalVar sharedInstance].currencyCode forKey:@"store_currency_code"];
    [params setValue:[[SimiFormatter sharedInstance] priceWithPrice:@"1000"] forKey:@"currency_template"];
    [self preDoRequest];
    [(SimiCartAPI *)[self getAPI] createNewQuoteWithParams:params target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)addCustomerToQuote:(NSMutableDictionary*)params
{
    currentNotificationName = DidAddCustomerToQuote;
    [self preDoRequest];
    [(SimiCartAPI *)[self getAPI] addCustomerToQuote:params extendUrl:[NSString stringWithFormat:@"/%@",[SimiGlobalVar sharedInstance].quoteId] target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)addNewCustomerToQuote:(NSMutableDictionary*)params
{
    currentNotificationName = DidAddNewCustomerToQuote;
    [self preDoRequest];
    [(SimiCartAPI *)[self getAPI] addCustomerToQuote:params extendUrl:[NSString stringWithFormat:@"/%@/customer",[SimiGlobalVar sharedInstance].quoteId] target:self selector:@selector(didFinishRequest:responder:)];
}

- (NSString *)cartQty{
    NSInteger badge = 0;
    for (SimiCartModel *obj in self) {
        badge += [[obj valueForKey:@"product_qty"] integerValue];
    }
    return [NSString stringWithFormat:@"%ld", (long)badge];
}

- (void)didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder
{
    if ([currentNotificationName isEqualToString:DidGetCart] || [currentNotificationName isEqualToString:DidCreateNewQuote] || [currentNotificationName isEqualToString:DidEditQty] || [currentNotificationName isEqualToString:DidAddToCart] || [currentNotificationName isEqualToString:DidAddNewCustomerToQuote] ||[currentNotificationName isEqualToString:DidMergeQuote]) {
        if (responder.simiObjectName) {
            currentNotificationName = responder.simiObjectName;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
        if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
            NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
            switch (modelActionType) {
                case ModelActionTypeInsert:{
                    [self addData:[responseObjectData valueForKey:@"quote"]];
                }
                    break;
                default:{
                    [self setData:[responseObjectData valueForKey:@"quote"]];
                }
                    break;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }else if (responseObject == nil){
            [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
        }
    }else
    {
        [super didFinishRequest:responseObject responder:responder];
    }
}

@end
