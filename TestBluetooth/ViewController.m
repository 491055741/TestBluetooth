//
//  ViewController.m
//  TestBluetooth
//
//  Created by LiPeng on 1/29/15.
//  Copyright (c) 2015 LiPeng. All rights reserved.
//

#import "ViewController.h"
#import "LeDiscovery.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import <MapKit/MapKit.h>
#import "Earth2Mars.h"
#import "SafeAreaManager.h"

@interface ViewController () <LeDiscoveryDelegate, LeAntiLostAlarmProtocol, CLLocationManagerDelegate>
@property (nonatomic, strong) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong) IBOutlet UILabel *distanceLabel;
@property (nonatomic, strong) IBOutlet UISwitch *alarmSwitch;
@property (nonatomic, strong) IBOutlet UILabel *alarmSwitchLabel;
@property (nonatomic, strong) IBOutlet UIImageView *connectStateImageView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *userLocation;
@property (nonatomic, strong) UIAlertController *alertView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processAddSafeArea:) name:@"AddSafeArea" object:nil];
    [self requestLocation];

    [[LeDiscovery sharedInstance] setDiscoveryDelegate:self];
    [[LeDiscovery sharedInstance] setPeripheralDelegate:self];

    _connectStateImageView.animationImages = @[
                                               [UIImage imageNamed:@"connect1"],
                                               [UIImage imageNamed:@"connect2"],
                                               [UIImage imageNamed:@"connect3"],
                                               [UIImage imageNamed:@"connect4"],
                                               [UIImage imageNamed:@"connect5"],
                                               [UIImage imageNamed:@"connect6"],
                                               ];
    _connectStateImageView.animationDuration = 2;
    [self changeConnectStateTo:NO];

    _alarmSwitch.on = YES;
    _alarmSwitchLabel.text = _alarmSwitch.on ? @"防丢报警:开" : @"防丢报警:关";
}

- (void)processAddSafeArea:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    MKUserLocation *location = userInfo[@"location"];
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:location.coordinate radius:100 identifier:nil];
    [_locationManager startMonitoringForRegion:region];
}

- (void)requestLocation
{
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = 50;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;//kCLLocationAccuracyBestForNavigation;
//        if (SYSTEM_VERSION >= 8.0) {
            //使用期间
            [_locationManager requestWhenInUseAuthorization];
            //始终
            //or [self.locationManage requestAlwaysAuthorization]
//        }
    }
}

// todo : transform Mars location to Earth location

- (void)startMonitorSafeArea
{
    if (!self.userLocation) {
        [_locationManager startUpdatingLocation];
        return;
    }
    [[SafeAreaManager shareInstance].safeAreasArray removeAllObjects];
    [[SafeAreaManager shareInstance].safeAreasArray addObject:self.userLocation];
    for (CLLocation *location in [SafeAreaManager shareInstance].safeAreasArray) {
        CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:location.coordinate radius:100 identifier:@"safe"];
        [_locationManager startMonitoringForRegion:region];
        NSLog(@"%s monitor:%d %f-%f", __func__, [CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]], region.center.latitude, region.center.longitude);
    }
}

//- (void)stopMonitoringForRegion:(CLRegion *)region;


- (IBAction)alarmSwitchValueChanged:(UISwitch *)alarmSwitch
{
//    NSLog(@"%s Switch value:%d", __func__, alarmSwitch.on);
    [self alarmSwitchTo:alarmSwitch.on];
}

- (void)alarmSwitchTo:(BOOL)isAlarm
{
    _alarmSwitchLabel.text = isAlarm ? @"防丢报警:开" : @"防丢报警:关";
    if (_alarmSwitch.on != isAlarm) {
        _alarmSwitch.on = isAlarm;
    }
}

- (IBAction)callBtnClicked
{
    NSLog(@"%s bbbbbbb......", __func__);
    [self startMonitorSafeArea];
}

- (void)changeConnectStateTo:(BOOL)conneced
{
    if (conneced) {
        [_connectStateImageView stopAnimating];
        _connectStateImageView.image = [UIImage imageNamed:@"connected"];

    } else {
        [_connectStateImageView startAnimating];
    }
}

#pragma mark -
#pragma mark LeDiscoveryDelegate
/****************************************************************************/
/*                       LeDiscoveryDelegate Methods                        */
/****************************************************************************/
- (void) discoveryDidRefresh
{
//    [sensorsTable reloadData];
    NSLog(@"%s", __func__);
}

