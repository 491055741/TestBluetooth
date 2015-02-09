//
//  POI.h
//  TestBluetooth
//
//  Created by LiPeng on 2/9/15.
//  Copyright (c) 2015 LiPeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mapkit/MKAnnotation.h>

@interface POI : NSObject <MKAnnotation>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic) CLLocationCoordinate2D coordinate;

//- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end