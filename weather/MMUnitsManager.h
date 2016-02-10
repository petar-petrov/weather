//
//  MMUnitsManager.h
//  weather
//
//  Created by Petar Petrov on 08/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import <Foundation/Foundation.h>

//extern NSString *const kUnitsMetric;
//extern NSString *const kUnitsImperial;

typedef NS_ENUM(NSInteger, MMUnits) {
    MMUnitsMetric,
    MMUnitsImperial
};

@interface MMUnitsManager : NSObject

+ (instancetype)sharedManager;

- (void)setUnits:(MMUnits)units;

@property (nonatomic, readonly) NSString *currentUnit;

@property (nonatomic, readonly) NSString *speedUnit;
@property (nonatomic, readonly) NSString *pressureUnit;
@property (nonatomic, readonly) NSString *humidityUnit;

@end
