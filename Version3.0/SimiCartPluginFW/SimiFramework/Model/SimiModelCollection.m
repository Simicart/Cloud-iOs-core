//
//  SimiModelCollection.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 2/8/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiModelCollection.h"
#import "SimiModel.h"

@implementation SimiModelCollection

+ (SimiAPI *)getSimiAPI
{
    NSString *klass = [NSStringFromClass(self) stringByReplacingOccurrencesOfString:@"ModelCollection" withString:@"API"];
    Class api = NSClassFromString(klass);
    Class loopClass = [self superclass];
    while (api == nil && loopClass) {
        api = NSClassFromString([[loopClass description] stringByReplacingOccurrencesOfString:@"ModelCollection" withString:@"API"]);
        loopClass = [loopClass superclass];
    }
    return [api new];
}

- (id)init{
    self = [super init];
    if (self) {
        currentNotificationName = @"DidFinishRequest";
    }
    return self;
}

- (instancetype)initWithArray:(NSArray *)array{
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (NSDictionary *obj in array) {
        SimiModel *model = [self getModel];
        [model setData:obj];
        [temp addObject:model];
    }
    self = [super initWithArray:temp];
    return self;
}

- (void)setData:(SimiMutableArray *)data{
    if ([self count]) {
        [self removeAllObjects];
    }
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (NSDictionary *obj in data) {
        SimiModel *model = [self getModel];
        [model setData:obj];
        [temp addObject:model];
    }
    [self addObjectsFromArray:temp];
}

- (void)addData:(SimiMutableArray *)data{
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (NSDictionary *obj in data) {
        SimiModel *model = [self getModel];
        [model setData:obj];
        [temp addObject:model];
    }
    [self addObjectsFromArray:temp];
}

- (SimiModel *)getModel{
    Class superClass = self.class;
    Class modelClass = NSClassFromString([[superClass description] stringByReplacingOccurrencesOfString:@"Collection" withString:@""]);
    while (modelClass == nil) {
        superClass = [superClass superclass];
        modelClass = NSClassFromString([[superClass description] stringByReplacingOccurrencesOfString:@"Collection" withString:@""]);
    }
    return [modelClass new];
}

- (SimiAPI *)getAPI{
    return [self.class getSimiAPI];
}

- (NSString *)currentNotificationName
{
    return currentNotificationName;
}

- (void)didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder{
    if (responder.simiObjectName) {
        currentNotificationName = responder.simiObjectName;
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
    if ([responseObject isKindOfClass:[SimiMutableArray class]]) {
        switch (modelActionType) {
            case ModelActionTypeInsert:{
                [self addData:(SimiMutableArray *)responseObject];
            }
                break;
            default:{
                [self setData:(SimiMutableArray *)responseObject];
            }
                break;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
    }else if (responseObject == nil){
        [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
    }
}

- (void)preDoRequest{
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@Before", currentNotificationName] object:self];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStart" object:currentNotificationName];
}

@end