- (void) discoveryStatePoweredOff
{
    NSString *title     = @"Bluetooth Power";
    NSString *message   = @"You must turn on Bluetooth in Settings in order to use LE";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark -
#pragma mark LeAntiLostAlarmProtocol Delegate Methods
/****************************************************************************/
/*				LeAntiLostAlarmProtocol Delegate Methods					*/
/****************************************************************************/
/** Broke the high or low temperature bound */
- (void) alarmService:(LeAntiLostService*)service didSoundAlarmOfType:(AlarmType)alarm
{
    NSString *title;
    NSString *message;
    
    switch (alarm) {
        case kAlarmLow:
            NSLog(@"Alarm low");
            title     = @"Alarm Notification";
            message   = @"Low Alarm Fired";
            break;
            
        case kAlarmHigh:
            NSLog(@"Alarm high");
            title     = @"Alarm Notification";
            message   = @"High Alarm Fired";
            break;
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}


/** Back into normal values */
- (void) alarmServiceDidStopAlarm:(LeAntiLostService*)service
{
    NSLog(@"Alarm stopped");
}


/** Current temp changed */
//- (void) alarmServiceDidChangeTemperature:(LeAntiLostService*)service
//{
//    if (service != currentlyDisplayingService)
//        return;
//    
//    NSInteger currentTemperature = (int)[service temperature];
//    [currentTemperatureLabel setText:[NSString stringWithFormat:@"%dº", currentTemperature]];
//}


/** Max or Min change request complete */
//- (void) alarmServiceDidChangeTemperatureBounds:(LeAntiLostService*)service
//{
//    if (service != currentlyDisplayingService)
//        return;
//    
//    [maxAlarmLabel setText:[NSString stringWithFormat:@"MAX %dº", (int)[currentlyDisplayingService maximumTemperature]]];
//    [minAlarmLabel setText:[NSString stringWithFormat:@"MIN %dº", (int)[currentlyDisplayingService minimumTemperature]]];
//    
//    [maxAlarmStepper setEnabled:YES];
//    [minAlarmStepper setEnabled:YES];
//}
//

/** Peripheral connected or disconnected */
- (void) alarmServiceDidChangeStatus:(LeAntiLostService*)service
{
    if ( [service peripheral].state == CBPeripheralStateConnected ) {
        NSLog(@"%s Device (%@) connected", __func__, service.peripheral.name);
        _statusLabel.text = [NSString stringWithFormat:@"%@ connected." ,service.peripheral.name ];
        [self changeConnectStateTo:YES];
    } else {
        NSLog(@"%s Device (%@) disconnected", __func__, service.peripheral.name);
        _statusLabel.text = @"Connecting...";
        [self changeConnectStateTo:NO];
    }
}

- (void) alarmService:(LeAntiLostService*)service didUpdateRSSI:(NSNumber *)RSSI
{
    _distanceLabel.text = [NSString stringWithFormat:@"%d", [RSSI intValue]];
}

/** Central Manager reset */
- (void) alarmServiceDidReset
{
    NSLog(@"%s", __func__);
//    [connectedServices removeAllObjects];
}

#pragma mark
#pragma Location protocal delegate method
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"%s area name:%@", __func__, region.identifier);
    [self alarmSwitchTo:NO];
    self.alertView = [UIAlertController alertControllerWithTitle:@"您已进入安全区域" message:@"报警自动关闭" preferredStyle:UIAlertControllerStyleAlert];
    [_alertView addAction:[UIAlertAction actionWithTitle:@"OK"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *action) {
                                                     [_alertView dismissViewControllerAnimated:YES completion:^{}];
                                                 }]];
    [self presentViewController:_alertView animated:YES completion:^{}];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"%s area name:%@", __func__, region.identifier);
    [self alarmSwitchTo:YES];
    self.alertView = [UIAlertController alertControllerWithTitle:@"您已离开安全区域" message:@"报警自动开启" preferredStyle:UIAlertControllerStyleAlert];
    [_alertView addAction:[UIAlertAction actionWithTitle:@"OK"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *action) {
                                                     [_alertView dismissViewControllerAnimated:YES completion:^{}];
                                                 }]];
    [self presentViewController:_alertView animated:YES completion:^{}];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [_locationManager requestAlwaysAuthorization];
            }
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            [_locationManager startUpdatingLocation];
            break;
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.userLocation = [locations lastObject];
    NSLog(@"%s %f-%f", __func__, _userLocation.coordinate.latitude, _userLocation.coordinate.longitude);
}

@end
