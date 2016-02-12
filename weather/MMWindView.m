//
//  MMWindView.m
//  weather
//
//  Created by Petar Petrov on 11/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMWindView.h"
#import "MMUnitsManager.h"

@interface  MMWindView ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *northLabel;
@property (strong, nonatomic) UILabel *windSpeedLabel;

@property (assign, nonatomic, getter=isConstraintsSet) BOOL constraintsSet;

@end

@implementation MMWindView
#define DEGREES_TO_RADIANS(x) (x * (M_PI / 180))

#pragma mark - Custom Accessor

- (void)setWindAngle:(double)windAngle {
    if (_windAngle != windAngle) {
        _windAngle = windAngle;
        
        self.imageView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(_windAngle));
        
    }
}

- (void)setWindSpeed:(double)windSpeed {
    if (_windSpeed != windSpeed) {
        _windSpeed = windSpeed;
        
        self.windSpeedLabel.text = [NSString stringWithFormat:@"%d%@", (int)_windSpeed, [MMUnitsManager sharedManager].speedUnit];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.northLabel = [[UILabel alloc] init];
    self.northLabel.text = @"N";
    self.northLabel.font = [UIFont systemFontOfSize:10];
    self.northLabel.textAlignment = NSTextAlignmentCenter;
    
    self.northLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:self.northLabel];
    
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_vertical.png"]];
    
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:self.imageView];
    
    self.windSpeedLabel = [[UILabel alloc] init];
    self.windSpeedLabel.textAlignment = NSTextAlignmentCenter;
    self.windSpeedLabel.font = [UIFont boldSystemFontOfSize:10];
    
    self.windSpeedLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:self.windSpeedLabel];
}

- (void)updateConstraints {
    
    if (!self.isConstraintsSet) {
        [self.northLabel.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [self.northLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10.0f].active = YES;
        [self.northLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10.0f].active = YES;
        
        [self.imageView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
        [self.imageView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
        
        [self.windSpeedLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
        [self.windSpeedLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
        [self.windSpeedLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
        
        self.constraintsSet = YES;
    }
    
    
    
    [super updateConstraints];
    
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
