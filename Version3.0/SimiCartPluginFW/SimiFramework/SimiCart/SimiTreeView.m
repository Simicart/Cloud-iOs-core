//
//  SimiTreeView.m
//  SimiCartPluginFW
//
//  Created by Nguyen Dac Doan on 11/17/14.
//  Copyright (c) 2014 Trueplus. All rights reserved.
//

#import "SimiTreeView.h"
#import "NSObject+SimiObject.h"
#import "SimiTreeViewPrototype.h"

@implementation SimiTreeView

+ (id<SimiTreeViewAlgorithm>)getAlgorithm
{
    return [SimiTreeViewPrototype singleton];
}

@end
