//
//  MMMainTableViewController.m
//  weather
//
//  Created by Petar Petrov on 28/01/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMMainTableViewController.h"
#import "MMWeatherCoreData.h"
#import "City.h"
#import "MMOpenWeatherMapManager.h"
#import "MMWeatherTableViewCell.h"
#import "UIImageView+Networking.h"
#import "MMDetailedWeatherViewController.h"

#import "Weather.h"
#import "MMReachabilityHandler.h"


#import <Reachability/Reachability.h>

@interface MMMainTableViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) MMWeatherCoreData *dataStore;
@property (strong, nonatomic) MMOpenWeatherMapManager *manager;

@property (strong, nonatomic) UIView *footerView;

@property (strong, nonatomic) NSIndexPath *currentlySelectedIndexPath;

@end

@implementation MMMainTableViewController

- (NSFetchedResultsController *)fetchedResultController {
    if (_fetchedResultController != nil) {
        return _fetchedResultController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"City" inManagedObjectContext:self.dataStore.managedObjectContext];
    
    fetchRequest.entity = entity;
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setFetchBatchSize:20];
    
    _fetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                   managedObjectContext:self.dataStore.managedObjectContext
                                                                     sectionNameKeyPath:nil
                                                                              cacheName:nil];
    
    _fetchedResultController.delegate = self;
    
    return _fetchedResultController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.manager = [[MMOpenWeatherMapManager alloc] init];
    
    self.dataStore = [[MMWeatherCoreData alloc] init];
    
    __autoreleasing NSError *error = nil;
    
    if (![self.fetchedResultController performFetch:nil]) {
        NSLog(@"Unresolved error %@ : %@", error, [error userInfo]);
        abort();
    }
    
    
    [self.tableView registerClass:[MMWeatherTableViewCell class] forCellReuseIdentifier:@"WeatherCell"];
    
    [self setupToolbar];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
//    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
//    [refreshControl addTarget:self action:@selector(refreshWeather) forControlEvents:UIControlEventValueChanged];
    
    //self.refreshControl = refreshControl;
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self refreshWeatherData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.toolbarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.toolbarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)changeUnits:(id)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *unitString = [userDefaults stringForKey:@"MMWeatherUnit"];
    
    if ([unitString isEqualToString:@"metric"]) {
        [userDefaults setObject:@"imperial" forKey:@"MMWeatherUnit"];
    } else {
        [userDefaults setObject:@"metric" forKey:@"MMWeatherUnit"];
    }
    
    [userDefaults synchronize];
    
    [self refreshWeatherData];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DetailedWeather"]) {
        MMDetailedWeatherViewController *destinationViewController = (MMDetailedWeatherViewController *)segue.destinationViewController;
        
        destinationViewController.city = [self.fetchedResultController objectAtIndexPath:self.currentlySelectedIndexPath];
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
    
    static NSString *identifier = @"WeatherCell";
    
    MMWeatherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.fetchedResultController.managedObjectContext deleteObject:[self.fetchedResultController objectAtIndexPath:indexPath]];
        
        [self.dataStore saveContext];
    }
}


#pragma mark - Private

- (void)setupToolbar {
    UISegmentedControl *unitsSegmentedController = [[UISegmentedControl alloc] initWithItems:@[@"ºC", @"ºF"]];
    [unitsSegmentedController setWidth:44.0f forSegmentAtIndex:0];
    [unitsSegmentedController setWidth:44.0f forSegmentAtIndex:1];
    [unitsSegmentedController addTarget:self action:@selector(changeUnits:) forControlEvents:UIControlEventValueChanged];
    
    NSString *unitString = [[NSUserDefaults standardUserDefaults] stringForKey:@"MMWeatherUnit"];
    unitsSegmentedController.selectedSegmentIndex = [unitString isEqualToString:@"metric"] ? 0 : 1;
    
    UIBarButtonItem *unitsBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:unitsSegmentedController];
    
    UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showSearch:)];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self setToolbarItems:@[unitsBarButtonItem,flexibleSpace, addBarButtonItem]];
}

- (void)showSearch:(id)sender {
    [self performSegueWithIdentifier:@"Show Search View" sender:sender];
}

- (void)refreshWeatherData {
    MMReachabilityHandler *reachabilityHandler = [[MMReachabilityHandler alloc] init];
    
    [reachabilityHandler performReachabilityCheckWithReachableBlock:^{
                                                        [self.manager updateAllCities];
                                                    }
                                                   unreachableBlock:^ {
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

static NSString *const iconURLStringBase = @"http://openweathermap.org/img/w/";

- (NSString *)urlStringForIcon:(NSString *)icon {
    
    return [NSString stringWithFormat:@"%@%@.png", iconURLStringBase, icon];
}

- (void)configureCell:(MMWeatherTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    City *city = (City *)[self.fetchedResultController objectAtIndexPath:indexPath];
    
    cell.cityNameLabel.text = city.name;
    
    Weather *currentWeather = (Weather *)city.currentWeather;
    
    NSInteger temp = currentWeather.temp.integerValue;
    
    cell.temperatureLabel.text = [NSString stringWithFormat:@"%ldº", temp];
    
    NSString *urlString = [self urlStringForIcon:currentWeather.icon];
    
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


@end
