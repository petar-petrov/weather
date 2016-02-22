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
#import "MMReachabilityHandler.h"

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
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self performSelector:@selector(showKeyboard) withObject:nil afterDelay:0.1];
    
    [MMReachabilityHandler performReachabilityCheckWithReachableBlock:nil
                                                     unreachableBlock:^{
                                                         [self showAlertView];
                                                     }];
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
    
    if (searchController.searchBar.text.length > 1) {
        NSLog(@"%@",searchController.searchBar.text);
        
        [MMReachabilityHandler performReachabilityCheckWithReachableBlock:^{
            [self.manager searchForCityWithText:searchController.searchBar.text completionHandler:^(NSArray *result){
                if (result) {
                    self.cities = result;
                    
                    [self.tableView reloadData];
                }
            }];
            
        }
                                                         unreachableBlock:^{
                                                             [self showAlertView];
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

- (void)showAlertView {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Mobile Data is Turned Off", nil)
                                                                   message:NSLocalizedString(@"Turn on mobile data of use Wi-Fi to access data.", nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action){
                                                          }];
    
    [alert addAction:defaultAction];
    
    alert.preferredAction = defaultAction;
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
