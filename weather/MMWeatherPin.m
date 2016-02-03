//
//  MMWeatherPin.m
//  weather
//
//  Created by Petar Petrov on 03/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMWeatherPin.h"

#import "City.h"
#import "Weather.h"

@interface MMWeatherPin ()

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

@property (strong, nonatomic) City *city;

@end

@implementation MMWeatherPin

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
    self.imageName = @"10d.png";
}
@end
