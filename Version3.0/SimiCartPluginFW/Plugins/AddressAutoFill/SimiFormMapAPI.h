//
//  SimiFormMapAPI.h
//  SimiCartPluginFW
//
//  Created by ADMIN on 6/29/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiFormAbstract.h>
#import <GoogleMaps/GoogleMaps.h>
@interface SimiFormMapAPI : SimiFormAbstract <UIActionSheetDelegate,GMSMapViewDelegate,CLLocationManagerDelegate>

{
    CLGeocoder *geocoder;
    CLLocationManager* locationManager;
}

@property (nonatomic, strong) GMSMarker *marker;

@end
