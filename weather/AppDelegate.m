//
//  AppDelegate.m
//  weather
//
//  Created by Petar Petrov on 27/01/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "AppDelegate.h"
#import "MMOpenWeatherMapManager.h"
#import <PKRevealController/PKRevealController.h>
#import "MMMenuTableViewController.h"
#import "MMCitiesTableViewController.h"
#import "MMMapViewController.h"
#import "MMCityManager.h"
#import "MMForecastDetailsTableViewController.h"
#import <notify.h>

@interface AppDelegate () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) PKRevealController *revealController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"WeatherList"];
    UINavigationController *mapViewController = [storyboard instantiateViewControllerWithIdentifier:@"Map"];
    
    UINavigationController *menuViewController = [storyboard instantiateViewControllerWithIdentifier:@"NavigationMenu"];
    
    [((MMMenuTableViewController *)menuViewController.viewControllers[0]) setViewControllers:@[navController, mapViewController]];
    
    self.revealController = [PKRevealController revealControllerWithFrontViewController:navController leftViewController:menuViewController];
    
    [self.window setRootViewController:self.revealController];
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self.window  makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [self mergeChangesFromWidget];
    
    int registrantionToken = 0;
    
    notify_register_dispatch("buttonPressed", &registrantionToken, dispatch_get_main_queue(), ^(int token){
        MMMenuTableViewController *menuTableViewController = (MMMenuTableViewController *)((UINavigationController *)self.revealController.leftViewController).viewControllers[0];
        
        MMCitiesTableViewController *citiesViewController = (MMCitiesTableViewController *)((UINavigationController *)menuTableViewController.viewControllers[0]).viewControllers[0];
        
        [self.revealController setFrontViewController:(UINavigationController *)menuTableViewController.viewControllers[0]];
        [self.revealController showViewController:(UINavigationController *)menuTableViewController.viewControllers[0]];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        MMForecastDetailsTableViewController *forecastTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"ForecastDetailsView"];
        forecastTableViewController.city = [[MMCityManager defaultManager] favoriteCity];
        
        [citiesViewController.navigationController pushViewController:forecastTableViewController animated:NO];
    });
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    [[MMOpenWeatherMapManager sharedManager] updateAllCitiesWithCompletionHandler:^{
        NSLog(@"Background Fetch performed");
        
        completionHandler(UIBackgroundFetchResultNewData);
    }];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer isEqual:self.revealController.revealPanGestureRecognizer]) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Private 

- (void)mergeChangesFromWidget {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.weatherContainer"];
    
    NSData *data = [userDefaults dataForKey:@"anKey"];
    
    if (data) {
        NSArray *notificationQueue = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        if (notificationQueue) {
            MMWeatherCoreData *dataStore = [MMWeatherCoreData defaultDataStore];
            
            [dataStore.mainContext performBlock:^{
                for (NSDictionary *notificationData in notificationQueue) {
                    [NSManagedObjectContext mergeChangesFromRemoteContextSave:notificationData intoContexts:@[dataStore.mainContext]];
                }
            }];
        }
    }
    
    [userDefaults removeObjectForKey:@"anKey"];
    [userDefaults synchronize];
}
@end
