//
//  SimiStoreLocatorViewController_iPad.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 7/18/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiStoreLocatorViewControllerPad.h"
#import "SimiGlobalVar+StoreLocator.h"
NSInteger const widthListView = 420;
NSInteger const heightButtonSearch = 50;



@interface SimiStoreLocatorViewControllerPad ()

@end

@implementation SimiStoreLocatorViewControllerPad
{
    BOOL ispopOverController;
    BOOL isSearchViewController;
    BOOL isDetailViewController;
}
@synthesize popOverController, btnSearch;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark View Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self showAlertContactSimiCartWithMessage:@"This is demo data of SimiCart. You are free to configure this data with the full version"];
    sLListViewControllerLandscape = [[SimiStoreLocatorListViewController alloc]init];
    sLListViewControllerLandscape.delegate = self;
    sLListViewControllerLandscape.sLModelCollection = [[SimiStoreLocatorModelCollection alloc]init];
    
    cLController = [[SimiCLController alloc]init];
    cLController.delegate = self;
    if (SIMI_SYSTEM_IOS >= 8.0) {
        [cLController.locationManager requestWhenInUseAuthorization];
    }
    [cLController.locationManager startUpdatingLocation];

    [self addChildViewController:sLListViewControllerLandscape];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetStoreLocatorList:) name:@"StoreLocator_DidGetStoreList" object:nil];
    // Do any additional setup after loading the view.
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self setInterfaceLandscape];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark SimiCLController Delegate
- (void)locationUpdate:(CLLocation *)location
{
    [cLController.locationManager stopUpdatingLocation];
    [self didGetCurrentLocationWithLatitube:location.coordinate.latitude andLongitube:location.coordinate.longitude];
}

- (void)locationError:(NSError *)error
{
    [self didGetCurrentLocationWithLatitube:0 andLongitube:0];
}

- (void) didGetCurrentLocationWithLatitube:(float)la andLongitube:(float)lng
{
    if (sLMapViewController == nil) {
        sLMapViewController = [[SimiStoreLocatorMapViewController alloc]init];
    }
    sLMapViewController.delegate = self;
    sLMapViewController.currentLatitube = la;
    sLMapViewController.currentLongitube = lng;
    sLMapViewController.sLModelCollectionSyncList = sLListViewControllerLandscape.sLModelCollection;
    
    [self addChildViewController:sLMapViewController];
}

#pragma mark
#pragma mark Search Action
- (void)btnSearch_Click
{
    if (searchViewController == nil) {
        searchViewController = [SimiStoreLocatorSearchViewController new];
        searchViewController.delegate = self;
    }
    searchViewController.currentLatitube = sLMapViewController.currentLatitube;
    searchViewController.currentLongitube = sLMapViewController.currentLongitube;
    if (popOverController == nil) {
        popOverController = [[UIPopoverController alloc]initWithContentViewController:searchViewController];
        popOverController.delegate = self;
        CGRect rect = CGRectMake(SCREEN_WIDTH - 250, SCREEN_HEIGHT/2, 1, 1);
        if (SIMI_SYSTEM_IOS > 7.0){
            [self.popOverController setBackgroundColor:[UIColor whiteColor]];
        }
        [self.popOverController presentPopoverFromRect:rect inView:self.view permittedArrowDirections:0 animated:YES];
        ispopOverController = YES;
        isSearchViewController = YES;
    }
}

#pragma mark Sync Data From List To Map
- (void)didGetStoreLocatorList:(NSNotification*)noti
{
    sLMapViewController.sLModelCollectionSyncList =  sLListViewControllerLandscape.sLModelCollection;
    [sLMapViewController syncDataFromList];
    [sLMapViewController showMaker];
}

#pragma mark btnSearch
- (UIButton*)setInterfaceButtonSearch:(ButtonSearchOption)searchOption
{
    btnSearch = [[UIButton alloc]init];
    [btnSearch addTarget:self action:@selector(btnSearch_Click) forControlEvents:UIControlEventTouchUpInside];
    switch (searchOption) {
        case ButtonSearchOptionLandscape:
            [btnSearch setFrame:CGRectMake(0, 0, widthListView, heightButtonSearch)];
            [btnSearch setTitle:@"Search By Area" forState:UIControlStateNormal];
            [btnSearch setTitleColor:[self colorWithStringHex:@"adadb1"] forState:UIControlStateNormal];
            [btnSearch.titleLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
            btnSearch.backgroundColor = [UIColor colorWithRed:227.0/255.0 green:228.0/255.0 blue:230.0/255.0 alpha:1.0];
            break;
        case ButtonSearchOptionPortrait:
            [btnSearch setFrame:CGRectMake(SCREEN_WIDTH - 60,0, 50, 50)];
            [btnSearch setTitle:@"" forState:UIControlStateNormal];
            [btnSearch setImage:[UIImage imageNamed:@"sl__search_area.png"] forState:UIControlStateNormal];
            btnSearch.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
            btnSearch.backgroundColor = [UIColor clearColor];
            break;
        default:
            break;
    }
    return btnSearch;
}

#pragma mark Set Interface List, Map

- (void)setInterfaceLandscape
{
    [self setInterfaceButtonSearch:ButtonSearchOptionLandscape];
    [self.view addSubview:btnSearch];
    
    UIImageView *imageSearch = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"storelocator_icon_search.png"]];
    [imageSearch setFrame:CGRectMake(70, 15, 16, 16)];
    [self.view addSubview:imageSearch];
    
    [sLListViewControllerLandscape.view setFrame:CGRectMake(0, heightButtonSearch, widthListView, self.view.bounds.size.height)];
    [self.view addSubview:sLListViewControllerLandscape.view];
    
    [sLMapViewController.view setFrame:CGRectMake(widthListView, 0, SCREEN_WIDTH - widthListView, self.view.bounds.size.height)];
    [self.view addSubview:sLMapViewController.view];
}

