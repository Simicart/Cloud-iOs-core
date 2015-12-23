//
//  SCGenderViewController.h
//  SimiCartPluginFW
//
//  Created by KingRetina on 8/11/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimiTableView.h"
#import "SimiViewController.h"

@protocol SCGenderViewDelegate <NSObject>
@optional
- (void)didSelectGender:(NSInteger)selectedId;
@end

@interface SCGenderViewController : SimiViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) SimiTableView *tableViewGender;
@property (strong, nonatomic) NSArray *genderList;
@property (strong, nonatomic) NSString *selectedGender;
@property (strong, nonatomic) id<SCGenderViewDelegate> delegate;

@end
