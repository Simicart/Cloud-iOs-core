//
//  SCPaymentViewController.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 3/2/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import "SimiOrderModel.h"

@interface SCPaymentViewController : SimiViewController<UIAlertViewDelegate>

@property (strong, nonatomic) SimiOrderModel* order;


-(void) moveToThankyouPageWithNotification:(NSNotification *)noti;

@end
