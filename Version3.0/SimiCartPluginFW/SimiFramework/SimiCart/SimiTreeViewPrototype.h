//
//  SimiTreeViewPrototype.h
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/17/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiTreeView.h"

@interface SimiTreeViewPrototypePattern : NSObject
@property (strong, nonatomic) NSString *className, *name, *identify;
@end

@interface SimiTreeViewPrototype : NSObject <SimiTreeViewAlgorithm>

@end
