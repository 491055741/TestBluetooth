//
//  SafeAreaMapViewController.h
//  TestBluetooth
//
//  Created by LiPeng on 2/9/15.
//  Copyright (c) 2015 LiPeng. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MKUserLocation;

@interface SafeAreaMapViewController : UIViewController
@property (nonatomic, strong) MKUserLocation *userLocation;
@end
