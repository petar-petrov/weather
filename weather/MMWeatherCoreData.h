//
//  MMWeatherCoreData.h
//  weather
//
//  Created by Petar Petrov on 28/01/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreData;

@class City;

@interface MMWeatherCoreData : NSObject

@property (strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

/*!
 Save the current context
 */
- (void)saveContext;

- (NSManagedObjectContext *)privateContext;

//- (void)addCityWithInfo:(NSDictionary *)info;
//- (void)cityWithName:(NSString *)name updateForecast:(NSDictionary *)forecastInfo;
//- (void)cityWithName:(NSString *)name updateFiveDayForecast:(NSArray *)forecastInfo;
//
//- (NSArray *)allCities; // not implemented
//- (City *)cityWithName:(NSString *)name;

@end
