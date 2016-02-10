//
//  Weather+CoreDataProperties.h
//  weather
//
//  Created by Petar Petrov on 10/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Weather.h"

NS_ASSUME_NONNULL_BEGIN

@interface Weather (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *clouds;
@property (nullable, nonatomic, retain) NSDate *dataTimeText;
@property (nullable, nonatomic, retain) NSNumber *humidity;
@property (nullable, nonatomic, retain) NSString *icon;
@property (nullable, nonatomic, retain) NSNumber *isFiveDayForecast;
@property (nullable, nonatomic, retain) NSNumber *pressure;
@property (nullable, nonatomic, retain) NSNumber *sunrise;
@property (nullable, nonatomic, retain) NSNumber *sunset;
@property (nullable, nonatomic, retain) NSNumber *temp;
@property (nullable, nonatomic, retain) NSNumber *timeStamp;
@property (nullable, nonatomic, retain) NSString *weatherDescription;
@property (nullable, nonatomic, retain) NSString *weatherMain;
@property (nullable, nonatomic, retain) NSNumber *windDegree;
@property (nullable, nonatomic, retain) NSNumber *windSpeed;
@property (nullable, nonatomic, retain) City *city;
@property (nullable, nonatomic, retain) City *forecastCity;

@end

NS_ASSUME_NONNULL_END
