//
//  MMDetailedWeatherViewController.m
//  weather
//
//  Created by Petar Petrov on 30/01/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMDetailedWeatherViewController.h"

#import "City.h"
#import "Weather.h"

#import "UIImageView+Networking.h"

@interface MMDetailedWeatherViewController ()
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *windLabel;
@property (weak, nonatomic) IBOutlet UILabel *humidityLabel;
@property (weak, nonatomic) IBOutlet UILabel *pressureLabel;


@end

@implementation MMDetailedWeatherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = self.city.name;
    
    Weather *currentWeather = (Weather *)self.city.currentWeather;
    
    NSInteger temp = currentWeather.temp.integerValue;
    self.temperatureLabel.text = [NSString stringWithFormat:@"%ldº", temp];
    self.descriptionLabel.text = currentWeather.weatherDescription;
    
    [self.iconImageView setImageWithURLString:[self urlStringForIcon:currentWeather.icon ] placeholder:nil];
    
    NSString *unitString = nil;
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"MMWeatherUnit"] isEqualToString:@"metric"]) {
        unitString = @"m/s";
    } else {
        unitString = @"mph";
    }

    self.windLabel.text = [currentWeather.windSpeed.stringValue stringByAppendingString:unitString];
    self.humidityLabel.text = [currentWeather.humidity.stringValue stringByAppendingString:@"%"];
    self.pressureLabel.text = [currentWeather.pressure.stringValue stringByAppendingString:@"hPa"];
    
//    self.navigationController.toolbarHidden = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Private
static NSString *const iconURLStringBase = @"http://openweathermap.org/img/w/";

- (NSString *)urlStringForIcon:(NSString *)icon {
    
    return [NSString stringWithFormat:@"%@%@.png", iconURLStringBase, icon];
}

@end
