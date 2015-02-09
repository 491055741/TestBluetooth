//
//  Earth2Mars.h
//  TestBluetooth
//
//  Created by LiPeng on 2/5/15.
//  Copyright (c) 2015 LiPeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Earth2Mars : NSObject
//判断是否已经超出中国范围
+(BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location;
//转GCJ-02
+(CLLocationCoordinate2D)transformFromWGSToGCJ:(CLLocationCoordinate2D)wgsLoc;

@end

