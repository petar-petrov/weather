//
//  MMUnitsManager.m
//  weather
//
//  Created by Petar Petrov on 08/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMUnitsManager.h"

@implementation MMUnitsManager

static NSString *const kMMWeatherUnit = @"MMweatherUnit";
static NSString *const kUnitsMetric = @"metric";
static NSString *const kUnitsImperial = @"imperial";

#pragma mark - Custom Accessors

- (NSString *)currentUnit {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kMMWeatherUnit];
}

- (NSString *)speedUnit {
    
    if ([self.currentUnit isEqualToString:kUnitsMetric]) {
        return NSLocalizedString(@"m/s", nil) ;
    } else if ([self.currentUnit isEqualToString:kUnitsImperial]) {
        return NSLocalizedString(@"mph", nil) ;
    }
    
    return nil;
}

- (NSString *)pressureUnit {
    return NSLocalizedString(@"hPa", <#comment#>) ;
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

- (void)setUnits:(MMUnits)units {
    
    switch (units) {
        case MMUnitsMetric:
            [[NSUserDefaults standardUserDefaults] setObject:kUnitsMetric forKey:kMMWeatherUnit];
            break;
        case MMUnitsImperial:
            [[NSUserDefaults standardUserDefaults] setObject:kUnitsImperial forKey:kMMWeatherUnit];
            break;
    }

    [[NSUserDefaults standardUserDefaults] synchronize];
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
