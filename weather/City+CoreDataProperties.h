//
//  City+CoreDataProperties.h
//  weather
//
//  Created by Petar Petrov on 15/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "City.h"

NS_ASSUME_NONNULL_BEGIN

@interface City (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *cityID;
@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *favorite;
@property (nullable, nonatomic, retain) Weather *currentWeather;
@property (nullable, nonatomic, retain) NSSet<Weather *> *fiveDayForecast;

@end

@interface City (CoreDataGeneratedAccessors)

- (void)addFiveDayForecastObject:(Weather *)value;
- (void)removeFiveDayForecastObject:(Weather *)value;
- (void)addFiveDayForecast:(NSSet<Weather *> *)values;
- (void)removeFiveDayForecast:(NSSet<Weather *> *)values;

@end

NS_ASSUME_NONNULL_END
