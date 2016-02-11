//
//  MMWeatherForecastCollectionViewController.h
//  weather
//
//  Created by Petar Petrov on 08/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMCityManager.h"

@interface MMWeatherForecastCollectionViewController : UICollectionViewController

@property (strong, nonatomic) City *city;

- (void)stopLoadingIndicator;

@end
