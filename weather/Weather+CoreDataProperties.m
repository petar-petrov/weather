//
//  Weather+CoreDataProperties.m
//  weather
//
//  Created by Petar Petrov on 15/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Weather+CoreDataProperties.h"

@implementation Weather (CoreDataProperties)

@dynamic clouds;
@dynamic dataTime;
@dynamic humidity;
@dynamic icon;
@dynamic isFiveDayForecast;
@dynamic pressure;
@dynamic sunrise;
@dynamic sunset;
@dynamic temp;
@dynamic timeStamp;
@dynamic weatherDescription;
@dynamic weatherMain;
@dynamic windDegree;
@dynamic windSpeed;
@dynamic city;
@dynamic forecastCity;

@end
