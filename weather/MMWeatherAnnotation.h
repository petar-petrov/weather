//
//  MMWeatherPin.h
//  weather
//
//  Created by Petar Petrov on 03/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import <Foundation/Foundation.h>

@import MapKit;

@class City;

@interface MMWeatherAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;;
@property (copy, nonatomic) NSString *subtitle;
@property (copy, nonatomic) NSString *imageName;
@property (strong, nonatomic) NSNumber *temp;

@property (strong, nonatomic, readonly) City *city;


- (instancetype)initWithCity:(City *)city;

@end
