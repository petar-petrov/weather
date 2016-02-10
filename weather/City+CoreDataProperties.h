//
//  City+CoreDataProperties.h
//  weather
//
//  Created by Petar Petrov on 10/02/2016.
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
@property (nullable, nonatomic, retain) Weather *currentWeather;
@property (nullable, nonatomic, retain) NSSet<Weather *> *fiveDayForcast;

@end

@interface City (CoreDataGeneratedAccessors)

- (void)addFiveDayForcastObject:(Weather *)value;
- (void)removeFiveDayForcastObject:(Weather *)value;
- (void)addFiveDayForcast:(NSSet<Weather *> *)values;
- (void)removeFiveDayForcast:(NSSet<Weather *> *)values;

@end

NS_ASSUME_NONNULL_END
