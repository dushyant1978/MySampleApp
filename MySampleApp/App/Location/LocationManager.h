
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

@class AppDelegate;
@class ShareManager;


@protocol LocationManagerDelegate <NSObject>
- (void)didUpdateCurrentLocation:(CLLocation*)location subLocality:(NSString*)subLocality inLocality:(NSString*)locality;
@end

@interface LocationManager : NSObject <CLLocationManagerDelegate> {
   CLGeocoder* mGeoCoder;
}

@property (nonatomic, assign) id <LocationManagerDelegate> delegate;
@property (nonatomic,retain) CLLocationManager* locationManager;

@end
