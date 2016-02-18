//
//  City+CoreDataProperties.m
//  weather
//
//  Created by Petar Petrov on 15/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "City+CoreDataProperties.h"

@implementation City (CoreDataProperties)

@dynamic cityID;
@dynamic latitude;
@dynamic longitude;
@dynamic name;
@dynamic favorite;
@dynamic currentWeather;
@dynamic fiveDayForecast;

@end
