#import "LocationManager.h"

@interface LocationManager ()

@end


@implementation LocationManager

@synthesize delegate;

- (id)init {
	if ((self = [super init])) {

      _locationManager = [[CLLocationManager alloc] init];
      _locationManager.delegate = self;
      _locationManager.allowsBackgroundLocationUpdates = YES;
      // Start heading updates.

      CLAuthorizationStatus st = [CLLocationManager authorizationStatus];
      if (st == kCLAuthorizationStatusNotDetermined && [_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
	      [_locationManager requestAlwaysAuthorization];         
      }
      if ([CLLocationManager locationServicesEnabled]) {
         _locationManager.distanceFilter = 100;
         _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
         [_locationManager startUpdatingLocation];
         _locationManager.pausesLocationUpdatesAutomatically = NO;
      }
   }
	return self;
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
   NSLog(@"locationManagerdidFailWithError %@",[error description]);
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
   if (locations) {
      CLLocation* location = [locations objectAtIndex:[locations count]-1];
      if (location) {
         //NSLog(@"Location %.2f, %.2f",location.coordinate.latitude,location.coordinate.longitude);
         
         if (!mGeoCoder) {
            mGeoCoder = [[CLGeocoder alloc] init];
         }
         
         [mGeoCoder reverseGeocodeLocation:location completionHandler:
          ^(NSArray* placemarks, NSError* error){
             if ([placemarks count] > 0)
             {
                CLPlacemark* loc = [placemarks objectAtIndex:0];
                NSLog(@"%@,%@,%@,%@",loc.name,loc.thoroughfare,loc.subLocality,loc.locality);
                [delegate didUpdateCurrentLocation:location subLocality:loc.subLocality inLocality:loc.locality];
             }
          }];
      }
   }
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
   //NSLog(@"locationManagerDidPauseLocationUpdates");
}

@end
