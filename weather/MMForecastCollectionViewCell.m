//
//  MMForecastCollectionViewCell.m
//  weather
//
//  Created by Petar Petrov on 09/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMForecastCollectionViewCell.h"


@interface MMForecastCollectionViewCell ()

@property (weak, nonatomic, readwrite) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic, readwrite) IBOutlet UIImageView *imageView;
@property (weak, nonatomic, readwrite) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic, readwrite) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic, readwrite) IBOutlet MMWindView *windView;

@property (assign, nonatomic, getter=isConstraintsSet) BOOL constraintsSet;

@end

@implementation MMForecastCollectionViewCell

- (void)prepareForReuse {
    [super prepareForReuse];

    self.tempLabel.text = @"0";
    self.dateLabel.text = @"Today";
    self.timeLabel.text = @"00:00";
    self.imageView.image = nil;
    self.windView.windSpeed = 0;
    self.windView.windAngle = 0;
    
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (self.highlighted) {
        self.tempLabel.alpha = 0.8f;
    } else {
        self.tempLabel.alpha = 1.0f;
    }
}

@end
