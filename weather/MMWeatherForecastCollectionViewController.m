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

@interface MMWeatherForecastCollectionViewController ()

@property (strong, nonatomic)NSArray *fiveDayForecast;

@end

@implementation MMWeatherForecastCollectionViewController

static NSString * const reuseIdentifier = @"ForecastCell";

//- (NSArray *)fiveDayForecast {
//    if (!_fiveDayForecast) {
//        _fiveDayForecast = [[MMCityManager defaultManager] fiveDayForecastForCity:self.city];
//    }
//    
//    return _fiveDayForecast;
//}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    [self addObserver:self forKeyPath:@"self.city.fiveDayForcast" options:NSKeyValueObservingOptionNew context:nil];
    
    // Register cell classes
    [self.collectionView registerNib:[UINib nibWithNibName:@"MMForecastCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    
    MMCollectionViewFlowLayout *flowLayout = [[MMCollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 10.0f;
    flowLayout.minimumLineSpacing = 0.0f;
    flowLayout.sectionInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    flowLayout.itemSize = CGSizeMake(80.0f, 200.0f);
    
    self.collectionView.collectionViewLayout = flowLayout;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self removeObserver:self forKeyPath:@"self.city.fiveDayForcast"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    self.fiveDayForecast = [[MMCityManager defaultManager] fiveDayForecastForCity:self.city];
    [self.collectionView reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    
    //NSLog(@"Cell");
    
    NSLog(@"%@", weather.dataTimeText);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/DD";
    
    cell.dateLabel.text = [formatter stringFromDate:weather.dataTimeText];
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
