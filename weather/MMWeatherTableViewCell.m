//
//  MMWeatherTableViewCell.m
//  weather
//
//  Created by Petar Petrov on 29/01/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMWeatherTableViewCell.h"

@interface MMWeatherTableViewCell ()

@property (strong, nonatomic, readwrite) UILabel *cityNameLabel;
@property (strong, nonatomic, readwrite) UILabel *temperatureLabel;
@property (strong, nonatomic, readwrite) UILabel *timeLabel;
@property (strong, nonatomic, readwrite) UIImageView *iconImageView;

@property (assign, nonatomic, getter=isConstraintSet) BOOL constraintSet;

@end

@implementation MMWeatherTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _cityNameLabel = [[UILabel alloc] init];
        _cityNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addSubview:_cityNameLabel];
        
        _temperatureLabel = [[UILabel alloc] init];
        _temperatureLabel.textAlignment = NSTextAlignmentRight;
        _temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:30.0f];
        _temperatureLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addSubview:_temperatureLabel];
        
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addSubview:_iconImageView];
        
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.translatesAutoresizingMaskIntoConstraints =  NO;
        
        [self.contentView addSubview:_timeLabel];
        
        [self.contentView setNeedsUpdateConstraints];
    }
    
    return self;
}

- (void)updateConstraints {
    
    if (!self.isConstraintSet) {
        [self.cityNameLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
        [self.cityNameLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:15.0f].active = YES;
        
        [self.temperatureLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
        [self.temperatureLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-15.0f].active = YES;
        [self.temperatureLabel.widthAnchor constraintEqualToConstant:60].active = YES;
        
        [self.iconImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
        [self.iconImageView.trailingAnchor constraintEqualToAnchor:self.temperatureLabel.leadingAnchor constant:8.0f].active = YES;
        
        [self.timeLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:15.0f].active = YES;
        
        [NSLayoutConstraint constraintWithItem:self.timeLabel
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.contentView
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0f
                                      constant:5.0f].active = YES;
        
        self.constraintSet = YES;
    }
    
    [super updateConstraints];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
