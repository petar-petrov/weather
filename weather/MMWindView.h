//
//  MMWindView.h
//  weather
//
//  Created by Petar Petrov on 11/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMWindView : UIView

@property (assign, nonatomic) double windAngle;
@property (assign, nonatomic) double windSpeed;

@property (strong, nonatomic) UIColor *arrowColor;

@end
