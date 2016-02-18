//
//  MMWeatherForecastCollectionViewController.m
//  weather
//
//  Created by Petar Petrov on 08/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMWeatherForecastCollectionViewController.h"
#import "MMForecastCollectionViewCell.h"
#import "MMCollectionViewFlowLayout.h"

#import "UIImageView+Networking.h"
#import "MMOpenWeatherMapManager.h"

@import QuartzCore;

@interface MMWeatherForecastCollectionViewController () <UIGestureRecognizerDelegate>

@property (strong, nonatomic)NSArray *fiveDayForecast;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@end

@implementation MMWeatherForecastCollectionViewController

static NSString *const kReuseIdentifier = @"ForecastCell";

static NSString *const fiveDayForecastKeyPath = @"self.city.fiveDayForcast";

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    [[MMOpenWeatherMapManager sharedManager] fetchFiveDayForecastForCityWithID:self.city.cityID completionHandler:^(NSError *error) {
        
        if (error == nil) {
            [self.loadingIndicator stopAnimating];
            self.loadingIndicator.hidden = YES;
            self.fiveDayForecast = [[MMCityManager defaultManager] fiveDayForecastForCity:self.city];
            [self.collectionView reloadData];
        }
    }];
    
    // Register cell classes
    [self.collectionView registerNib:[UINib nibWithNibName:@"MMForecastCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:kReuseIdentifier];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"%@", NSStringFromCGRect(self.collectionView.bounds));
    
    MMCollectionViewFlowLayout *flowLayout = [[MMCollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 10.0f;
    flowLayout.minimumLineSpacing = 0.0f;
    flowLayout.sectionInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    flowLayout.itemSize = CGSizeMake(95.0f, self.collectionView.bounds.size.height - 10.0f);
    
    self.collectionView.collectionViewLayout = flowLayout;
    
    [self.loadingIndicator startAnimating];
}

- (void)stopLoadingIndicator {
    [self.loadingIndicator stopAnimating];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fiveDayForecast.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MMForecastCollectionViewCell *cell = (MMForecastCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kReuseIdentifier forIndexPath:indexPath];
    
    Weather *weather = self.fiveDayForecast[indexPath.row];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"eeee";
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"HH:mm";
    
    cell.dateLabel.text = [formatter stringFromDate:weather.dataTime];
    cell.timeLabel.text = [timeFormatter stringFromDate:weather.dataTime];
    cell.tempLabel.text = [NSString stringWithFormat:@"%ldº", weather.temp.integerValue];
    [cell.imageView setImageWithURLString:[[MMCityManager defaultManager] iconURLStringForWeather:weather] placeholder:nil];;
    cell.windView.windAngle = weather.windDegree.doubleValue;
    cell.windView.windSpeed = weather.windSpeed.doubleValue;
    cell.windView.arrowColor = [[UIColor alloc]initWithRed: 0.219034 green: 0.598590 blue: 0.815217 alpha: 1 ];
    
    return cell;
}

@end
