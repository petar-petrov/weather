//
//  MMWeatherTableViewCell.h
//  weather
//
//  Created by Petar Petrov on 29/01/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMWeatherTableViewCell : UITableViewCell

@property (strong, nonatomic, readonly) UILabel *cityNameLabel;
@property (strong, nonatomic, readonly) UILabel *temperatureLabel;
@property (strong, nonatomic, readonly) UILabel *timeLabel;
@property (strong, nonatomic, readonly) UIImageView *iconImageView;

@end
