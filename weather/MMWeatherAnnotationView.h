//
//  MMWeatherAnnotationView.h
//  weather
//
//  Created by Petar Petrov on 04/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import <MapKit/MapKit.h>

@class MMWeatherPin;


@interface MMWeatherAnnotationView : MKAnnotationView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;

- (void)updateWithAnnotation:(MMWeatherPin *)annotation;

@end
