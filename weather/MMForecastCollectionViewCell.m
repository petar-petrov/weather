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

@property (assign, nonatomic, getter=isConstraintsSet) BOOL constraintsSet;

@end

@implementation MMForecastCollectionViewCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    if (self) {
       self.backgroundColor = [UIColor lightGrayColor];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
    }
    
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.backgroundColor = [UIColor lightGrayColor];
    self.tempLabel.text = @"0";
    self.dateLabel.text = @"Today";
    self.timeLabel.text = @"00:00";
    self.imageView.image = nil;
    
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
