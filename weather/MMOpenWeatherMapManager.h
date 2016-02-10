//
//  MMOpenWeatherMapManager.h
//  weather
//
//  Created by Petar Petrov on 28/01/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreData;

@interface MMOpenWeatherMapManager : NSObject

+ (instancetype)sharedManager;

- (instancetype)init NS_UNAVAILABLE;

//- (void)fetchWeatherForecaseForCity:(NSString *)name completionHandler:(void (^) (NSDictionary *))handler;

- (void)updateAllCitiesWithCompletionHandler:(void (^)(void))block;

- (void)searchForCityWithText:(NSString *)text completionHandler:(void(^)(NSArray *))handler;

- (void)fetchFiveDayForecastForCityWithID:(NSNumber *)cityID completionHandler:(void(^)(void))handler;

@end
