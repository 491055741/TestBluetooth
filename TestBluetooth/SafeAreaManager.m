//
//  SafeAreaManager.m
//  TestBluetooth
//
//  Created by LiPeng on 2/5/15.
//  Copyright (c) 2015 LiPeng. All rights reserved.
//

#import "SafeAreaManager.h"

@interface SafeAreaManager()
@end

@implementation SafeAreaManager

+ (SafeAreaManager *)shareInstance
{
    static SafeAreaManager *safeAreaManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        safeAreaManager = [[SafeAreaManager alloc] init];
    });

    return safeAreaManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[SafeAreaManager filePath:@"safaAreas.plist"]]) {
            [self load];
        } else {
            self.safeAreasArray = [NSMutableArray arrayWithCapacity:5];
        }
    }
    return self;
}

- (void)save
{
    [self.safeAreasArray writeToFile:[SafeAreaManager filePath:@"safaAreas.plist"] atomically:YES];
}

- (void)load
{
    self.safeAreasArray = [[NSMutableArray alloc] initWithContentsOfFile:[SafeAreaManager filePath:@"safaAreas.plist"]];
}

+ (NSString *)filePath:(NSString *)fileName
{
    NSAssert(fileName.length != 0, @"FileManager get filePath: filename is nil!");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}
@end
