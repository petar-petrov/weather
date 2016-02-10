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
- (void)cityWithName:(NSString *)name updateForecast:(NSDictionary *)forecastInfo __deprecated;
- (void)cityWithID:(NSNumber *)cityID updateFiveDayForecast:(NSArray *)forecastInfo;
- (void)cityWithID:(NSNumber *)cityID updateForecast:(NSDictionary *)forecastInfo;

- (NSArray <Weather *> *)fiveDayForecastForCity:(City *)city;

- (NSArray <City *> *)allCities;
- (City *)cityWithName:(NSString *)name __deprecated;
- (City *)cityWithID:(NSNumber *)cityID;

- (BOOL)deleteCityWithName:(NSString *)name error:(NSError * __autoreleasing *)error __deprecated;
- (BOOL)deleteCity:(City *)city error:(NSError * __autoreleasing *)error;
- (BOOL)deleteCityWithID:(NSNumber *)cityID error:(NSError * __autoreleasing *)error;

- (NSString *)iconURLStringForWeather:(Weather *)weather;

- (void)saveChanges;

@end
