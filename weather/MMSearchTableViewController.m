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

@interface MMSearchTableViewController () <UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate>

@property (strong, nonatomic) UISearchController *searchController;

@property (copy, nonatomic) NSArray *cities;

@property (strong, nonatomic) MMWeatherCoreData *dataStore;
@property (strong, nonatomic) MMOpenWeatherMapManager *manager;

@end

@implementation MMSearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.manager = [[MMOpenWeatherMapManager alloc] init];
    
    self.dataStore = [[MMWeatherCoreData alloc] init];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.showsCancelButton = YES;
    
    self.navigationItem.titleView = self.searchController.searchBar;
    
    [self.searchController.searchBar becomeFirstResponder];
    
    [self.searchController setActive:YES];

    
    self.definesPresentationContext = YES;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    

}
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    // add the selected city to the data store
    
    NSDictionary *cityData = self.cities[indexPath.row][@"cityData"];
    
    [self.dataStore addCityWithInfo:cityData];
    
    [self dismissViewController];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

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

#pragma mark - UISearchControllerDelegate

- (void)didPresentSearchController:(UISearchController *)searchController {
    [searchController becomeFirstResponder];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self dismissViewController];
}

#pragma mark - Private

- (void)dismissViewController {
    [self.searchController.searchBar resignFirstResponder];
    
    self.searchController.active = NO;
    
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
