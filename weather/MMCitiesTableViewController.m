//
//  MMMainTableViewController.m
//  weather
//
//  Created by Petar Petrov on 28/01/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMCitiesTableViewController.h"
#import "MMOpenWeatherMapManager.h"
#import "MMWeatherTableViewCell.h"
#import "UIImageView+Networking.h"
#import "MMDetailedWeatherViewController.h"
#import "MMForecastDetailsTableViewController.h"

#import "MMMapViewController.h"

#import "MMReachabilityHandler.h"

#import "MMCityManager.h"
#import "MMUnitsManager.h"
#import <PKRevealController/PKRevealController.h>
#import "MMMenuButtonViewController.h"

@import CoreData;

@interface MMCitiesTableViewController () <NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultController;

@property (nonatomic, readonly) MMWeatherCoreData *dataStore;
@property (nonatomic, readonly) MMOpenWeatherMapManager *manager;

@property (strong, nonatomic) UIView *footerView;

@property (strong, nonatomic) NSIndexPath *currentlySelectedIndexPath;

@property (strong, nonatomic) UIRefreshControl *weatherRefreshControl;

@end

@implementation MMCitiesTableViewController

static NSString *const reuseIdentifier = @"WeatherCell";

#pragma mark - Custom Accessors

- (MMWeatherCoreData *)dataStore {
    return [MMWeatherCoreData defaultDataStore];
}

- (MMOpenWeatherMapManager *)manager {
    return [MMOpenWeatherMapManager sharedManager];
}

- (NSFetchedResultsController *)fetchedResultController {
    if (_fetchedResultController == nil) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription * entity = [NSEntityDescription entityForName:NSStringFromClass([City class]) inManagedObjectContext:self.dataStore.mainContext];
        
        fetchRequest.entity = entity;
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        fetchRequest.sortDescriptors = @[sortDescriptor];
        
        [fetchRequest setFetchBatchSize:20];
        
        _fetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                       managedObjectContext:self.dataStore.mainContext
                                                                         sectionNameKeyPath:nil
                                                                                  cacheName:nil];
        
        _fetchedResultController.delegate = self;
    }
    
    return _fetchedResultController;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    __autoreleasing NSError *error = nil;
    
    if (![self.fetchedResultController performFetch:&error]) {
        NSLog(@"Unresolved error %@ : %@", error, [error userInfo]);
        abort();
    }
    
    [self.tableView registerClass:[MMWeatherTableViewCell class] forCellReuseIdentifier:reuseIdentifier];
    
    self.weatherRefreshControl = [[UIRefreshControl alloc] init];
    [self.weatherRefreshControl addTarget:self action:@selector(pullDownRefresh) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = self.weatherRefreshControl;
    
    self.revealController.revealPanGestureRecognizer.delegate = self;
    
    self.title = @"Cities";
    
    [[NSNotificationCenter defaultCenter] addObserverForName:MMUnitsManagerDidChangeUnit
                                                      object:[MMUnitsManager sharedManager]
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification){
                                                      [self refreshWeatherData];
                                                  }];
}

- (void)pullDownRefresh {
    [self.manager updateAllCitiesWithCompletionHandler:^{
        [self.weatherRefreshControl endRefreshing];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self refreshWeatherData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MMUnitsManagerDidChangeUnit object:[MMUnitsManager sharedManager]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DetailedWeather"]) {
        MMForecastDetailsTableViewController *destinationViewController = (MMForecastDetailsTableViewController *)segue.destinationViewController;
        
        destinationViewController.city = [self.fetchedResultController objectAtIndexPath:self.currentlySelectedIndexPath];
    } else if ([segue.identifier isEqualToString:@"ShowMap"]) {
        MMMapViewController *destinationViewController = (MMMapViewController *)segue.destinationViewController;
        
        destinationViewController.cities = self.fetchedResultController.fetchedObjects;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.currentlySelectedIndexPath = indexPath;
    
    [self performSegueWithIdentifier:@"DetailedWeather" sender:self];
}

// ask about this
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return [self.fetchedResultController.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo>sectionInfo = self.fetchedResultController.sections[section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MMWeatherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        City *city = [self.fetchedResultController objectAtIndexPath:indexPath];
        
        [[MMCityManager defaultManager] deleteCity:city error:nil];
    }
}


#pragma mark - Private

- (void)configureNavgationBarTitle {
    NSMutableAttributedString *titleAttributedString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"MMWeather!", nil)];
    
    [titleAttributedString addAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]} range:NSMakeRange(0, 2)];
    [titleAttributedString addAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} range:NSMakeRange(2, titleAttributedString.length - 2)];
    [titleAttributedString addAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Futura-CondensedExtraBold" size:20.0f]} range:NSMakeRange(0, titleAttributedString.length)];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.attributedText = titleAttributedString;
    
    [titleLabel sizeToFit];
    
    self.navigationItem.titleView = titleLabel;
}

- (void)showSearch:(id)sender {
    [self performSegueWithIdentifier:@"ShowSearchView" sender:sender];
}

- (void)refreshWeatherData {
    [MMReachabilityHandler performReachabilityCheckWithReachableBlock:^{
                                                        [self.manager updateAllCitiesWithCompletionHandler:nil];
                                                    }
                                                   unreachableBlock:^{
                                                        [self showAlertView];
                                                   }];
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

- (void)configureCell:(MMWeatherTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    City *city = (City *)[self.fetchedResultController objectAtIndexPath:indexPath];
    
    cell.cityNameLabel.text = city.name;
    
    Weather *currentWeather = (Weather *)city.currentWeather;
    
    NSInteger temp = currentWeather.temp.integerValue;
    
    cell.temperatureLabel.text = [NSString stringWithFormat:@"%ldº", (long)temp];
    
    NSString *urlString = [[MMCityManager defaultManager] iconURLStringForWeather:city.currentWeather];
    
    [cell.iconImageView setImageWithURLString:urlString placeholder:nil];
}

#pragma mark - NSFetchedResultControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint touchPosition = [gestureRecognizer locationInView:self.view];
    
    if (!(touchPosition.x < 50.0f || touchPosition.x > self.view.bounds.size.width - 50.0f))
        return NO;
    
    return YES;
}

@end
