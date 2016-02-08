//
//  MMUnitsManager.m
//  weather
//
//  Created by Petar Petrov on 08/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMUnitsManager.h"

NSString *const kUnitsMetric = @"metric";
NSString *const kUnitsImperial = @"imperial";

@implementation MMUnitsManager

static NSString *const kMMWeatherUnit = @"MMweatherUnit";

#pragma mark - Custom Accessors

- (NSString *)currentUnit {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kMMWeatherUnit];
}

- (NSString *)speedUnit {
    
    if ([self.currentUnit isEqualToString:kUnitsMetric]) {
        return @"m/s";
    } else if ([self.currentUnit isEqualToString:kUnitsImperial]) {
        return @"mph";
    }
    
    return nil;
}

- (NSString *)pressureUnit {
    return @"hPa";
}

- (NSString *)humidityUnit {
    return @"%";
}

#pragma mark - Initilizers

+ (instancetype)sharedManager {
    static MMUnitsManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MMUnitsManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self setupManager];
    }
    
    return self;
}

#pragma mark - Public

- (void)setUnits:(NSString *)units {
    if (units) {
        [[NSUserDefaults standardUserDefaults] setObject:units forKey:kMMWeatherUnit];
        
        [[NSUserDefaults standardUserDefaults] synchronize];

    }
}

#pragma mark - Private

- (void)setupManager {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *unitString = [userDefaults stringForKey:kMMWeatherUnit];
    
    if (unitString == nil) {
        [userDefaults setObject:kUnitsMetric forKey:kMMWeatherUnit];
    }
    
    [userDefaults synchronize];
}




@end
