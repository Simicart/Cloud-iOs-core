//
//  BarCodeModel.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 1/20/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiModel.h>

@interface BarCodeModel : SimiModel
- (void)getProductIdWithParams:(NSDictionary *)params;
@end
