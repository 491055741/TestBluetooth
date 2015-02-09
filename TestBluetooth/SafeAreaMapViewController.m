//
//  SafeAreaMapViewController.m
//  TestBluetooth
//
//  Created by LiPeng on 2/9/15.
//  Copyright (c) 2015 LiPeng. All rights reserved.
//

#import "SafeAreaMapViewController.h"
#import <MapKit/MapKit.h>
#import "SafeAreaManager.h"
#import "POI.h"

@interface SafeAreaMapViewController () <MKMapViewDelegate>
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@end

@implementation SafeAreaMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_userLocation) {
        POI *poi = [[POI alloc] init];
        poi.coordinate = _userLocation.coordinate;
        [_mapView addAnnotation:poi];
        [_mapView setRegion:MKCoordinateRegionMakeWithDistance(_userLocation.coordinate, 100, 100)];
        [_mapView setCenterCoordinate:_userLocation.coordinate animated:YES];
    } else {
        NSLog(@"%s Should set userlocaton first.", __func__);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -
#pragma mark MKMapViewDelegate method

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[POI class]])
    {
        static NSString *defaultPinID = @"SafeAreaPinView";
        MKPinAnnotationView* pinView = (MKPinAnnotationView*)[_mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if (pinView == nil)
        {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID];
            pinView.pinColor = MKPinAnnotationColorRed;
            pinView.canShowCallout = NO;
            pinView.animatesDrop = NO;
            pinView.draggable = NO;
            pinView.selected = NO;
        }
        else
            pinView.annotation = annotation;
        return pinView;
    }
    
    return nil;
}
@end
