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

@import QuartzCore;

@interface MMWeatherForecastCollectionViewController ()

@property (strong, nonatomic)NSArray *fiveDayForecast;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@end

@implementation MMWeatherForecastCollectionViewController

static NSString *const reuseIdentifier = @"ForecastCell";

static NSString *const fiveDayForecastKeyPath = @"self.city.fiveDayForcast";

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    [self addObserver:self forKeyPath:fiveDayForecastKeyPath options:NSKeyValueObservingOptionNew context:nil];
    
    // Register cell classes
    [self.collectionView registerNib:[UINib nibWithNibName:@"MMForecastCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    
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

- (void)dealloc {
        [self removeObserver:self forKeyPath:fiveDayForecastKeyPath];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:fiveDayForecastKeyPath]) {
        [self.loadingIndicator stopAnimating];
        self.loadingIndicator.hidden = YES;
        self.fiveDayForecast = [[MMCityManager defaultManager] fiveDayForecastForCity:self.city];
        [self.collectionView reloadData];
    }
    
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
    
    MMForecastCollectionViewCell *cell = (MMForecastCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    Weather *weather = self.fiveDayForecast[indexPath.row];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"EEEE";
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"HH:mm";
    
    cell.dateLabel.text = [formatter stringFromDate:weather.dataTimeText];
    cell.timeLabel.text = [timeFormatter stringFromDate:weather.dataTimeText];
    cell.tempLabel.text = [NSString stringWithFormat:@"%ldº", weather.temp.integerValue];
    [cell.imageView setImageWithURLString:[[MMCityManager defaultManager] iconURLStringForWeather:weather] placeholder:nil];;
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
