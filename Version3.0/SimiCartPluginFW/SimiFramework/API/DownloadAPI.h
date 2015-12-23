//
//  DownLoadAPI.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 9/9/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
extern NSString *const kSimiGetDownloadItems;
@interface DownloadAPI : SimiAPI
- (void)getDownloadItemsWithParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
@end
