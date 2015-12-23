//
//  SimiPaymentAPI.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 12/21/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

@interface SimiPaymentAPI : SimiAPI
- (void)addAddressForQuote:(NSDictionary *)params extendsUrl:(NSString *)extendsUrl target:(id)target selector:(SEL)selector;
@end
