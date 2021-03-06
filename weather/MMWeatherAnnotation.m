//
//  MMWeatherPin.m
//  weather
//
//  Created by Petar Petrov on 03/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMWeatherAnnotation.h"

#import "City.h"
#import "Weather.h"

@interface MMWeatherAnnotation ()

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

@property (strong, nonatomic, readwrite) City *city;

@end

@implementation MMWeatherAnnotation

- (instancetype)initWithCity:(City *)city {
    self = [super init];
    
    if (self) {
        _city = city;
        
        [self setupAnnotation];
    }
    
    return self;
}


#pragma mark - Private 

- (void)setupAnnotation {
    self.title = self.city.name;
    self.subtitle = ((Weather *)self.city.currentWeather).temp.stringValue;
    
    self.coordinate = CLLocationCoordinate2DMake(self.city.longitude.doubleValue, self.city.latitude.doubleValue);
    self.imageName = ((Weather *)self.city.currentWeather).icon;
    self.temp = ((Weather *)self.city.currentWeather).temp;
}
@end
