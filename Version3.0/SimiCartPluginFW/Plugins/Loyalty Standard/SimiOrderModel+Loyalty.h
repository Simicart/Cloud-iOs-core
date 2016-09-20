//
//  SimiOrderModel+Loyalty.h
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 2/3/15.
//  Copyright (c) 2015 Magestore. All rights reserved.
//

#import <SimiCartBundle/SimiOrderModel.h>

@interface SimiOrderModel (Loyalty)

- (void)spendPoints:(NSInteger)points ruleId:(id)ruleId;

@end
