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

//- (void)updateConstraints {
//    if (!self.isConstraintsSet) {
//        [NSLayoutConstraint constraintWithItem:self.dateLabel
//                                     attribute:NSLayoutAttributeTop
//                                     relatedBy:NSLayoutRelationEqual
//                                        toItem:self.contentView
//                                     attribute:NSLayoutAttributeTop
//                                    multiplier:1.0
//                                      constant:0.0f].active = YES;
//        
//        [self.dateLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor].active = YES;
//        [self.dateLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor].active = YES;
//        
//        [self.imageView.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
//        [self.imageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
//        
//        
//        [self.tempLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor].active = YES;
//        [self.tempLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor].active = YES;
//        
//        [NSLayoutConstraint constraintWithItem:self.tempLabel
//                                     attribute:NSLayoutAttributeBottom
//                                     relatedBy:NSLayoutRelationEqual
//                                        toItem:self.contentView
//                                     attribute:NSLayoutAttributeBottom
//                                    multiplier:1.0f
//                                      constant:0.0f].active = YES;
//    }
//    
//    [super updateConstraints];
//}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.backgroundColor = [UIColor lightGrayColor];
    self.tempLabel.text = @"0";
    self.dateLabel.text = @"Today";
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