#pragma mark ListViewController Delegate
-(void)didChoiseStoreFromListToMap
{
    sLMapViewController.sLModel = sLListViewControllerLandscape.sLModel;
    sLMapViewController.mapViewOption = MapViewSelectedMarker;
    [sLMapViewController showMaker];
}


#pragma mark Modify UIColor

- (UIColor*) colorWithStringHex:(NSString*)stringHex
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:stringHex];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

#pragma mark List View Controller Delegate
- (void)showViewDetailControllerFromList:(SimiStoreLocatorModel *)sLModel_
{
    isDetailViewController = YES;
    detailViewController = [SimiStoreLocatorDetailViewController new];
    detailViewController.sLModel = sLModel_;
    detailViewController.currentLatitude = sLMapViewController.currentLatitube;
    detailViewController.currentLongitude = sLMapViewController.currentLongitube;
    
    detailViewController.preferredContentSize = CGSizeMake(SCREEN_WIDTH * 2/3, SCREEN_HEIGHT *2/3);
    if (popOverController == nil) {
        popOverController = [[UIPopoverController alloc]initWithContentViewController:detailViewController];
        popOverController.delegate = self;
        CGRect rect = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1);
        if (SIMI_SYSTEM_IOS > 7.0){
            [self.popOverController setBackgroundColor:[UIColor whiteColor]];
        }
        [self.popOverController presentPopoverFromRect:rect inView:self.view permittedArrowDirections:0 animated:YES];
        ispopOverController = YES;
        isDetailViewController = YES;
    }
}

#pragma mark Map View Controller Delegate
- (void)showViewDetailControllerFromMap:(SimiStoreLocatorModel *)sLModel_
{
    isDetailViewController = YES;
    detailViewController = [SimiStoreLocatorDetailViewController new];
    detailViewController.sLModel = sLModel_;
    detailViewController.currentLatitude = sLMapViewController.currentLatitube;
    detailViewController.currentLongitude = sLMapViewController.currentLongitube;
    detailViewController.preferredContentSize = CGSizeMake(SCREEN_WIDTH * 2/3, SCREEN_HEIGHT *2/3);
    
    if (popOverController == nil) {
        popOverController = [[UIPopoverController alloc]initWithContentViewController:detailViewController];
        popOverController.delegate = self;
        CGRect rect = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1);
        if (SIMI_SYSTEM_IOS > 7.0){
            [self.popOverController setBackgroundColor:[UIColor whiteColor]];
        }
        [self.popOverController presentPopoverFromRect:rect inView:self.view permittedArrowDirections:0 animated:YES];
        ispopOverController = YES;
        isDetailViewController = YES;
    }
}

#pragma mark popOverViewController Delegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (popOverController) {
        popOverController = nil;
        isSearchViewController = NO;
        ispopOverController = NO;
        isDetailViewController = NO;
    }
}

#pragma mark SearchView Controller Delegate
- (void)searchStoreLocatorWithCountryName:(NSString *)countryName countryCode:(NSString *)countryCode city:(NSString *)city state:(NSString *)state zipcode:(NSString *)zipcode tag:(NSString *)tag
{
    [popOverController dismissPopoverAnimated:YES];
    popOverController = nil;
    
    sLListViewControllerLandscape.dictSearch = @{@"countryCode":countryCode,@"countryName":countryName,@"city":city,@"state":state,@"zipcode":zipcode,@"tag":tag};
    if (sLMapViewController == nil) {
        sLMapViewController = [[SimiStoreLocatorMapViewController alloc]init];
    }
    sLMapViewController.dictSearch = @{@"countryCode":countryCode,@"countryName":countryName,@"city":city,@"state":state,@"zipcode":zipcode,@"tag":tag};
    
    sLListViewControllerLandscape.listViewOption = ListViewOptionSearched;
    sLMapViewController.searchOption = SearchOptionSearched;
}

- (void)cacheDataWithstoreLocatorModelCollection:(SimiStoreLocatorModelCollection *)collection simiAddressStoreLocatorModelCollection:(SimiAddressStoreLocatorModelCollection *)addressCollection simiConfigSearchStoreLocatorModel:(SimiConfigSearchStoreLocatorModel *)configSearch simiTagModelCollection:(SimiTagModelCollection *)tagModelCollection tagChoise:(NSString *)tagString
{
    [sLListViewControllerLandscape.sLModelCollection removeAllObjects];
    for (int i = 0; i < collection.count; i++) {
        [sLListViewControllerLandscape.sLModelCollection addObject:[collection objectAtIndex:i]];
    }
    [sLListViewControllerLandscape.tableView reloadData];
    
    if (sLMapViewController == nil) {
        sLMapViewController = [[SimiStoreLocatorMapViewController alloc]init];
    }
    [sLMapViewController.sLModelCollectionAll removeAllObjects];
    for (int i = 0; i < collection.count; i++) {
        [sLMapViewController.sLModelCollectionAll addObject:[collection objectAtIndex:i]];
    }
    
    [sLMapViewController showMaker];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end
