//
//  SafeAreaManager.h
//  TestBluetooth
//
//  Created by LiPeng on 2/5/15.
//  Copyright (c) 2015 LiPeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SafeAreaManager : NSObject

@property (nonatomic, strong) NSMutableArray *safeAreasArray;

+ (SafeAreaManager *)shareInstance;
- (void)save;

@end
