//
//  MMForecastDetailsTableViewController.m
//  weather
//
//  Created by Petar Petrov on 10/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMForecastDetailsTableViewController.h"
#import "MMForecastDetailsTableViewCell.h"

#import "MMCityManager.h"
#import "MMOpenWeatherMapManager.h"
#import "UIImageView+Networking.h"
#import "MMUnitsManager.h"

#import "MMWindView.h"

#import "MMWeatherForecastCollectionViewController.h"

@interface MMForecastDetailsTableViewController ()

@property (strong, nonatomic) NSArray <NSDictionary *> *forecastDetails;

@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@property (weak, nonatomic) IBOutlet MMWindView *windView;

@end

@implementation MMForecastDetailsTableViewController

static NSString *const kReuseIdentifier = @"DetailsCell";
static NSString *const kFiveDayForecastCollectionViewIdentifier = @"ForecastCollectionVeiw";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.city.name;
    
    Weather *currentWeather = (Weather *)self.city.currentWeather;
    
    self.windView.windAngle = currentWeather.windDegree.doubleValue;
    self.windView.windSpeed = currentWeather.windSpeed.doubleValue;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm";
    
    self.forecastDetails = @[@{@"pressure" : [currentWeather.pressure.stringValue stringByAppendingString:[MMUnitsManager sharedManager].pressureUnit]},
                             @{@"humidity" : [currentWeather.humidity.stringValue stringByAppendingString:[MMUnitsManager sharedManager].humidityUnit]},
                             @{@"sunrise" : [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:currentWeather.sunrise.doubleValue]]},
                             @{@"sunset" : [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:currentWeather.sunset.doubleValue]]}];
    
    NSInteger temp = currentWeather.temp.integerValue;
    self.temperatureLabel.text = [NSString stringWithFormat:@"%ldº", (long)temp];
    self.descriptionLabel.text = currentWeather.weatherDescription;
    
    [self.iconImageView setImageWithURLString:[[MMCityManager defaultManager] iconURLStringForWeather:self.city.currentWeather] placeholder:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kFiveDayForecastCollectionViewIdentifier]) {
        MMWeatherForecastCollectionViewController *destinationViewController = (MMWeatherForecastCollectionViewController *)segue.destinationViewController;
        
        destinationViewController.city = self.city;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.forecastDetails.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MMForecastDetailsTableViewCell *cell = (MMForecastDetailsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kReuseIdentifier forIndexPath:indexPath];
    
    NSDictionary *dic = self.forecastDetails[indexPath.row];
    NSString *key = [dic.allKeys lastObject];
    
    cell.titleLabel.text = key;
    cell.detailLabel.text = dic[key];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
