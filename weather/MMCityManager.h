//
//  MMCityManager.h
//  weather
//
//  Created by Petar Petrov on 05/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MMWeatherCoreData.h"
#import "City.h"
#import "Weather.h"

@interface MMCityManager : NSObject

@property (strong, nonatomic, readonly) MMWeatherCoreData *dataStore;

+ (instancetype)defaultManager;

- (instancetype)init NS_UNAVAILABLE;

- (void)addCityWithInfo:(NSDictionary *)info;
- (void)cityWithName:(NSString *)name updateForecast:(NSDictionary *)forecastInfo;
- (void)cityWithName:(NSString *)name updateFiveDayForecast:(NSArray *)forecastInfo; //not implemented

- (NSArray <City *> *)allCities;
- (City *)cityWithName:(NSString *)name;
- (City *)cityWithID:(NSInteger)cityID; // not implemented

- (BOOL)deleteCityWithName:(NSString *)name error:(NSError **)error;
- (BOOL)deleteCity:(City *)city error:(NSError **)error;

- (NSString *)iconURLStringForCity:(City *)city;

@end
