//
//  SimiFormMapAPI.m
//  SimiCartPluginFW
//
//  Created by ADMIN on 6/29/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SimiFormMapAPI.h"
#import <GoogleMaps/GoogleMaps.h>
#import <SimiCartBundle/UILabelDynamicSize.h>

@implementation SimiFormMapAPI
{
    GMSMapView *mapView_;
    CLLocation *myLocationChange;
    CLLocationManager *_locationAuthorizationManager;
    UILabel *guideLabel;
}
@synthesize form = _form, children = _children;
@synthesize title = _title, required = _required, sortOrder = _sortOrder, height = _height;
@synthesize enabled = _enabled;

- (instancetype)initWithConfig:(NSDictionary *)config
{
    [GMSServices provideAPIKey:@"AIzaSyDh-R-4SO0lAeWa-2Dkfe7YPMQIa75GR5c"];
    self = [super initWithConfig:config];
    if(self)
    {
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:5.111111
                                                                longitude:1.2223645
                                                                    zoom:6];
        float mapWidth = SCREEN_WIDTH;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            mapWidth = 2* SCREEN_WIDTH/3;
        }
        float padding = 15;
        guideLabel = [[UILabel alloc]initWithFrame:CGRectMake(padding, 0, mapWidth - padding*2, 20)];
        [guideLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:15]];
        [guideLabel setTextColor:THEME_CONTENT_PLACEHOLDER_COLOR];
        [guideLabel setText:SCLocalizedString(@"Please press and hold to select the address you want to fill")];
        float mapPaddingTop = [guideLabel resizLabelToFit];
        [self addSubview:guideLabel];
        
        mapView_ = [GMSMapView mapWithFrame:CGRectMake(padding, mapPaddingTop, mapWidth - padding,self.height - mapPaddingTop) camera:camera];
        mapView_.delegate = self;
        mapView_.settings.myLocationButton = YES;
        mapView_.settings.compassButton = YES;
    
        locationManager = [[CLLocationManager alloc]init]; // initializing locationManager
        locationManager.delegate = self; // we set the delegate of locationManager to self.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest; // setting the accuracy
        
        [locationManager startUpdatingLocation];  //requesting location updates

        // Ask for My Location data after the map has already been added to the UI.
        dispatch_async(dispatch_get_main_queue(), ^{
            mapView_.myLocationEnabled = YES;
        });
//        [self start];
        geocoder = [[CLGeocoder alloc] init];
        [self addSubview: mapView_];
    }
    return self;
}

- (void)start
{
    geocoder = [[CLGeocoder alloc] init];
 
    //Block address
    [geocoder reverseGeocodeLocation: locationManager.location completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         if (error==nil) {
             //Get address
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             if (SIMI_DEBUG_ENABLE) {
                 NSLog(@"Placemark array: %@",[placemark.addressDictionary valueForKey:@"lat"]);

                 //String to address
                 NSString *locatedaddress = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                 
                 //Print the location in the console
                 NSLog(@"Currently address is: %@",locatedaddress);
             }
             
         } else {
             CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
             
             // If the status is denied or only granted for when in use, display an alert
             if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
                 NSString *title;
                 title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
                 NSString *message = @"To use your current location, you must turn to \"Always\" in Location settings";
                 
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                     message:message
                                                                    delegate:self
                                                           cancelButtonTitle:@"Cancel"
                                                           otherButtonTitles:@"Settings", nil];
                 [alertView show];
             }
             // The user has not enabled any location services. Request background authorization.
             else if (status == kCLAuthorizationStatusNotDetermined) {
                 [locationManager requestAlwaysAuthorization];
             }
         }
     }];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
        NSString *message = @"To use your current location, you must turn to \"Always\" in Location settings";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Settings", nil];
        [alertView show];
        return;
    }
    
    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There was an error retrieving your location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [errorAlert show];
    NSLog(@"Error: %@",error.description);
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [locationManager stopUpdatingLocation];
    myLocationChange = [locations lastObject];
    NSString *myLocation = [NSString stringWithFormat:@"%.4f,%.4f",
                            myLocationChange.coordinate.latitude, myLocationChange.coordinate.longitude];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"getMyLocationCurrent" object: myLocation];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:myLocationChange.coordinate.latitude
                                                            longitude:myLocationChange.coordinate.longitude
                                                                 zoom:14];
    [mapView_ setCamera:camera];
}

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    if (_marker == nil) {
        _marker = [GMSMarker new];
        _marker.appearAnimation = kGMSMarkerAnimationPop;
        _marker.map = mapView;
    }
    _marker.position = coordinate;
    NSString *myLocation = [NSString stringWithFormat:@"%.4f,%.4f",coordinate.latitude, coordinate.longitude];
    [self updateFormData:myLocation];
    CLLocation *location = [[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [geocoder reverseGeocodeLocation: location completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         
         //Get address
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         
         NSLog(@"Placemark array: %@",placemark.addressDictionary );
         
         //String to address
         NSString *locatedaddress = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
         
         //Print the location in the console
         NSLog(@"Currently address is: %@",locatedaddress);
         [[NSNotificationCenter defaultCenter]postNotificationName:@"SimiFormMapAPI_DidGetAddress" object:placemark];
     }];
    
}
- (void)dealloc
{
     [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
