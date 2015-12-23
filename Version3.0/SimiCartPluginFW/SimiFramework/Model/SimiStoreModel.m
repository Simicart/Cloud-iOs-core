//
//  SimiStoreModel.m
//  SimiCartPluginFW
//
//  Created by Tan Hoang on 3/17/14.
//  Copyright (c) 2014 SimiTeam. All rights reserved.
//

#import "SimiStoreModel.h"

@implementation SimiStoreModel

- (void)getStoreWithStoreId:(NSString *)storeId{
    currentNotificationName = DidGetStore;
    [self preDoRequest];
    /*
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libDir = [paths objectAtIndex:0];
    NSString *storeConfigFilePath = [libDir stringByAppendingPathComponent:@"StoreConfig.plist"];
    NSFileManager *fileMan = [NSFileManager defaultManager];
    if ([fileMan fileExistsAtPath:storeConfigFilePath]) {
        NSDictionary *storeConfig = [[NSDictionary alloc] initWithContentsOfFile:storeConfigFilePath];
        if (!storeId || [[storeConfig valueForKey:@"store_id"] isEqualToString:storeId]) {
            //Request save store in Server session
            [(SimiStoreAPI *)[self getAPI] getStoreWithParams:@{@"store_id":[storeConfig valueForKey:@"store_id"]} target:self selector:@selector(didFinishRequest:responder:)];
        }else{
            [(SimiStoreAPI *)[self getAPI] getStoreWithParams:@{@"store_id":(storeId ? storeId : @"")} target:self selector:@selector(didFinishRequest:responder:)];
        }
    }else{
        [(SimiStoreAPI *)[self getAPI] getStoreWithParams:@{@"store_id":(storeId ? storeId : @"")} target:self selector:@selector(didFinishRequest:responder:)];
    }
    */
    [(SimiStoreAPI *)[self getAPI] getStoreWithParams:@{} target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)getThemeConfigure
{
    currentNotificationName = DidGetThemeConfigure;
    [self preDoRequest];
    [(SimiStoreAPI *)[self getAPI] getThemeConfigureParams:@{} target:self selector:@selector(didFinishRequest:responder:)];
}

- (void)didFinishRequest:(NSObject *)responseObject responder:(SimiResponder *)responder{
    if (responder.simiObjectName) {
        currentNotificationName = responder.simiObjectName;
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"TimeLoaderStop" object:currentNotificationName];
    if ([responseObject isKindOfClass:[SimiMutableDictionary class]]) {
        NSMutableDictionary *responseObjectData = [[SimiMutableDictionary alloc]initWithDictionary:(NSMutableDictionary*)responseObject];
        if ([currentNotificationName isEqualToString:DidGetStore]) {
            switch (modelActionType) {
                case ModelActionTypeInsert:{
                    [self addData:[responseObjectData valueForKey:@"settings"]];
                }
                    break;
                case ModelActionTypeEdit:{
                    [self editData:[responseObjectData valueForKey:@"settings"]];
                }
                    break;
                case ModelActionTypeDelete:{
                    [self deleteData];
                }
                    break;
                default:{
                    [self setData:[responseObjectData valueForKey:@"settings"]];
                }
                    break;
            }
        }else if([currentNotificationName isEqualToString:DidGetThemeConfigure])
        {
            switch (modelActionType) {
                case ModelActionTypeGet:{
                    if ([[responseObjectData valueForKey:@"app-configs"] isKindOfClass:[NSArray class]]) {
                        NSMutableArray *dataArray = [[NSMutableArray alloc]initWithArray:[responseObjectData valueForKey:@"app-configs"]];
                        if (dataArray.count > 0) {
                            NSMutableDictionary *dataObject = [dataArray objectAtIndex:0];
                            [self setData:dataObject];
                        }
                    }
                }
                    break;
                default:
                    break;
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:currentNotificationName object:self userInfo:@{@"responder":responder}];
    if (![currentNotificationName isEqualToString:@"DidFinishRequest"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidFinishRequest" object:self userInfo:@{@"responder":responder}];
    }
}

- (void)saveToLocal:(NSString*)storeID{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *librarayPath = [paths objectAtIndex:0];
    NSString *storeConfigFilePath = [librarayPath stringByAppendingPathComponent:@"StoreConfig.plist"];
    NSDictionary *storeConfig = [[NSDictionary alloc]initWithObjects:@[storeID]forKeys:@[@"store_id"]];
    [storeConfig writeToFile:storeConfigFilePath atomically:YES];
}

@end
