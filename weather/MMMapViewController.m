//
//  MMMapViewController.m
//  weather
//
//  Created by Petar Petrov on 29/01/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMMapViewController.h"
#import "MMWeatherAnnotation.h"
#import "MMWeatherAnnotationView.h"

@import MapKit;

@interface MMMapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MMMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.mapView.delegate = self;
    
    @autoreleasepool {
        for (City *city in self.cities) {
            MMWeatherAnnotation *weatherAnnotation= [[MMWeatherAnnotation alloc] initWithCity:city];
            
            [self.mapView addAnnotation:weatherAnnotation];
        }
    }
    
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MMWeatherAnnotation class]]) {
        MMWeatherAnnotation *weatherAnnotation = (MMWeatherAnnotation *)annotation;
        
        MMWeatherAnnotationView *annotationView = (MMWeatherAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"WeatherAnnotation"];
        
        if (annotationView == nil) {
            annotationView = [self annotationViewWithAnnotation:weatherAnnotation];
        } else {
            [annotationView updateWithAnnotation:weatherAnnotation];;
        }
        
        return annotationView;
    }
    
    return nil;
}

- (MMWeatherAnnotationView *)annotationViewWithAnnotation:(id <MKAnnotation>)annotation {
    MMWeatherAnnotationView *annotationView = [[MMWeatherAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"WeatherAnnotation"];
    
    annotationView.enabled = YES;
    
    return annotationView;
}

@end
