//
//  MapViewController.m
//  TestBluetooth
//
//  Created by LiPeng on 2/3/15.
//  Copyright (c) 2015 LiPeng. All rights reserved.
//

#import "CurPosMapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SafeAreaManager.h"

@interface CurPosMapViewController () <MKMapViewDelegate>
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UIButton *confirmBtn;
@property (nonatomic, strong) MKUserLocation *userLocation;

@end

@implementation CurPosMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"当前位置";
    // Do any additional setup after loading the view.

    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    _confirmBtn.enabled = NO;
    if (authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
        authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        _mapView.showsUserLocation = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)confirm
{
    _confirmBtn.enabled = NO;
    [self startedReverseGeoderWithLatitude:_userLocation.coordinate.latitude longitude:_userLocation.coordinate.longitude];
}

- (void)startedReverseGeoderWithLatitude:(double)latitude longitude:(double)longitude
{
    CLLocationCoordinate2D coordinate2D;
    coordinate2D.longitude = longitude;
    coordinate2D.latitude = latitude;
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];

    [geoCoder reverseGeocodeLocation:_userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {

//        NSLog(@"current address: %@", )
        for (NSString *addr in placemarks) {
            NSLog(@"addr: %@", addr);
        }
        NSDictionary *dict = @{@"location":self.userLocation, @"address":[placemarks count] ? placemarks[0] : @"安全区域"};
        [[SafeAreaManager shareInstance].safeAreasArray addObject:dict];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddSafeArea" object:self userInfo:dict];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"已添加安全区域" message:@"进入安全区域将自动关闭报警" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
                                                    [self.navigationController popViewControllerAnimated:YES];
                                                }]];
        [self presentViewController:alert animated:YES completion:^{}];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSLog(@"%s", __func__);

    self.userLocation = userLocation;
    _confirmBtn.enabled = YES;
    [mapView setRegion:MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 100, 100)];
    [mapView setCenterCoordinate:userLocation.coordinate animated:YES];
}

@end
