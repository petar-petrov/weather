//
//  MMSearchTableViewController.m
//  weather
//
//  Created by Petar Petrov on 27/01/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMSearchTableViewController.h"
#import "MMWeatherCoreData.h"
#import "City.h"
#import "MMOpenWeatherMapManager.h"

#import "MMCityManager.h"

@interface MMSearchTableViewController () <UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate>

@property (strong, nonatomic) UISearchController *searchController;

@property (copy, nonatomic) NSArray *cities;

@property (nonatomic, readonly) MMWeatherCoreData *dataStore;
@property (nonatomic, readonly) MMOpenWeatherMapManager *manager;

@end

@implementation MMSearchTableViewController

#pragma mark - Custom Accessor

- (MMWeatherCoreData *)dataStore {
    return [MMWeatherCoreData defaultDataStore];
}

- (MMOpenWeatherMapManager *)manager {
    return [MMOpenWeatherMapManager sharedManager];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.showsCancelButton = YES;
    
    self.navigationItem.titleView = self.searchController.searchBar;
    
    self.definesPresentationContext = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self performSelector:@selector(showKeyboard) withObject:nil afterDelay:0.1];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // add the selected city to the data store
    
    NSDictionary *cityData = self.cities[indexPath.row][@"cityData"];
    
    [[MMCityManager defaultManager] addCityWithInfo:cityData];
    
    [self dismissViewController];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.cities count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CityCell"];
    
    cell.textLabel.text = self.cities[indexPath.row][@"name"];
    
    return cell;
}

#pragma mark - UISearchResultUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    if (searchController.searchBar.text.length > 2) {
        NSLog(@"%@",searchController.searchBar.text);
        
        [self.manager searchForCityWithText:searchController.searchBar.text completionHandler:^(NSArray *result){
            if (result) {
                self.cities = result;
                
                [self.tableView reloadData];
            }
        }];
        
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self dismissViewController];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}

#pragma mark - Private

- (void)dismissViewController {
    
    [self.searchController.searchBar resignFirstResponder];
    
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showKeyboard {
    [self.searchController.searchBar becomeFirstResponder];
}

@end
