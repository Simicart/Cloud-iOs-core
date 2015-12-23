//
//  SimiCMSPagesModelCollection.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 12/2/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import "SimiModelCollection.h"

@interface SimiCMSPagesModelCollection : SimiModelCollection
- (void)getCMSPagesWithParams:(NSDictionary *)params;
@end
