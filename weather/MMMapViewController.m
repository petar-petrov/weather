//
//  MMMapViewController.m
//  weather
//
//  Created by Petar Petrov on 29/01/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMMapViewController.h"
#import "MMWeatherPin.h"

@import MapKit;

@interface MMMapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MMMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.mapView.delegate = self;
//    self.mapView.showsCompass = YES;
    
    @autoreleasepool {
        for (City *city in self.cities) {
            MMWeatherPin *weatherPin = [[MMWeatherPin alloc] initWithCity:city];
            
            [self.mapView addAnnotation:weatherPin];
        }
    }
    
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MMWeatherPin class]]) {
        MMWeatherPin *weatherPin = (MMWeatherPin *)annotation;
        
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"WeatherAnnotation"];
        
        if (annotationView == nil) {
            annotationView = [self annotationViewWithAnnotation:weatherPin];
        } else {
            annotationView.annotation = weatherPin;
        }
        
        return annotationView;
    }
    
    return nil;
}

- (MKAnnotationView *)annotationViewWithAnnotation:(id <MKAnnotation>)annotation {
    
    MMWeatherPin *weatherPin = (MMWeatherPin *)annotation;
    
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"WeatherAnnotation"];
    
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    annotationView.image = [UIImage imageNamed:weatherPin.imageName];
    
    return annotationView;
}

@end
