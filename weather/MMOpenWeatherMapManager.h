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

- (void)fetchWeatherForecaseForCity:(NSString *)name completionHandler:(void (^) (NSDictionary *))handler;

- (void)updateAllCitiesWithCompletionHandler:(void (^)(void))block;

- (void)searchForCityWithText:(NSString *)text completionHandler:(void(^)(NSArray *))handler;

@end
