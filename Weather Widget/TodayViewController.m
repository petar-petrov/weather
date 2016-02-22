//
//  TodayViewController.m
//  Weather Widget
//
//  Created by Petar Petrov on 15/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "UIImageView+Networking.h"
#import "MMOpenWeatherMapManager.h"

#import "MMCityManager.h"

#import <notify.h>

@import Foundation;

@interface TodayViewController () <NCWidgetProviding>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.preferredContentSize = CGSizeMake(self.view.frame.size.width , 80.0f);
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    
    [self.view addGestureRecognizer:tapGesture];
    
    __weak TodayViewController *weakSelf = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      TodayViewController *strongSelf = weakSelf;
                                                      
                                                      [strongSelf handleContextDidChange:note];
                                                  }];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    City *favoriteCity = [[MMCityManager defaultManager] favoriteCity];
    
    if (favoriteCity) {
        [[MMOpenWeatherMapManager sharedManager] updateForecastForCityWithID:favoriteCity.cityID completionHandler:^{
            
            
            City *favoriteCity = [[MMCityManager defaultManager] favoriteCity];
            
            Weather *currentWeather = (Weather *)favoriteCity.currentWeather;
            
            NSInteger temp = currentWeather.temp.integerValue;
            
            self.nameLabel.text = favoriteCity.name;
            self.tempLabel.text = [NSString stringWithFormat:@"%ldº", temp];
            
            NSString *urlString = [[MMCityManager defaultManager] iconURLStringForWeather:favoriteCity.currentWeather];
            
            [self.imageView setImageWithURLString:urlString placeholder:nil];
        }];
    } else {
        self.nameLabel.text = @"No Favorite City Chosen";
        self.tempLabel.text = @"";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    
    City *favoriteCity = [[MMCityManager defaultManager] favoriteCity];
    
    if (favoriteCity) {
        [[MMOpenWeatherMapManager sharedManager] updateForecastForCityWithID:favoriteCity.cityID completionHandler:^{
            
            
            City *favoriteCity = [[MMCityManager defaultManager] favoriteCity];
            
            Weather *currentWeather = (Weather *)favoriteCity.currentWeather;
            
            NSInteger temp = currentWeather.temp.integerValue;
            
            self.nameLabel.text = favoriteCity.name;
            self.tempLabel.text = [NSString stringWithFormat:@"%ldº", temp];
            
            NSString *urlString = [[MMCityManager defaultManager] iconURLStringForWeather:favoriteCity.currentWeather];
            
            [self.imageView setImageWithURLString:urlString placeholder:nil];
            
            completionHandler(NCUpdateResultNewData);
        }];
    } else {
        self.nameLabel.text = @"No Favorite City Chosen";
        self.tempLabel.text = @"";
        
        completionHandler(NCUpdateResultNewData);
    }
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    return UIEdgeInsetsZero;
}

#pragma mark - Private 

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer {
    NSURL *weatherAppURL = [NSURL URLWithString:@"mmweather://"];
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.weatherContainer"];
    
    [userDefaults setBool:@(YES) forKey:@"ExtensionTapped"];
    [userDefaults synchronize];
    
    [self.extensionContext openURL:weatherAppURL completionHandler:nil];
}

- (void)handleContextDidChange:(NSNotification *)notification{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.weatherContainer"];
    
    NSMutableDictionary *notificationData = [NSMutableDictionary dictionary];
    
    for (id key in notification.userInfo) {
        if ([notification.userInfo[key] isKindOfClass:[NSSet class]]) {
            NSMutableArray *uriRepresentations = [NSMutableArray array];
            
            for (id element in notification.userInfo[key]) {
                if ([element isKindOfClass:[NSManagedObject class]]) {
                    NSManagedObject *managedObject = (NSManagedObject *)element;
                    
                    [uriRepresentations addObject:managedObject.objectID.URIRepresentation];
                } else {
                    continue;
                }
            }
            
            notificationData[key] = uriRepresentations;
            
            NSMutableArray *notificationQueue = [NSMutableArray array];
            
            NSData *data = [userDefaults dataForKey:@"NotificationQueue"];
            NSArray *existingNotificationQueue = nil;
            if (data) {
                 existingNotificationQueue = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                [notificationQueue addObjectsFromArray:existingNotificationQueue];
            }
            
            [notificationQueue addObject:notificationData];
            
            NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:notificationQueue];
            
            [userDefaults setObject:archivedData forKey:@"NotificationQueue"];
            [userDefaults synchronize];
            
        } else {
            continue;
        }
    }
}



@end
