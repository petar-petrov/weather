//
//  MMDetailedWeatherViewController.m
//  weather
//
//  Created by Petar Petrov on 30/01/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMDetailedWeatherViewController.h"

#import "MMCityManager.h"
#import "MMUnitsManager.h"
#import "MMOpenWeatherMapManager.h"

#import "UIImageView+Networking.h"
#import "MMWeatherForecastCollectionViewController.h"
#import "MMForecastDetailsTableViewController.h"

@interface MMDetailedWeatherViewController ()
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (strong, nonatomic) MMWeatherForecastCollectionViewController *forecastCollectionViewController;
@property (strong, nonatomic) MMForecastDetailsTableViewController *forecastDetailsTableViewController;


@end

@implementation MMDetailedWeatherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = self.city.name;
    
    Weather *currentWeather = (Weather *)self.city.currentWeather;
    
    
    
    NSInteger temp = currentWeather.temp.integerValue;
    self.temperatureLabel.text = [NSString stringWithFormat:@"%ldº", (long)temp];
    self.descriptionLabel.text = currentWeather.weatherDescription;
    
    [self.iconImageView setImageWithURLString:[[MMCityManager defaultManager] iconURLStringForWeather:self.city.currentWeather] placeholder:nil];

//    self.windLabel.text = [currentWeather.windSpeed.stringValue stringByAppendingString:[MMUnitsManager sharedManager].speedUnit];
//    self.humidityLabel.text = [currentWeather.humidity.stringValue stringByAppendingString:[MMUnitsManager sharedManager].humidityUnit];
//    self.pressureLabel.text = [currentWeather.pressure.stringValue stringByAppendingString:[MMUnitsManager sharedManager].pressureUnit];
    
//    self.navigationController.toolbarHidden = YES;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    self.forecastCollectionViewController = (MMWeatherForecastCollectionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"WeatherForecastCollectionView"];
    self.forecastCollectionViewController.city = self.city;
    
    [self addChildViewController:self.forecastCollectionViewController];
    
    self.forecastCollectionViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.forecastCollectionViewController.view];
    [self.forecastCollectionViewController didMoveToParentViewController:self];
    
//    self.forecastDetailsTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"ForecastDetailsView"];
//    
//    [self addChildViewController:self.forecastDetailsTableViewController];
//    
//    self.forecastDetailsTableViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
//    
//    [self.view addSubview:self.forecastDetailsTableViewController.view];
//    [self.forecastDetailsTableViewController didMoveToParentViewController:self];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[MMOpenWeatherMapManager sharedManager] fetchFiveDayForecastForCityWithID:self.city.cityID completionHandler:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateViewConstraints {
    
    [self.forecastCollectionViewController.view.topAnchor constraintEqualToAnchor:self.descriptionLabel.bottomAnchor constant:30.0f].active = YES;
    [self.forecastCollectionViewController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.forecastCollectionViewController.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    
    [self.forecastCollectionViewController.view.heightAnchor constraintEqualToConstant:200.0f].active = YES;
    
//    [self.forecastDetailsTableViewController.view.topAnchor constraintEqualToAnchor:self.forecastDetailsTableViewController.view.bottomAnchor constant:10.0f].active = YES;
//    [self.forecastDetailsTableViewController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
//    [self.forecastDetailsTableViewController.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
//    [self.forecastDetailsTableViewController.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    [super updateViewConstraints];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
