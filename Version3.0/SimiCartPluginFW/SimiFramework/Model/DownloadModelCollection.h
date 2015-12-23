//
//  DownloadModelCollection.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 9/9/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import "DownloadAPI.h"
@interface DownloadModelCollection : SimiModelCollection
- (void)getDownloadItemsWithParams:(NSDictionary *)params;
@end
