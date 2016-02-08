//
//  MMWeatherAnnotationView.m
//  weather
//
//  Created by Petar Petrov on 04/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMWeatherAnnotationView.h"
#import "MMCityManager.h"
#import "UIImageView+Networking.h"

#import "MMWeatherAnnotation.h"

@interface MMWeatherAnnotationView ()

@property (strong, nonatomic, readwrite) City *city;

@property (assign, nonatomic, getter=isConstraintsSet) BOOL constraintsSet;

@property (strong, nonatomic) UILabel *cityLabel;
@property (strong, nonatomic) UILabel *tempLabel;
@property (strong, nonatomic) UIImageView *iconImageView;

@end

@implementation MMWeatherAnnotationView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.canShowCallout = NO;
        
        self.bounds = CGRectMake(0.0f, 0.0f, 50.0f, 70.0f);
        
        MMWeatherAnnotation *weatherAnnotation = (MMWeatherAnnotation *)annotation;
        
        _cityLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _cityLabel.text = weatherAnnotation.title;
        _cityLabel.textColor = [UIColor grayColor];//[[UIColor alloc]initWithRed: 0.219034 green: 0.598590 blue: 0.815217 alpha: 1 ];
        _cityLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        _cityLabel.minimumScaleFactor = 0.5f;
        _cityLabel.numberOfLines = 0;
        _cityLabel.textAlignment = NSTextAlignmentCenter;
        _cityLabel.shadowColor = [UIColor lightGrayColor];
        _cityLabel.shadowOffset = CGSizeMake(0.0f, 0.0f);
        
        _cityLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:_cityLabel];
        
        MMCityManager *cityManager = [MMCityManager defaultManager];
        
        City *city = [cityManager cityWithName:weatherAnnotation.title];
        
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_iconImageView setImageWithURLString:[cityManager iconURLStringForCity:city]
                                  placeholder:nil];
        
        _iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:_iconImageView];
        
        _tempLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tempLabel.text = [NSString stringWithFormat:@"%ldº", (long)weatherAnnotation.temp.integerValue];
        _tempLabel.textColor = [UIColor grayColor];
        _tempLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        _tempLabel.minimumScaleFactor = 0.5f;
        _tempLabel.textAlignment = NSTextAlignmentCenter;
        _tempLabel.shadowColor = [UIColor lightGrayColor];
        _tempLabel.shadowOffset = CGSizeMake(0.0f, 0.0f);
        
        _tempLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:_tempLabel];
        
        [self setNeedsUpdateConstraints];
    }
    
    return self;
}

- (void)updateWithAnnotation:(MMWeatherAnnotation *)annotation {
    self.annotation = annotation;
    
    self.cityLabel.text = annotation.title;
    
    MMCityManager *cityManager = [MMCityManager defaultManager];
    
    [self.iconImageView setImageWithURLString:[cityManager iconURLStringForCity:[cityManager cityWithName:annotation.title]]
                                  placeholder:[UIImage imageNamed:@"10d.png"]];
}

- (void)updateConstraints {
    if (!self.isConstraintsSet) {
        [NSLayoutConstraint constraintWithItem:self.cityLabel
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0f
                                      constant:0.0f].active = YES;
        
        [self.cityLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:0.0f].active = YES;
        [self.cityLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:0.0f].active = YES;
        
        [self.iconImageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
        [self.iconImageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
        [self.iconImageView.topAnchor constraintEqualToAnchor:self.cityLabel.bottomAnchor constant:-10.0f].active = YES;
        
        [self.tempLabel.topAnchor constraintEqualToAnchor:self.iconImageView.bottomAnchor constant:-10.0f].active = YES;
        [self.tempLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
        [self.tempLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
        
        self.constraintsSet = YES;
    }
    
    [super updateConstraints];
}

@end
