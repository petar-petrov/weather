//
//  MMMenuTableViewController.m
//  weather
//
//  Created by Petar Petrov on 12/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMMenuTableViewController.h"
#import "MMUnitsManager.h"
#import <PKRevealController/PKRevealController.h>

#import "MMCitiesTableViewController.h"
#import "MMMapViewController.h"

@interface MMMenuTableViewController ()

@property (strong, nonatomic) NSArray *list;
@property (strong, nonatomic) NSArray *imageList;


@end

@implementation MMMenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.list = @[@"Cities", @"Map"];
    self.imageList = @[@"albums.png", @"map_location.png"];
    
    [self.tableView reloadData];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setupToolbar];
    
    [self configureNavgationBarTitle];
}

- (void)viewWillLayoutSubviews {
    [self centerTitleView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *viewController = self.viewControllers[indexPath.row];
    
    if (![self.revealController.frontViewController isEqual:viewController]) {
        self.revealController.frontViewController = viewController;
        
    }
    
    [self.revealController showViewController:viewController animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.list.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NavCell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.list[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:self.imageList[indexPath.row]];
    
    return cell;
}

#pragma mark - Private Methods

- (void)setupToolbar {
    UISegmentedControl *unitsSegmentedController = [[UISegmentedControl alloc] initWithItems:@[@"ºC", @"ºF"]];
    [unitsSegmentedController setWidth:44.0f forSegmentAtIndex:0];
    [unitsSegmentedController setWidth:44.0f forSegmentAtIndex:1];
    [unitsSegmentedController addTarget:self action:@selector(changeUnits:) forControlEvents:UIControlEventValueChanged];
    
    unitsSegmentedController.selectedSegmentIndex = ([[MMUnitsManager sharedManager].currentUnit isEqualToString:@"metric"]) ? 0 : 1;
    
    UIBarButtonItem *unitsBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:unitsSegmentedController];

    
    [self setToolbarItems:@[unitsBarButtonItem]];
}

- (void)changeUnits:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0) {
        [[MMUnitsManager sharedManager] setUnits:MMUnitsMetric];
    } else {
        [[MMUnitsManager sharedManager] setUnits:MMUnitsImperial];
    }
    
    [self.revealController showViewController:self.revealController.frontViewController animated:YES completion:nil];
}

- (void)configureNavgationBarTitle {
    NSMutableAttributedString *titleAttributedString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"MMWeather!", nil)];
    
    [titleAttributedString addAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]} range:NSMakeRange(0, 2)];
    [titleAttributedString addAttributes:@{NSForegroundColorAttributeName :  [[UIColor alloc]initWithRed: 0.219034 green: 0.598590 blue: 0.815217 alpha: 1 ]} range:NSMakeRange(2, titleAttributedString.length - 2)];
    [titleAttributedString addAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Futura-CondensedExtraBold" size:20.0f]} range:NSMakeRange(0, titleAttributedString.length)];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.attributedText = titleAttributedString;
    
    [titleLabel sizeToFit];
    
    self.navigationItem.titleView = titleLabel;
    
    [self centerTitleView];
}

- (void)centerTitleView {
    [(UILabel *)self.navigationItem.titleView sizeToFit];

    CGFloat dx = (((self.tableView.bounds.size.width / 2) - 260.0f) + (self.tableView.bounds.size.width / 2)) / 2;

    self.navigationItem.titleView.frame = CGRectInset(self.navigationItem.titleView.frame, -dx, 0);
}


@end
