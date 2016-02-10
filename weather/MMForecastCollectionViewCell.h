//
//  MMForecastCollectionViewCell.h
//  weather
//
//  Created by Petar Petrov on 09/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMForecastCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic, readonly) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic, readonly) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;


@end
